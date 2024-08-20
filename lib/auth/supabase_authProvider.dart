import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:samadhan_chat/auth/auth_exceptions.dart';
// import 'package:samadhan_chat/Auth/auth_exceptions.dart';
// import 'package:samadhan_chat/Auth/supabase_client_singleton.dart';
import 'package:samadhan_chat/auth/supabase_client_singleton.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_providers.dart';
import 'custom_auth_user.dart';

class SupabaseAuthProvider implements AuthProvider {
  late final SupabaseClient _supabase;
  CustomAuthUser? _cachedUser;

  @override
  Future<void> initialize() async {await SupabaseClientManager().initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_KEY']!,
    );
    _supabase = SupabaseClientManager().client;
  }

  @override
  Future<CustomAuthUser> createUser({required String email, required String password}) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user != null) {
        return CustomAuthUser.fromSupabase(user);
      } else {
        throw UserNotLoggedInAuthException();
      }
    } catch (e) {
      if (e is AuthException) {
        switch (e.message) {
          case 'User already registered':
            throw EmailAlreadyInUseAuthException();
          case 'Invalid email':
            throw InvalidEmailAuthException();
          case 'Weak password':
            throw WeakPasswordAuthException();
          default:
            throw GenericAuthException();
        }
      }
      throw GenericAuthException();
    }
  }

  @override
  CustomAuthUser? get currentUser {
    if (_cachedUser != null) return _cachedUser;
    final user = _supabase.auth.currentUser;
    if (user != null) {
      _cachedUser = CustomAuthUser.fromSupabase(user);
      return _cachedUser;
    }
    return null;
  }

  @override
  Future<CustomAuthUser> login({required String email, required String password}) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user != null) {
        return CustomAuthUser.fromSupabase(user);
      } else {
        throw UserNotLoggedInAuthException();
      }
    } catch (e) {
      if (e is AuthException) {
        switch (e.message) {
          case 'Invalid login credentials':
            throw InvalidCredentialAuthException();
          case 'Invalid email':
            throw InvalidEmailAuthException();
          default:
            throw GenericAuthException();
        }
      }
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logout() async {
    await _supabase.auth.signOut();
    _cachedUser = null;
  }

  @override
  Future<void> resendEmailVerification() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw UserNotLoggedInAuthException();
    
    try {
      await _supabase.auth.resend(type: OtpType.signup, email: user.email);
    } catch (e) {
      throw EmailVerificationException();
    }
  }

  @override
  Future<bool> isEmailVerified() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw UserNotLoggedInAuthException();
    
    // Fetch the latest user data
    final updatedUser = await _supabase.auth.getUser();
    return updatedUser.user?.emailConfirmedAt != null;
  }

  Future<void> refreshSession() async {
    try {
      await _supabase.auth.refreshSession();
    } catch (e) {
      throw SessionRefreshException();
    }
  }
  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(toEmail);
    } catch (e) {
      throw GenericAuthException();
    }
  }
  
  Future<String?> getSignInMethod() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    
    if (user.appMetadata['provider'] == 'google') {
      return 'google';
    } else if (user.appMetadata['provider'] == 'facebook') {
      return 'facebook';
    } else {
      return 'email';
    }
  }
  
  @override
  Future<CustomAuthUser> signInWithGoogle() async {
    try {
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );
      if (response) {
        final user = _supabase.auth.currentUser;
        if (user != null) {
          return CustomAuthUser.fromSupabase(user);
        }
      }
      throw UserNotLoggedInAuthException();
    } catch (e) {
      throw GoogleLoginFailureException();
    }
  }

  @override
  Future<CustomAuthUser> signInWithFacebook() async {
    try {
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/s',
      );
      if (response) {
        final user = _supabase.auth.currentUser;
        if (user != null) {
          return CustomAuthUser.fromSupabase(user);
        }
      }
      throw UserNotLoggedInAuthException();
    } catch (e) {
      throw FacebookSignInFailedAuthException();
    }
  }
}