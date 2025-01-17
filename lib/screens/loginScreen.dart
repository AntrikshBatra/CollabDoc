import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/models/errorModel.dart';
import 'package:google_docs/repository/auth_repository.dart';
import 'package:google_docs/screens/homeScreen.dart';
import 'package:google_docs/utils/colors.dart';
import 'package:routemaster/routemaster.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void signInWithGoogle(WidgetRef ref, BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Routemaster.of(context);
    final errorModel =
        await ref.read(authRepositoryProvider).signInWithGoogle();
    if (errorModel.error == null) {
      ref.read(userProvider.notifier).update((state) => errorModel.data);
      navigator.replace('/');
    } else {
      messenger.showSnackBar(SnackBar(content: Text(errorModel.error!)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => signInWithGoogle(ref, context),
          icon: Image.asset(
            "lib/assets/g-logo.png",
            height: 20,
          ),
          label: const Text(
            "Sign In With Google",
            style: TextStyle(color: BlackColor),
          ),
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(150, 50), backgroundColor: WhiteColor),
        ),
      ),
    );
  }
}
