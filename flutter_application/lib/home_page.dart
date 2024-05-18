import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_application/LeaderboardPage.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/bars.dart';
import 'package:flutter_application/challenges_page.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/controllers/health.dart';
import 'package:flutter_application/midnattsloppet_activity_page.dart';
import 'package:flutter_application/models/group.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Temporary sample data for leaderboard entries can be changed to real data
  List<Group> _leaderboardGroups = [];

  @override
  void initState() {
    super.initState();
    unawaited(collectAndSendData());
    unawaited(BackendService().getGroups(0, 3).then((groups) {
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
      padding: const EdgeInsets.symmetric(horizontal: 140.0),
      child: Container(
        width: double.infinity,
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
  final bool showMoreButton;
  final bool showCrown;

  Leaderboard(
      {required this.leaderboardEntries,
      this.showMoreButton = true,
      this.showCrown = false});

  @override
  Widget build(BuildContext context) {
    leaderboardEntries.sort((a, b) => b.points.compareTo(a.points));

    if (leaderboardEntries.length >= 3) {
      var temp = leaderboardEntries[1];
      leaderboardEntries[1] = leaderboardEntries[0];
      leaderboardEntries[0] = leaderboardEntries[2];
      leaderboardEntries[2] = temp;
    }

    int highestScoreIndex = 0;
    for (int i = 1; i < leaderboardEntries.length; i++) {
      if (leaderboardEntries[i].points >
          leaderboardEntries[highestScoreIndex].points) {
        highestScoreIndex = i;
      }
    }

    return Container(
      width: 327,
      height: 370,
      padding: const EdgeInsets.all(10),
      child: Stack(
        children: [
          if (showMoreButton)
            Positioned(
              bottom: -20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  margin: EdgeInsets.all(20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFFF344F7),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 90, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: const BorderSide(color: Colors.white, width: 30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LeaderboardPage()),
                      );
                    },
                    child: const Text(
                      'More',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
          ...leaderboardEntries.asMap().entries.map((entry) {
            return Positioned(
              bottom: 50,
              left: (entry.key * 100).toDouble(),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                      color: Color(0xFF9087E5),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        entry.value.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  if (showCrown && entry.key == highestScoreIndex)
                    Icon(Icons.rocket_launch, color: Colors.yellow, size: 24.0),
                  Container(
                    width: 100,
                    height: entry.value.points * 2,
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
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: Color(0xFF9087E5),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        '${entry.value.points} points',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
