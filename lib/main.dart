import 'package:flutter/material.dart';
import 'package:kordofan_app/auth/login.dart';
import 'package:kordofan_app/auth/signup.dart';
import 'package:kordofan_app/grouches/grouche.dart';
import 'package:kordofan_app/grouches/meeting.dart';
import 'package:kordofan_app/home/homepage.dart';
import 'package:kordofan_app/notifictions%20and%20result/notifications.dart';
import 'package:kordofan_app/notifictions%20and%20result/result.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.indigo[100],
        primarySwatch: Colors.indigo,
        textTheme: const TextTheme(),
      ),
      home: Login(),
      routes: {
        "login": (context) => const Login(),
        "signup": (context) => Signup(),
        "homepage": (context) => HomePage(),
        "grouche": (context) => Grouche(),
        "meeting": (context) => Meeting(),
        "notifications": (context) => Notific(),
        "resultz": (context) => const Resultz(),
      },
    );
  }
}
