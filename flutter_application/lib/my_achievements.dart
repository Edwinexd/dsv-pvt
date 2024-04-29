import 'package:flutter_application/achievement.dart';

import 'package:flutter/material.dart';

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
      header: 'Promenerat 10 km',
      description: 'Du har promenerat 10 km!',
    ),
    Achievement(
      icon: Icons.star_border,
      header: 'Sprungit 5 km',
      description: 'Du har sprungit 5 km!',
    ),
    Achievement(
      icon: Icons.star_half,
      header: 'Lagt till en vän',
      description: 'Du har lagt till en vän!',
    ),
  ];

  @override
  Widget build(BuildContext context) {    

    return Scaffold(
      //appBar: AppBar(
        //title: Text('Mina Troféer'),
        //centerTitle: true,
      //),
      // add header here, trophys
      body: ListView.builder(
        itemCount: trophies.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: AchievementCard(
              achievement: trophies[index],
            ),
          );
        },
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
          SizedBox(width: 10.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(achievement.header),
              Text(achievement.description),
            ],
          ),
        ],
      ),
    );    
  }
}

