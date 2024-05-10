import 'package:flutter/material.dart';

class InterestsGrid extends StatefulWidget {
  final Map<String, bool> interests;
  final Function(String, bool) onInterestChanged;

  const InterestsGrid({
    Key? key,
    required this.interests,
    required this.onInterestChanged,
  }) : super(key: key);

  @override
  _InterestsGridState createState() => _InterestsGridState();
}

class _InterestsGridState extends State<InterestsGrid> {
  Widget buildInterestCheckbox(String interest) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          value: widget.interests[interest],
          onChanged: (bool? newValue) {
            widget.onInterestChanged(interest, newValue ?? false);
          },
        ),
        Text(interest),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      shrinkWrap: true,
      crossAxisCount: 2, // No. of boxes per row
      childAspectRatio: 4, // space vertically
      crossAxisSpacing: 8,
      mainAxisSpacing: 2,
      physics: NeverScrollableScrollPhysics(),
      children: widget.interests.keys.map((String key) {
        return buildInterestCheckbox(key);
      }).toList(),
    );
  }
}
