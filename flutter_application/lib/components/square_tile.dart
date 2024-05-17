import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;

  const SquareTile({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      height: 60,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        //border: Border.all(
        //color: Colors.white
        //),
        borderRadius: BorderRadius.circular(25),
        color: Colors.grey[200],
      ),
      child: Image.asset(
        imagePath,
        height: 40,
      ),
    );
  }
}
