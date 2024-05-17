import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/bars.dart';
import 'package:flutter_application/home_page.dart';

class LeaderboardPage extends StatelessWidget {
  final List<LeaderboardEntry> leaderboardEntries;

  LeaderboardPage({required this.leaderboardEntries});

  @override
  Widget build(BuildContext context) {
    leaderboardEntries.sort((a, b) => b.points.compareTo(a.points));

    return Scaffold(
      appBar: buildAppBar(
        context: context,
        title: 'Leaderboard',
        showBackButton: true,
      ),
      body: DefaultBackground(
        child: Column(
          children: [
            Leaderboard(leaderboardEntries: leaderboardEntries, showMoreButton: false, showCrown: true),
            Expanded(
              child: ListView.builder(
                itemCount: leaderboardEntries.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Text('${index + 1}'),
                    title: Text(leaderboardEntries[index].name),
                    trailing:
                        Text('${leaderboardEntries[index].points} points'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        context: context,
      ),
    );
  }
}
