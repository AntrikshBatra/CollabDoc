import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/constants.dart';
import 'package:google_docs/models/errorModel.dart';
import 'package:google_docs/models/userModel.dart';
import 'package:google_docs/repository/localStorageRepo.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(
    googleSignIn: GoogleSignIn(),
    client: Client(),
    localStorage: LocalStorage()));

final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final LocalStorage _localStorage;

  AuthRepository(
      {required GoogleSignIn googleSignIn,
      required Client client,
      required localStorage})
      : _googleSignIn = googleSignIn,
        _client = client,
        _localStorage = localStorage;

  Future<ErrorModel> signInWithGoogle() async {
    ErrorModel error =
        ErrorModel(error: "Something Unexpected Occured", data: null);
    try {
      final user = await _googleSignIn.signIn();
      if (user != null) {
        final userAccount = UserModel(
            email: user.email,
            name: user.displayName!,
            profilePic: user.photoUrl ?? '',
            uid: '',
            token: '');

        var res = await _client.post(Uri.parse('$host/api/signup'),
            body: userAccount.toJson(),
            headers: {'Content-Type': 'application/json; charset=UTF-8'});

        switch (res.statusCode) {
          case 200:
            final newUser = userAccount.copyWith(
                uid: jsonDecode(res.body)['user']['_id'],
                token: jsonDecode(res.body)['token']);
            error = ErrorModel(error: null, data: newUser);
            _localStorage.setToken(newUser.token);
            break;
        }
        print(user.email);
        print(user.displayName);  
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  Future<ErrorModel> getUserData() async {
    ErrorModel error =
        ErrorModel(error: "Something Unexpected Occured", data: null);
    try {
      String? token = await _localStorage.getToken();

      if (token != null) {
        var res = await _client.get(Uri.parse('$host/'), headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token
        });

        switch (res.statusCode) {
          case 200:
            final newUser = UserModel.fromJson(jsonEncode(
              jsonDecode(res.body)['user'],
            )).copyWith(token: token);
            error = ErrorModel(error: null, data: newUser);
            _localStorage.setToken(newUser.token);
            break;
        }
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  void SignOut() async {
    await _googleSignIn.signOut();
    _localStorage.setToken('');
  }
}
