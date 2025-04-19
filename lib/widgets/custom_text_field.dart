import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String labelText;
  final bool isPassword;
  final TextEditingController? controller;
  final bool isDisabled;

  const CustomTextField({
    super.key,
    required this.labelText,
    this.isPassword = false,
    this.controller,
    this.isDisabled = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final Color fieldColor = widget.isDisabled ? const Color(0xFFB0B0B0) : const Color(0xFFD9D9D9);

    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: widget.isPassword ? TextInputType.visiblePassword : TextInputType.emailAddress,
      enabled: !widget.isDisabled,
      decoration: InputDecoration(
        hintText: widget.labelText,
        filled: true,
        fillColor: fieldColor,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: fieldColor),
          borderRadius: BorderRadius.circular(16),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: fieldColor),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: fieldColor),
          borderRadius: BorderRadius.circular(16),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[700],
                ),
                onPressed: widget.isDisabled
                    ? null
                    : () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
              )
            : null,
      ),
      style: const TextStyle(color: Colors.black),
    );
  }
}
