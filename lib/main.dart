import 'package:flutter/material.dart';
import 'package:samadhan_chat/apis/supabase_keys.dart';
import 'package:samadhan_chat/auth/auth_gate.dart';
import 'package:samadhan_chat/screens/home_page.dart';
import 'package:samadhan_chat/screens/login_page.dart';
import 'package:samadhan_chat/themes/light_mode.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: url,
    anonKey: key,
  );
  runApp(const MainApp());
}

final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const AuthGate(),
      theme: lightmode,
    );
  }
}
