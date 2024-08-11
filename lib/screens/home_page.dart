import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:samadhan_chat/main.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        title: const Text("S Chat"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Spacer(),
            ElevatedButton(
                onPressed: () async {
                  await supabase.auth.signOut();
                },
                child: Text("Sign out")),
            Padding(
              padding: EdgeInsets.all(24.0),
              child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(100)))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
