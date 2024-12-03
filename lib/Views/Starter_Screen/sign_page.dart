import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:samadhan_chat/ErrorHandling/error_translator.dart';
import 'package:samadhan_chat/auth/Bloc/auth_bloc.dart';
import 'package:samadhan_chat/auth/Bloc/auth_event.dart';
import 'package:samadhan_chat/auth/Bloc/auth_state.dart';
import 'package:samadhan_chat/utilities/Dialogs/show_message.dart';
import 'package:samadhan_chat/utilities/Visuals/glassbox.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  String _email = '';
  String _password = '';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateLoggedOut) {
          if (state.exception != null) {
            String message = ErrorTranslator.translate(state.exception!);
            showMessage(
              message: message,
              context: context,
              icon: Icons.error,
              backgroundColor: Colors.red.withOpacity(0.8),
            );
          }
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange.shade300,
                Colors.deepOrange.shade500,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: GlassmorphicContainer(
                  blur: 15,
                  opacity: 0.2,
                  borderRadius: 30,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildLogo(),
                            const SizedBox(height: 24),
                            _buildTitle(),
                            const SizedBox(height: 32),
                            _buildEmailField(),
                            const SizedBox(height: 16),
                            _buildPasswordField(),
                            const SizedBox(height: 24),
                            _buildSignInButton(),
                            _buildForgotPasswordButton(),
                            const SizedBox(height: 24),
                            _buildDivider(),
                            const SizedBox(height: 24),
                            _buildSocialLoginButtons(),
                            const SizedBox(height: 24),
                            _buildRegisterButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(
        Icons.chat_bubble_outline,
        size: 60,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      "Samaddhan Chat",
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.2,
        shadows: [
          Shadow(
            offset: const Offset(2.0, 2.0),
            blurRadius: 3.0,
            color: Colors.black.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email, color: Colors.deepOrange.shade600),
        labelText: 'Email',
        labelStyle: TextStyle(color: Colors.deepOrange.shade800),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
      onSaved: (value) => _email = value ?? '',
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock, color: Colors.deepOrange.shade600),
        labelText: 'Password',
        labelStyle: TextStyle(color: Colors.deepOrange.shade800),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.deepOrange.shade600,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters long';
        }
        return null;
      },
      onSaved: (value) => _password = value ?? '',
    );
  }

  Widget _buildSignInButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepOrange.shade600,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
      ),
      child: const Text('Sign In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: () {
        context.read<AuthBloc>().add(const AuthEventForgotPassword());
      },
      child:const Text(
        'Forgot Password?',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(0.5), thickness: 1)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or sign in with',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.5), thickness: 1)),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton("assets/icons/google.svg", () {
          context.read<AuthBloc>().add(const AuthEventGoogleSignIn());
        }),
        const SizedBox(width: 20),
        _buildSocialButton("assets/icons/facebook.svg", () {
          context.read<AuthBloc>().add(const AuthEventSignInWithFacebook());
        }),
      ],
    );
  }

  Widget _buildSocialButton(String asset, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SvgPicture.asset(
          asset,
          height: 30,
          width: 30,
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return TextButton(
      onPressed: () {
        context.read<AuthBloc>().add(const AuthEventNavigateToRegister());
      },
      child:const Text(
        'New user? Register here!',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      context.read<AuthBloc>().add(AuthEventLogIn(_email, _password));
    }
  }

  // String _getErrorMessage(Exception exception) {
    // if (exception is InvalidCredentialAuthException) {
    //   return 'Invalid credentials';
    // } else if (exception is IllegalArgumentException) {
    //   return 'Invalid argument';
    // } else if (exception is GoogleLoginFailureException) {
    //   return 'Google login failed';
    // } else if (exception is CancelledByUserAuthException) {
    //   return 'Sign-in was cancelled';
    // } else if (exception is FacebookLoginFailureException) {
    //   return 'An error occurred during Facebook sign-in';
    // } else {
    //   return 'An error occurred';
    // }
  // }
}