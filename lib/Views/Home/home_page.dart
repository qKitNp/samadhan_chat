import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samadhan_chat/auth/Bloc/auth_bloc.dart';
import 'package:samadhan_chat/auth/Bloc/auth_event.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child:Column(
          children: [
            const Text('Home Page'),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthEventLogOut());
              }, 
              child:const Text('Logout'),
            ),
          ],
        ),
    ))
    ;
  }
}