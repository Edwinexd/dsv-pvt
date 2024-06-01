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

class DefaultBackground extends StatelessWidget {
  final Widget? child;
  final List<Widget>? children;

  DefaultBackground({this.child, this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFABABFC),
            Color(0xFFAA6CFC),
            Color(0xFFEEACFF),
            Color(0xFFFDFDFF),
          ],
        ),
      ),
      child: child ?? (children != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children!,
                )
              : null),
    );
  }
}
