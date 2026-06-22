class AuthService {
  Future<bool> isLoggedIn() async {
    return false;
  }

  Future<bool> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> signInWithGitHub() async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}