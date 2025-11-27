import 'package:app_rawg/firebase_options.dart';
import 'package:app_rawg/view/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MaterialApp(home: AuthPage(), debugShowCheckedModeBanner: false));
}
