import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/constants.dart';
import 'package:google_docs/models/DocumentModel.dart';
import 'package:google_docs/models/errorModel.dart';
import 'package:http/http.dart';

final documentRepositoryProvider =
    Provider((ref) => DocumentRepository(client: Client()));

class DocumentRepository {
  final Client _client;

  DocumentRepository({required Client client}) : _client = client;

  Future<ErrorModel> createDocument(String token) async {
    ErrorModel error =
        ErrorModel(error: "Something Unexpected Occured", data: null);
    try {
      var res = await _client.post(Uri.parse('$host/doc/create'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token
          },
          body:
              jsonEncode({'createdAt': DateTime.now().millisecondsSinceEpoch}));

      print('reached here----------');
      print(res.statusCode.toString());
      switch (res.statusCode) {
        case 200:
          print('here too');
          error =
              ErrorModel(error: null, data: Documentmodel.fromJson(res.body));

          break;
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  Future<ErrorModel> getDocuments(String token) async {
    ErrorModel error =
        ErrorModel(error: "Something Unexpected Occured", data: null);
    try {
      var res = await _client.get(
        Uri.parse('$host/docs/me'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token
        },
      );

      switch (res.statusCode) {
        case 200:
          List<Documentmodel> documents = [];

          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            documents.add(
                Documentmodel.fromJson(jsonEncode(jsonDecode(res.body)[i])));
          }
          error = ErrorModel(error: null, data: documents);
          print('reached here----------');
          print(res.statusCode.toString());
          break;
      }
    } catch (e) {
      print('Here');
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  void updateTitle(
      {required String token,
      required String id,
      required String title}) async {
    await _client.post(Uri.parse('$host/doc/title'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token
        },
        body: jsonEncode({'title': title, 'id': id}));
  }

  Future<ErrorModel> getDocumentByID(String token, String id) async {
    ErrorModel error =
        ErrorModel(error: "Something Unexpected Occured", data: null);
    try {
      var res = await _client.get(
        Uri.parse('$host/doc/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token
        },
      );

      switch (res.statusCode) {
        case 200:
          print(res.body.toString());
          error =
              ErrorModel(error: null, data: Documentmodel.fromJson(res.body));
          
          break;

        default:
          throw 'This Doucument Does not Exist!!';
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    print('reached here----------');
          
    return error;
  }
}
