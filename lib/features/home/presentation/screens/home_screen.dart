import 'package:flutter/material.dart';
import '../../../../app/theme/theme_extensions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text('Home', style: TextStyle(color: context.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.onSurface),
      ),
      body: Center(
        child: Text(
          'Welcome to U-Axis',
          style: TextStyle(color: context.onSurface, fontSize: 20),
        ),
      ),
    );
  }
}
