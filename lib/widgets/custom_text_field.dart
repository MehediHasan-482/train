// ignore_for_file: deprecated_member_use, use_super_parameters

import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.validator,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 13,
        ),
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.3),
          fontSize: 13,
        ),
        prefixIcon: Icon(widget.icon, color: const Color(0xFF6C63FF), size: 20),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white.withOpacity(0.5),
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF6584), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF6584), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF6584)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
