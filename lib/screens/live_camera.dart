import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home_app/widgets/icon_with_labels.dart';

class LiveCameraScreen extends StatelessWidget {
  const LiveCameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1166AA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1166AA),
        title: const Text('Live Camera'),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const IconWithLabels(underIconLabel: 'Siaran Langsung Kamera'),
            const SizedBox(height: 64),
            Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.videocam,
                  color: Colors.white,
                  size: 64,
                ),
              ),
            ),
            const SizedBox(height: 64),
            ElevatedButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}
