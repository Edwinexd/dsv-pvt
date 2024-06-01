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

  @override
  Widget build(BuildContext context) {
    return DefaultBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('My Achievements'),
          backgroundColor: Colors.transparent,
          centerTitle: true,
          elevation: 0.0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        // add header here, trophys
        body: ListView.builder(
          itemCount: allAchievements.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: AchievementCard(
                achievement: allAchievements[index],
                completed: grantedAchievements
                    .map((e) => e.id)
                    .contains(allAchievements[index].id),
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
  final bool completed;

  const AchievementCard({super.key, required this.achievement, required this.completed});

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
        if (!widget.completed) {
          return;
        }
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
                    String userId = (await BackendService().getMe()).id;
                    XFile shareImage = await BackendService().getAchievementShareImage(userId, widget.achievement.id);
                    Share.shareXFiles([shareImage]);
                    Navigator.of(context).pop(); // Close dialog
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
          Container(
            width: 75.0,
            height: 75.0,
            decoration: image != null
                ? BoxDecoration(
                    image: DecorationImage(image: image!),
                  )
                : null,
            child: const SizedBox(width: 75.0, height: 75.0),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
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
                  softWrap: true,
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              widget.completed
                  ? Icon(Icons.lock_open, color: Colors.green[300])
                  : Icon(Icons.lock, color: Colors.red[300]),
            ],
          ),
          const SizedBox(width: 10.0), // Add margin to the right of the element
        ],
      ),
    ),


    );
  }
}
