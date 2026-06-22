import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final AuthService _authService = AuthService();

  void _goToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  void _goToAuthentication(BuildContext context) {
    Navigator.pushNamed(context, '/auth');
  }

  Future<void> _handleLogin(BuildContext context) async {
    final bool isLoggedIn = await _authService.isLoggedIn();

    if (!context.mounted) {
      return;
    }

    if (isLoggedIn) {
      _goToProfile(context);
    } else {
      _goToAuthentication(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _handleLogin(context);
          },
          child: const Text('Login'),
         ),
      ),
    );
  }
}