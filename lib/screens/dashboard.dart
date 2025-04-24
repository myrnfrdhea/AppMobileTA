import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_home/screens/activities.dart';
import 'package:smart_home/screens/live_camera.dart';
import 'package:smart_home/screens/settings.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1166AA),
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset("assets/images/logo_icon.png", scale: 1.2, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Smart\nHome',
              style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: GoogleFonts.inriaSans().fontFamily),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Get.to(const SettingsScreen());
            },
          ),
        ],
        backgroundColor: const Color(0xFF1166AA),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Get.to(const LiveCameraScreen());
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 100),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Less rounded corners
                  ),
                ),
                child: const Icon(Icons.camera_alt_rounded, size: 36),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Get.to(const ActivityScreen());
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 100),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Less rounded corners
                  ),
                ),
                child: const Icon(Icons.calendar_month_sharp, size: 36),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
