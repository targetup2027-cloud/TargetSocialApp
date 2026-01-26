import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/home'),
          child: const Text('Login'),
        ),
      ),
    );
  }
}
