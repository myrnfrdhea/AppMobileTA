import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IconWithLabels extends StatelessWidget {
  final String underIconLabel;

  const IconWithLabels({super.key, required this.underIconLabel});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Smart\nHome',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontFamily: GoogleFonts.inriaSans().fontFamily,
          ),
        ),
        const SizedBox(height: 12),
        Image.asset(
          "assets/images/logo_icon.png",
          scale: 0.9,
        ),
        const SizedBox(height: 16),
        Text(
          underIconLabel,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
