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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/controllers/backend_service.dart';

class IconButtonConfig {
  final IconData icon;
  final VoidCallback onPressed;
  final bool showIcon;

  IconButtonConfig({
    required this.icon,
    required this.onPressed,
    this.showIcon = true,
  });
}

class ProfileAvatar extends StatelessWidget {
  final ImageProvider image;
  final IconButtonConfig? iconButtonConfig;

  const ProfileAvatar({
    Key? key,
    required this.image,
    this.iconButtonConfig,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        CircleAvatar(
          radius: 70.0,
          foregroundImage: image,
        ),
        if (iconButtonConfig != null && iconButtonConfig!.showIcon)
          Positioned(
            right: -10,
            top: 95,
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(iconButtonConfig!.icon,
                    color: Color.fromARGB(255, 255, 92, 00)),
                onPressed: iconButtonConfig!.onPressed,
              ),
            ),
          ),
      ],
    );
  }
}
