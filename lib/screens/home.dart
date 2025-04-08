import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home_app/screens/login.dart';
import 'package:smart_home_app/screens/register.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 45), // Wider button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Less rounded corners
                  ),
                ),
                onPressed: () {
                  Get.to(const RegisterScreen());
                },
                child: const Text('Sign Up', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 45), // Wider button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Less rounded corners
                  ),
                ),
                onPressed: () {
                  Get.to(const LoginScreen());
                },
                child: const Text('Login', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
