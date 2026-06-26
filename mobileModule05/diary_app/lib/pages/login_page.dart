import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  bool _checkingSession = true;
  late final Stream<AuthState> _authStateStream;

  @override
  void initState() {
    super.initState();

    _authStateStream = Supabase.instance.client.auth.onAuthStateChange;

    _authStateStream.listen((data) {
      if (!mounted) return;

      if (data.session != null) {
        Navigator.pushReplacementNamed(context, '/profile');
      }
    });

    Future.microtask(_checkSession);
  }

  Future<void> _checkSession() async {
    final bool isLoggedIn = await _authService.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/profile');
    } else {
      setState(() {
        _checkingSession = false;
      });
    }
  }

  void _goToAuthentication() {
    Navigator.pushNamed(context, '/auth');
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSession) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _goToAuthentication,
          child: const Text('Login'),
        ),
      ),
    );
  }
}