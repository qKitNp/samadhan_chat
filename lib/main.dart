import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:samadhan_chat/Views/Home/home_page.dart';
import 'package:samadhan_chat/Views/Starter_Screen/email_verification.dart';
import 'package:samadhan_chat/Views/Starter_Screen/forgot_password_view.dart';
import 'package:samadhan_chat/Views/Starter_Screen/onboarding_screen.dart';
import 'package:samadhan_chat/Views/Starter_Screen/register_page.dart';
import 'package:samadhan_chat/Views/Starter_Screen/sign_page.dart';
import 'package:samadhan_chat/auth/Bloc/auth_bloc.dart';
import 'package:samadhan_chat/auth/Bloc/auth_event.dart';
import 'package:samadhan_chat/auth/Bloc/auth_state.dart';
import 'package:samadhan_chat/auth/supabase_authProvider.dart';
import 'package:samadhan_chat/chat/chat_bloc/chat_bloc.dart';
import 'package:samadhan_chat/chat/chat_cache_manager.dart';
import 'package:samadhan_chat/chat/chat_repository.dart';
import 'package:samadhan_chat/chat/gemini/gemini_service.dart';
import 'package:samadhan_chat/themes/light_mode.dart';
import 'package:samadhan_chat/utilities/Loading/loading_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final prefs = await SharedPreferences.getInstance();

   _setupLogging();
  runApp(
    MultiBlocProvider(
      providers:[ 
        BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(
          SupabaseAuthProvider(),
        )..add(const AuthEventInitialise()),
        ),
        BlocProvider<ChatBloc>(
          create: (context) => ChatBloc(
            ChatRepository(), 
            GeminiService(),
            ChatCacheService(prefs),
          )
          ),
      ],
      child: const MainApp(),
    ),
  );
}

void _setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S Chat',
      theme: lightmode,
      home: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.isLoading) {
            LoadingScreen().show(
              context: context,
              text: state.loadingText ?? 'Please wait a moment',
            );
          } else {
            LoadingScreen().hide();
          }
        },
        builder: (context, state) => _buildHome(state),
      ),
      routes: const {
        // Add routes here
      },
    );
  }
  
  Widget _buildHome(AuthState state) {
     if (state is AuthStateRegistering) {
      return const RegisterView();
    } else if (state is AuthStateLoggedIn) {
      print(state.user.email);
      print(state.user.isEmailVerified);
      return state.user.isEmailVerified ? const ChatScreen() : const EmailVerification();
    } else if (state is AuthStateNeedsVerification) {
      return const EmailVerification();
    } else if (state is AuthStateForgotPassword) {
      return const ForgotPasswordView();
    } else if (state is AuthStateLoggedOut) {
      switch (state.intendedView) {
        case AuthView.signIn:
          return const SignInView();
        case AuthView.register:
          return const RegisterView();
        case AuthView.onboarding:
        default:
          return const OnboardingScreenView();
      }
    } else if (state is AuthStateRegistering) {
      return const RegisterView();
    } else {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}