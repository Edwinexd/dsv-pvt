/*
Lace Up & Lead The Way - A pre-race training app and social platform for runners.
Copyright (C) 2024 Group 71 (PVT 7.5) Stockholm University

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
*/
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
