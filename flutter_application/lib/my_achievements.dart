import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/models/achievement.dart';
import 'package:share_plus/share_plus.dart';

class MyAchievements extends StatefulWidget {
  MyAchievements({super.key});

  @override
  State<MyAchievements> createState() => _MyAchievementsState();
}

class _MyAchievementsState extends State<MyAchievements> {
  List<Achievement> allAchievements = [];
  List<Achievement> grantedAchievements = [];

  Future<void> _populateGrantedAchievements() async {
    String id = (await BackendService().getMe()).id;
    List<Achievement> achievements =
        await BackendService().getUserAchievements(id);
    setState(() {
      grantedAchievements = achievements;
    });
  }

  @override
  void initState() {
    super.initState();
    unawaited(BackendService().getAchievements(0, 100).then((achievements) {
      setState(() {
        allAchievements = achievements;
      });
    }));
    unawaited(_populateGrantedAchievements());
  }

  // TODO: There isnt any indication of completion
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
          itemCount: allAchievements.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: AchievementCard(
                achievement: allAchievements[index],
              ),
            );
          },
        ),
      ),
    );
  }
}

class AchievementCard extends StatefulWidget {
  final Achievement achievement;

  const AchievementCard({super.key, required this.achievement});

  @override
  State<AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<AchievementCard> {
  ImageProvider? image;

  @override
  void initState() {
    super.initState();
    unawaited(BackendService()
        .getImage(widget.achievement.imageId ?? "404")
        .then((value) {
      setState(() {
        image = value;
      });
    }));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Show popup dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(widget.achievement.achievementName),
              content: Text(widget.achievement.description),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed: () async {
                    // TODO: Connect to getShareImage
                    Share.share(
                        '${widget.achievement.achievementName}: ${widget.achievement.description}');
                  },
                  child: const Text('Share'),
                ),
              ],
            );
          },
        );
      },
      child: Card(
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 60,
              backgroundImage: image,
            ),
            const SizedBox(width: 10.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.achievement.achievementName,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.achievement.description,
                  style: const TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
