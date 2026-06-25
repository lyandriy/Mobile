import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<bool> isLoggedIn() async {
    final session = _client.auth.currentSession;

    return session != null;
  }

  Future<bool> signInWithGoogle() async {
    return await _client.auth.signInWithOAuth(
      OAuthProvider.google,
    );
  }

  Future<bool> signInWithGitHub() async {
    return await _client.auth.signInWithOAuth(
      OAuthProvider.github,
    );
  }

  Future<void> signOut() {
    return _client.auth.signOut();
  }
}