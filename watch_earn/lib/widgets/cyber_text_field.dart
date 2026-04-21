import 'package:flutter/material.dart';

class CyberTextField extends StatelessWidget {

  final TextEditingController controller;

  final IconData icon;

  final String label;

  final String? hint;

  final int maxLines;

  final TextInputType keyboardType;

  final String? Function(String?)? validator;

  final bool obscureText;

  const CyberTextField({

    super.key,

    required this.controller,

    required this.icon,

    required this.label,

    this.hint,

    this.maxLines = 1,

    this.keyboardType = TextInputType.text,

    this.validator,

    this.obscureText = false,

  });

  @override

  Widget build(BuildContext context) {

    return Container(

      decoration: BoxDecoration(

        border: Border.all(color: const Color(0xFF00F0FF)),

        borderRadius: BorderRadius.circular(12),

      ),

      child: TextFormField(

        controller: controller,

        maxLines: maxLines,

        obscureText: obscureText,

        keyboardType: keyboardType,

        style: const TextStyle(color: Colors.white),

        decoration: InputDecoration(

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

          prefixIcon: Icon(icon, color: const Color(0xFF00F0FF)),

          labelText: label,

          labelStyle: const TextStyle(color: Color(0xFF00F0FF), fontSize: 12),

          hintText: hint,

          hintStyle: const TextStyle(color: Colors.white38),

        ),

        validator: validator,

      ),

    );

  }

}