import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool showIcon;

  const ProfileAvatar({
    Key? key,
    required this.imageUrl,
    this.icon,
    this.onPressed,
    this.showIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        CircleAvatar(
          radius: 70.0,
          backgroundImage: NetworkImage(imageUrl),
        ),
        if (showIcon && icon != null && onPressed != null)
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
                icon: Icon(icon, color: Color.fromARGB(255, 255, 92, 0)),
                onPressed: onPressed,
              ),
            ),
          ),
      ],
    );
  }
}
