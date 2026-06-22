import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/profile_page.dart';
import 'pages/authentication_page.dart';

void main() {
  runApp(const DiaryApp());
}

class DiaryApp extends StatelessWidget {
  const DiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diary App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/profile': (context) => const ProfilePage(),
        '/auth': (context) => AuthenticationPage(),
      },
    );
  }
}