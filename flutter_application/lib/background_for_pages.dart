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
