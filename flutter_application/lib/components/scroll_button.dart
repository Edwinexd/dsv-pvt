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

class ScrollButton extends StatelessWidget {
  final ScrollController scrollController;
  final bool isVisible;

  ScrollButton({
    required this.scrollController,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: Duration(milliseconds: 300),
        child: Visibility(
          visible: isVisible,
          child: FloatingActionButton(
            onPressed: () {
              scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            child: Icon(Icons.arrow_downward),
          ),
        ),
      ),
    );
  }
}
