// AuthProvider is an abstract class that defines the methods that must be implemented by any class that wants to be an authentication provider.
// The AuthProvider class has the following methods:
// - initialize: This method is used to initialize the authentication provider.
// - currentUser: This method returns the current user.
// - login: This method is used to log in a user.
// - createUser: This method is used to create a new user.
// - logout: This method is used to log out a user.
// - sendEmailVerification: This method is used to send an email verification.
// - isEmailVerified: This method is used to check if the email is verified.
// - sendPasswordReset: This method is used to send a password reset email.
// The AuthProvider class is used by the AuthBloc to interact with the authentication provider.
// The AuthUser class is a simple data class that represents a user.

import 'custom_auth_user.dart';

abstract class AuthProvider {
  
    Future<void> initialize();

    CustomAuthUser? get currentUser;
    
    Future<CustomAuthUser> login({
      required String email,
      required String password,
    });

    Future<CustomAuthUser> createUser({
      required String email,
      required String password,  
    });
    Future<void> logout();
    Future<bool> isEmailVerified();
    Future<void> resendEmailVerification();
    Future<void> sendPasswordReset({required String toEmail});
    Future<CustomAuthUser> signInWithGoogle();
    Future<CustomAuthUser> signInWithFacebook();
}   
