import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  final Function()? onTap;
  final String buttonText; 

  const MyButton({Key? key, required this.onTap, required this.buttonText})
      : super(key: key);

  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      onTap: widget.onTap,
      child: Container(
        width: 175,
        height: 50,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 25.0),
        decoration: BoxDecoration(
          color: _isPressed ? const Color.fromARGB(255, 245, 156, 104) : const Color.fromARGB(255,255,92,00),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            widget.buttonText, 
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
