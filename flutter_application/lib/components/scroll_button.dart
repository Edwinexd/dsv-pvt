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
