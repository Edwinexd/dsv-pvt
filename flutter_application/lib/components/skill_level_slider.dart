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
