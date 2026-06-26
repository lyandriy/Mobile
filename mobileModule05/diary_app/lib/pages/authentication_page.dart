import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthenticationPage extends StatelessWidget {
  AuthenticationPage({super.key});

  final AuthService _authService = AuthService();

  void _goToProfile(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final success = await _authService.signInWithGoogle();

                if (success && context.mounted) {
                  _goToProfile(context);
                }
              },
              child: const Text('Continue with Google'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final success = await _authService.signInWithGitHub();

                if (success && context.mounted) {
                  _goToProfile(context);
                }
              },
              child: const Text('Continue with GitHub'),
            ),
          ],
        ),
      ),
    );
  }
}