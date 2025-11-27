import 'package:app_rawg/view/home_page.dart';
import 'package:app_rawg/view/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  static bool isGuest = false;
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            isGuest = false;
          }

          return snapshot.hasData || isGuest ? HomePage() : LoginPage();
        },
      ),
    );
  }
}
