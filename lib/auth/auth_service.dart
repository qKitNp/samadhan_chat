import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // instance of an auth
  final SupabaseClient supabase = Supabase.instance.client;
  // sign in

  Future<void> signInWithEmailPassword(
      String email, String password) async {
        try {
          await supabase.auth.signInWithPassword(email: email, password: password);
        } on AuthException catch (e) {
          throw Exception(e.message);
        }
  }

  Future<AuthResponse> registerWithEmailPassword(String email, String password) async {
    try {
      final authResponse = await supabase.auth.signUp(password: password, email: email);
      return authResponse;
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // sign out
}
