import 'package:flutter/material.dart';

class CheckeredPatternPainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final int rowCount;
  final int columnCount;

  CheckeredPatternPainter({
    required this.color1,
    required this.color2,
    this.rowCount = 6,
    this.columnCount = 16,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rectWidth = size.width / columnCount;
    final rectHeight = size.height / rowCount;
    final paint = Paint();

    for (int row = 0; row < rowCount; row++) {
      for (int col = 0; col < columnCount; col++) {
        if ((row + col) % 2 == 0) {
          paint.color = color1;
        } else {
          paint.color = color2;
        }
        final rect = Rect.fromLTWH(
          col * rectWidth,
          row * rectHeight,
          rectWidth,
          rectHeight,
        );
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CheckeredPatternBackground extends StatelessWidget {
  final Color color1;
  final Color color2;
  final Widget child;

  CheckeredPatternBackground({
    required this.color1,
    required this.color2,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CheckeredPatternPainter(
        color1: color1,
        color2: color2,
      ),
      child: child,
    );
  }
}
