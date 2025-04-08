import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final bool isPassword;

  const CustomTextField({
    super.key,
    required this.labelText,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: labelText,
        filled: true,
        fillColor: const Color(0xFFD9D9D9),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      style: const TextStyle(color: Colors.black),
    );
  }
}
