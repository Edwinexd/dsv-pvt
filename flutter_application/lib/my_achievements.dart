import 'package:flutter_application/achievement.dart';

import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';

// should this be stateful?
class MyAchievements extends StatefulWidget {
  MyAchievements({super.key});

  @override
  State<MyAchievements> createState() => _MyAchievementsState();
}

class _MyAchievementsState extends State<MyAchievements> {
  // Placeholder, create a widget that takes an achivement and creates a card (returns a widget)
  final List<Achievement> trophies = [
    Achievement(
      icon: Icons.star,
      header: 'Walked 10 km',
      description: 'You walked 10 km!',
    ),
    Achievement(
      icon: Icons.star_border,
      header: 'Run 5 km',
      description: 'You ran 5 km!',
    ),
    Achievement(
      icon: Icons.star_half,
      header: 'Added a friend',
      description: 'You added a friend',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Achievements'),
        centerTitle: true,
      ),
      // add header here, trophys
      body: DefaultBackground(
        child: ListView.builder(
          itemCount: trophies.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: AchievementCard(
                achievement: trophies[index],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Creates an achievement card - where to place it?
class AchievementCard extends StatelessWidget {
  final Achievement achievement;

  AchievementCard({
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: <Widget>[
          Icon(achievement.icon),
          const SizedBox(width: 10.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                achievement.header,
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                achievement.description,
                style: const TextStyle(
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
