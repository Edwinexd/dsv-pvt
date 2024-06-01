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

class SkillLevelSlider extends StatefulWidget {
  final int initialSkillLevel;
  final Function(int)? onSkillLevelChanged;
  final bool isSliderLocked;

  const SkillLevelSlider({
    super.key,
    this.initialSkillLevel = 0,
    this.onSkillLevelChanged,
    this.isSliderLocked = false,
  });

  @override
  SkillLevelSliderState createState() => SkillLevelSliderState();
}

class SkillLevelSliderState extends State<SkillLevelSlider> {
  late int _skillLevel;
  final List<String> skillLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert',
    'Master'
  ];

  @override
  void initState() {
    super.initState();
    _skillLevel = widget.initialSkillLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          width: 400,
          child: AbsorbPointer(
            absorbing: widget.isSliderLocked,
            child: Slider(
              value: _skillLevel.toDouble(),
              min: 0,
              max: 4,
              divisions: 4,
              label: skillLevels[_skillLevel],
              onChanged: (double value) {
                setState(() {
                  _skillLevel = value.round();
                  if (widget.onSkillLevelChanged != null) {
                    widget.onSkillLevelChanged!(_skillLevel);
                  }
                });
              },
              activeColor: const Color.fromARGB(255, 255, 92, 00),
              inactiveColor: const Color.fromARGB(255, 206, 150, 118),
            ),
          ),
        ),
        Text(skillLevels[_skillLevel], style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
