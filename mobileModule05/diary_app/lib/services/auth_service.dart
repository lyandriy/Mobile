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
      redirectTo: 'io.supabase.diaryapp://login-callback/',
    );
  }

  Future<bool> signInWithGitHub() async {
    return await _client.auth.signInWithOAuth(
      OAuthProvider.github,
      redirectTo: 'io.supabase.diaryapp://login-callback/',
    );
  }

  Future<void> signOut() {
    return _client.auth.signOut();
  }
}