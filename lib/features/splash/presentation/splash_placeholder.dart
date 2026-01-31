import 'package:flutter/material.dart';

import '../../../app/theme/uaxis_theme.dart';

class SplashPlaceholder extends StatelessWidget {
  const SplashPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: UAxisColors.backgroundBase,
      body: Center(
        child: Text(
          'U-Axis',
          style: TextStyle(
            color: UAxisColors.discoverPremium,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
