import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final bool filled;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const CustomTextField({
    Key? key,
    required this.labelText,
    this.filled = true,
    this.controller,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        fillColor: filled ? Colors.white : null,
        filled: filled,
      ),
    );
  }
}
