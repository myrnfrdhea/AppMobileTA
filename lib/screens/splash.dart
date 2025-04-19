import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1166AA),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Smart',
            style: TextStyle(
              fontSize: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Image.asset(
            'assets/images/logo_icon.png',
            scale: 0.7,
          ),
          const SizedBox(height: 8),
          const Text(
            'Home',
            style: TextStyle(
              fontSize: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.onPrimary,
            strokeWidth: 5,
          ),
        ],
      )),
    );
  }
}
