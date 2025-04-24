import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_home/controllers/register_controller.dart';
import 'package:smart_home/widgets/custom_text_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegisterController());

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
                Image.asset("assets/images/logo_icon.png", scale: 1),
                Text(
                  'Create Account',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: GoogleFonts.inriaSans().fontFamily),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      CustomTextField(labelText: 'Nama Lengkap', controller: controller.fullNameController),
                      const SizedBox(height: 24),
                      CustomTextField(labelText: 'Email', controller: controller.emailController),
                      const SizedBox(height: 24),
                      CustomTextField(labelText: 'No Telp', controller: controller.phoneController),
                      const SizedBox(height: 24),
                      CustomTextField(
                        labelText: 'Password',
                        isPassword: true,
                        controller: controller.passwordController,
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        labelText: 'Konfirmasi Password',
                        isPassword: true,
                        controller: controller.confirmPasswordController,
                      ),
                      const SizedBox(height: 24),
                      Obx(
                        () => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: controller.isLoading.value ? null : controller.register,
                          child:
                              controller.isLoading.value
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Register'),
                        ),
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
