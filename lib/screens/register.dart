import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_home_app/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1166AA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'SMART\nHOME',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
                Image.asset(
                  "assets/images/logo_icon.png",
                  scale: 1,
                ),
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: GoogleFonts.inriaSans().fontFamily,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      const CustomTextField(labelText: 'Nama Lengkap'),
                      const SizedBox(height: 24),
                      const CustomTextField(labelText: 'Email'),
                      const SizedBox(height: 24),
                      const CustomTextField(labelText: 'No Telp'),
                      const SizedBox(height: 24),
                      const CustomTextField(labelText: 'Password', isPassword: true),
                      const SizedBox(height: 24),
                      const CustomTextField(labelText: 'Konfirmasi Password', isPassword: true),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // Less rounded corners
                          ),
                        ),
                        onPressed: () {
                          // Handle register action
                        },
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
