import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  var isLoading = true.obs;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> updateUserData() async {
    try {
      isLoading.value = true;
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(nameController.text);
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'fullName': nameController.text,
          'phone': phoneController.text,
        });
        await user.reload();

        Get.snackbar(
          'Success',
          'Data pengguna berhasil diperbarui',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Pengguna tidak ditemukan',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (error) {
      Get.snackbar(
        'Error',
        error.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void fetchUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      isLoading.value = true;
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        nameController.text = doc['fullName'] ?? '';
        emailController.text = doc['email'] ?? '';
        phoneController.text = doc['phone'] ?? '';
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat data pengguna");
    } finally {
      isLoading.value = false;
    }
  }
}
