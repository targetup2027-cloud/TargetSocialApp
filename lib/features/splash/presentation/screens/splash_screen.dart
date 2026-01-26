import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('U-Axis'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/auth'),
              child: const Text('Go to Auth'),
            ),
          ],
        ),
      ),
    );
  }
}
