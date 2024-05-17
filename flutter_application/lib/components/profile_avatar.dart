import 'package:flutter/material.dart';

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
  final String imageUrl;
  final IconButtonConfig? iconButtonConfig;

  const ProfileAvatar({
    Key? key,
    required this.imageUrl,
    this.iconButtonConfig,
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
