import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_home_app/controllers/settings_controller.dart';
import 'package:smart_home_app/screens/home.dart';
import 'package:smart_home_app/widgets/custom_text_field.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFF1166AA),
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1166AA),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut().then((value) {
                Get.offAll(() => const HomeScreen());
              }).catchError((error) {
                Get.snackbar('Error', error.toString(), backgroundColor: Colors.red, colorText: Colors.white);
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(left: 36.0, right: 36.0, top: 24.0, bottom: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Color(0xFF1166AA), size: 50),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        controller.nameController.text,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                CustomTextField(labelText: 'Nama Pengguna', controller: controller.nameController),
                const SizedBox(height: 24),
                CustomTextField(
                  labelText: 'Email',
                  controller: controller.emailController,
                  isDisabled: true,
                ),
                const SizedBox(height: 24),
                CustomTextField(labelText: 'No Telp', controller: controller.phoneController),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: controller.updateUserData,
                  child: const Text('Simpan'),
                ),
                const SizedBox(height: 48),
                // Password Update Section
                CustomTextField(
                  labelText: 'Password Baru',
                  controller: passwordController,
                  isPassword: true,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  labelText: 'Konfirmasi Password Baru',
                  controller: confirmPasswordController,
                  isPassword: true,
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Colors.white),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    // Check if the passwords match
                    if (passwordController.text == confirmPasswordController.text) {
                      try {
                        // Update password in Firebase
                        User? user = FirebaseAuth.instance.currentUser;
                        await user?.updatePassword(passwordController.text);
                        Get.snackbar(
                          'Success',
                          'Password berhasil diperbarui',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      } catch (error) {
                        Get.snackbar(
                          'Error',
                          error.toString(),
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      } finally {
                        passwordController.clear();
                        confirmPasswordController.clear();
                      }
                    } else {
                      Get.snackbar(
                        'Error',
                        'Password baru dan konfirmasi password tidak cocok',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  child: const Text('Perbarui Password'),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
