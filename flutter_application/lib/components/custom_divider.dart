import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final Color color;
  final double thickness;
  final double height;

  const CustomDivider({
    Key? key,
    this.color = const Color.fromARGB(255, 16, 14, 99),
    this.thickness = 0.5,
    this.height = 20.0, // Default space around divider
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height / 2),
      child: Divider(
        color: color,
        thickness: thickness,
      ),
    );
  }
}
