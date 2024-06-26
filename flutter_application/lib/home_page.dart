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
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_application/controllers/backend_service_interface.dart';
import 'package:flutter_application/leaderboard_page.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/bars.dart';
import 'package:flutter_application/challenges_page.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/controllers/health.dart';
import 'package:flutter_application/midnattsloppet_activity_page.dart';
import 'package:flutter_application/models/group.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  final BackendServiceInterface backendService;

  HomePage({
    Key? key,
    BackendServiceInterface? backendService,
  })  : backendService = backendService ?? BackendService(),
        super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Group> _leaderboardGroups = [];

  @override
  void initState() {
    super.initState();
    unawaited(collectAndSendData());
    unawaited(widget.backendService
        .getGroups(0, 3, GroupOrderType.POINTS, true)
        .then((groups) {
      setState(() {
        _leaderboardGroups = groups;
      });
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: 'Lace up & lead the way',
        context: context,
        showBackButton: false,
      ),
      body: DefaultBackground(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CustomPaint(
                  painter: SemicirclesPainter(),
                  child: Column(
                    children: [
                      CountdownWidget(),
                      SignupButton(),
                    ],
                  ),
                ),
                ActivityButton(),
                ChallengesButton(),
                Leaderboard(
                  leaderboardEntries: _leaderboardGroups,
                ),
                MoreButton(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        context: context,
      ),
    );
  }
}

class CountdownWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final raceDate = DateTime(2024, 8, 17);
    final currentDate = DateTime.now();
    final difference = raceDate.difference(currentDate).inDays;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 20,
          ),
          children: <TextSpan>[
            TextSpan(text: '$difference DAYS TO\n'),
            TextSpan(text: 'MIDNATTSLOPPET'),
          ],
        ),
      ),
    );
  }
}

class SignupButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 90.0),
      child: Container(
        width: 200,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            minimumSize: Size(30, 40),
          ),
          onPressed: () async {
            const url = 'https://midnattsloppet.com/midnattsloppet-stockholm/';
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
          },
          child: const Text(
            'Sign up for race',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class SemicirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color.fromARGB(255, 255, 255, 255);
    final leftSemicircle = Rect.fromLTRB(
        0, -size.height * 1.25, size.width * 0.75, size.height * 1.1);
    final rightSemicircle = Rect.fromLTRB(size.width * 0.15,
        -size.height * 1.35, size.width * 1.15, size.height * 1.2);

    canvas.drawArc(leftSemicircle, 0, math.pi, false, paint);
    canvas.drawArc(rightSemicircle, 0, math.pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ActivityButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Color(0xFF8134CE),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: Size(327, 80),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MidnatsloppetActivity()),
          );
        },
        child: const SizedBox(
          width: 327,
          child: Text(
            'Special activity \nfrom midnattsloppet!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class ChallengesButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, bottom: 50),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Color(0xFF8134CE),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: Size(327, 180),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChallengesPage()),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 327,
              child: Text(
                'Challenges',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 2,
                ),
              ),
            ),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFF8134CE), width: 5),
              ),
              child: ClipOval(
                child: Image.asset(
                  'lib/images/challenge.jpg',
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Leaderboard extends StatelessWidget {
  final List<Group> leaderboardEntries;
  final bool showCrown;

  Leaderboard({
    required this.leaderboardEntries,
    this.showCrown = false,
  });

  @override
  Widget build(BuildContext context) {
    leaderboardEntries.sort((a, b) => b.points.compareTo(a.points));
    List<Group> topThree = leaderboardEntries.take(3).toList();

    if (topThree.length >= 3) {
      var temp = topThree[1];
      topThree[1] = topThree[0];
      topThree[0] = topThree[2];
      topThree[2] = temp;
    }

    int highestScoreIndex = 0;
    for (int i = 1; i < topThree.length; i++) {
      if (topThree[i].points > topThree[highestScoreIndex].points) {
        highestScoreIndex = i;
      }
    }

    final maxPoints = topThree.isNotEmpty
        ? topThree.map((group) => group.points).reduce(math.max)
        : 1;
    final maxHeight = 200.0;

    return Container(
      width: 327,
      height: 300,
      padding: const EdgeInsets.only(top: 15),
      child: Stack(
        children: [
          const Positioned(
            top: -10,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Leaderboard',
                style: TextStyle(
                  color: Color(0xFF8134CE),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: topThree.asMap().entries.map((entry) {
                final barHeight = (entry.value.points / maxPoints) * maxHeight;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 80,
                      margin: EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            entry.value.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (showCrown && entry.key == highestScoreIndex)
                      Icon(Icons.rocket_launch,
                          color: Colors.yellow, size: 24.0),
                    Container(
                      width: 75,
                      height: barHeight,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF9087E5),
                            Color(0xFFCDC9F3),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${entry.value.points} points',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class MoreButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: EdgeInsets.only(bottom: 15),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFF344F7),
            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LeaderboardPage()),
            );
          },
          child: const Text(
            'Show More',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
