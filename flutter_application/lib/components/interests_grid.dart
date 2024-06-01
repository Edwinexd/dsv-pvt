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
