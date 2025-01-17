import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/models/DocumentModel.dart';
import 'package:google_docs/models/errorModel.dart';
import 'package:google_docs/repository/auth_repository.dart';
import 'package:google_docs/repository/documentRepository.dart';
import 'package:google_docs/utils/colors.dart';
import 'package:google_docs/widgets/loader.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void signOut(WidgetRef ref) {
    ref.read(authRepositoryProvider).SignOut();
    ref.read(userProvider.notifier).update((state) => null);
  }

  void createDocument(BuildContext context, WidgetRef ref) async {
    String token = ref.read(userProvider)!.token;
    final navigator = Routemaster.of(context);
    final snackbar = ScaffoldMessenger.of(context);

    final errorModel =
        await ref.read(documentRepositoryProvider).createDocument(token);

    if (errorModel.data != null) {
      navigator.push('/document/${errorModel.data.id}');
    } else {
      snackbar.showSnackBar(SnackBar(content: Text(errorModel.error!)));
    }
  }

  void DocumentNavigator(BuildContext context, String DocumentID) {
    Routemaster.of(context).push('/document/$DocumentID');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: WhiteColor,
          elevation: 0,
          actions: [
            IconButton(
                onPressed: () => createDocument(context, ref),
                icon: const Icon(
                  Icons.add,
                  color: BlackColor,
                )),
            IconButton(
                onPressed: () => signOut(ref),
                icon: const Icon(
                  Icons.delete,
                  color: RedColor,
                ))
          ],
        ),
        body: FutureBuilder(
            future: ref
                .watch(documentRepositoryProvider)
                .getDocuments(ref.watch(userProvider)!.token),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.data == null) {
                return const Center(child: Text('No documents found.'));
              }
              return Center(
                child: Container(
                  width: 600,
                  margin: const EdgeInsets.only(top: 15),
                  child: ListView.builder(
                      itemCount: snapshot.data!.data.length,
                      itemBuilder: (context, index) {
                        Documentmodel document = snapshot.data!.data[index];

                        return InkWell(
                          onTap: () => DocumentNavigator(context, document.id),
                          child: SizedBox(
                            height: 60,
                            child: Card(
                              child: Center(
                                child: Text(
                                  document.title,
                                  style: TextStyle(fontSize: 17),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              );
            }));
  }
}
