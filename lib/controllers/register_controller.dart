import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/screens/dashboard.dart';

class RegisterController extends GetxController {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isLoading = false.obs;

  void register() async {
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar("Error", "Password dan Konfirmasi Password tidak sama");
      return;
    }

    try {
      isLoading.value = true;

      UserCredential user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      User? currentUser = user.user;
      if (currentUser != null) {
        await currentUser.updateProfile(displayName: fullNameController.text);
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection("users").doc(user.user?.uid).set({
        "fullName": fullNameController.text,
        "email": emailController.text,
        "phone": phoneController.text,
        "createdAt": DateTime.now(),
      });

      // Get.back(); // Kembali ke login setelah register berhasil
      Get.offAll(() => const DashboardScreen()); // Pindah ke dashboard setelah register berhasil
      Get.snackbar("Success", "Registrasi berhasil.", backgroundColor: Colors.white);
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Registrasi Gagal",
        e.message ?? "Terjadi kesalahan",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
