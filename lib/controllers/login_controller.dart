import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home_app/screens/dashboard.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firebaseAuth = FirebaseAuth.instance;

  var isLoading = false.obs;

  void login() async {
    isLoading.value = true;

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Login Failed',
        'Please fill in all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
      );
      isLoading.value = false;
      return;
    }
    // Future.delayed(const Duration(seconds: 2));

    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Get.offAll(const DashboardScreen());
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Login Failed',
        e.message ?? 'Unknown error',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
      );
    }

    isLoading.value = false;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
