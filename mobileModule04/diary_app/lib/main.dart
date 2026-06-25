import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/profile_page.dart';
import 'pages/authentication_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/create_entry_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xnaahbbnbsydufziewzf.supabase.co',
    publishableKey: 'sb_publishable_jY5_SgM6J9_RScVIPZWXMA_Pk_11ZEE',
  );

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
        '/': (context) => const LoginPage(),
        '/profile': (context) => const ProfilePage(),
        '/auth': (context) => AuthenticationPage(),
        '/create': (context) => const CreateEntryPage(),
      },
    );
  }
}