import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/models/DocumentModel.dart';
import 'package:google_docs/models/errorModel.dart';
import 'package:google_docs/repository/auth_repository.dart';
import 'package:google_docs/repository/documentRepository.dart';
import 'package:google_docs/repository/socketRepository.dart';
import 'package:google_docs/utils/colors.dart';
import 'package:google_docs/widgets/loader.dart';
import 'package:routemaster/routemaster.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  TextEditingController titleController =
      TextEditingController(text: 'Untitled Document');
  quill.QuillController? _controller;
  ErrorModel? errorModel;
  SocketRepository repo = SocketRepository();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    repo.joinRoom(widget.id);
    repo.changeListener(
      (data) {
        try {
          // Ensure data format
          if (data.containsKey('delta') && data['delta'] is List) {
            final delta = Delta.fromJson(data['delta']);
            _controller!.compose(
              delta,
              _controller?.selection ??
                  const TextSelection.collapsed(offset: 0),
              quill.ChangeSource.remote,
            );
          } else {
            print("Invalid data format: $data");
          }
        } catch (e) {
          print("Error composing document: $e");
        }
      },
    );
    Timer.periodic(const Duration(seconds: 2), (timer) {
      repo.autoSave(<String, dynamic>{
        'delta': _controller!.document.toDelta(),
        'room': widget.id
      });
    });

    fetchDocumentData();
  }

  fetchDocumentData() async {
    print('11111111111111111111111111');
    errorModel = await ref
        .read(documentRepositoryProvider)
        .getDocumentByID(ref.read(userProvider)!.token, widget.id);

    print('22222222222222222222222222');    
    if (errorModel!.data != null) {
      titleController.text = (errorModel!.data as Documentmodel).title;
      _controller = quill.QuillController(
          document: errorModel!.data.content.isEmpty
              ? quill.Document()
              : quill.Document.fromDelta(Delta.fromJson(errorModel!.data.content as List)),
          selection: const TextSelection.collapsed(offset: 0));

          print('3333333333333333333333333333333');
      setState(() {});
    }
    print('ppppppppppppppppppppppppppppp');
    _controller!.document.changes.listen((event) {
      print('dcumentChanged');
      if (event.source == quill.ChangeSource.local) {
        Map<String, dynamic> map = {'delta': event.change, 'room': widget.id};
        repo.typing(widget.id, map);
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    titleController.dispose();
    _controller!.dispose();
  }

  void UpdateTitle(WidgetRef ref, String title) {
    print(title);
    ref.read(documentRepositoryProvider).updateTitle(
        token: ref.read(userProvider)!.token, id: widget.id, title: title);
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return Loader();
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: WhiteColor,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: BlueColor),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                            text:
                                'http://localhost:3000/#/document/${widget.id}'))
                        .then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Link Copied!!')));
                    });
                  },
                  icon: const Icon(
                    Icons.lock,
                    size: 16,
                    color: WhiteColor,
                  ),
                  label: const Text(
                    'Share',
                    style: TextStyle(color: WhiteColor),
                  )),
            ),
          ],
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Routemaster.of(context).replace('/');
                  },
                  child: Image.asset(
                    'lib/assets/docs-logo.png',
                    height: 40,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 180,
                  child: TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: BlueColor)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 5)),
                    onSubmitted: (value) => UpdateTitle(ref, value),
                  ),
                )
              ],
            ),
          ),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(0.1),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: greyColor, width: 0.4)),
              )),
        ),
        body: Center(
          child: Column(
            children: [
              quill.QuillSimpleToolbar(
                controller: _controller!,
                configurations: const quill.QuillSimpleToolbarConfigurations(),
              ),
              Expanded(
                child: SizedBox(
                  width: 750,
                  child: Card(
                    color: WhiteColor,
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: quill.QuillEditor.basic(
                        controller: _controller,
                        configurations: const quill.QuillEditorConfigurations(),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
