import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/challenges_page.dart';
import 'package:flutter_application/midnattsloppet_activity_page.dart';
import 'package:flutter_application/views/leaderboard.dart';
import 'package:url_launcher/url_launcher.dart';


class HomePage extends StatelessWidget {

   // Temporary sample data for leaderboard entries
  final List<LeaderboardEntry> _leaderboardEntries = [
    LeaderboardEntry('Player 1', 30, 2),
    LeaderboardEntry('Player 2', 90, 3),
    LeaderboardEntry('Player 3', 40, 1),
  ];
  @override
  Widget build(BuildContext context) {
    return DefaultBackground(
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
              Leaderboard(_leaderboardEntries),
            ],
          ),
        ),
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
    final paint = Paint()..color = Colors.white;
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
          foregroundColor: Color(0xFF8134CE), backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: Size(327, 80),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MidnattsloppetActivityPage()),
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
      padding: const EdgeInsets.only(top: 30.0, bottom: 30),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Color(0xFF8134CE), backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: Size(327, 180), // Double the height
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

