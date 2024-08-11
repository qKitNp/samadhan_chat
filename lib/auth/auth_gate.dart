import 'package:flutter/material.dart';
import 'package:samadhan_chat/main.dart';
import 'package:samadhan_chat/screens/home_page.dart';
import 'package:samadhan_chat/screens/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            stream: supabase.auth.onAuthStateChange,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data?.session != null) {
                print("Snapshot email: ${snapshot.data?.session?.user.email}");
                return const HomePage();
              } else {
                print("Snapshot data: ${snapshot.data?.event.toString()}");
                return LoginPage();
              }
            }));
  }
}
