import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String buttonText;
  final Function() onTap;

  const GradientButton({Key? key, required this.buttonText, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,  // Set width to fit your layout or use MediaQuery for responsiveness
        height: 48,  // Set height to fit your design
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFA840C8),  // Start color of the gradient
              Color(0xFFF344F7)   // End color of the gradient
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),  // Adjust radius to match your design
        ),
        child: Center(
          child: Text(
            buttonText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
