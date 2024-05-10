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
              LeaderboardStat(),
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
          foregroundColor: Color(0xFF8134CE), backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
          foregroundColor: Color(0xFF8134CE), backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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

class LeaderboardStat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 379,
          height: 356,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 379,
                  height: 356,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 379,
                          height: 356,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 63.65,
                                top: 17,
                                child: SizedBox(
                                  width: 315.35,
                                  child: Text(
                                    'Leaderboard',
                                    style: TextStyle(
                                      color: Color(0xFF8134CE),
                                      fontSize: 32,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      height: 0.04,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 217.58,
                                top: 181.71,
                                child: Container(
                                  width: 97.77,
                                  height: 147.29,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        child: Container(
                                          width: 97.77,
                                          height: 147.29,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 13.09,
                                                child: Container(
                                                  width: 97.77,
                                                  height: 134.20,
                                                  decoration: BoxDecoration(color: Color(0xFF9087E5)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 30.08,
                                        top: 13.09,
                                        child: SizedBox(
                                          width: 36.66,
                                          height: 68.74,
                                          child: Text(
                                            '3',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 60,
                                              fontFamily: 'Graphik',
                                              fontWeight: FontWeight.w600,
                                              height: 0.02,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 222.28,
                                top: 118.13,
                                child: Container(
                                  width: 87.43,
                                  height: 59.43,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 7.52,
                                        top: 25.43,
                                        child: Container(
                                          width: 55,
                                          height: 34,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: ShapeDecoration(
                                            color: Color(0xFF9087E5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                '500p',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontFamily: 'Rubik',
                                                  fontWeight: FontWeight.w500,
                                                  height: 0.12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        child: SizedBox(
                                          width: 87.43,
                                          height: 21.80,
                                          child: Text(
                                            'Täby',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontFamily: 'Rubik',
                                              fontWeight: FontWeight.w500,
                                              height: 0.09,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8.68,
                        top: 87.76,
                        child: Container(
                          width: 112.83,
                          height: 228.37,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 7.72,
                                top: 64.88,
                                child: Container(
                                  width: 97.77,
                                  height: 163.49,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        child: Container(
                                          width: 97.77,
                                          height: 163.49,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: -0,
                                                top: 14.53,
                                                child: Container(
                                                  width: 97.77,
                                                  height: 148.96,
                                                  decoration: BoxDecoration(color: Color(0xFF9087E5)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 26.32,
                                        top: 14.53,
                                        child: SizedBox(
                                          width: 45.13,
                                          height: 101.73,
                                          child: Text(
                                            '2',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 80,
                                              fontFamily: 'Graphik',
                                              fontWeight: FontWeight.w600,
                                              height: 0.02,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 112.83,
                                  height: 60.74,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        child: SizedBox(
                                          width: 112.83,
                                          height: 27.76,
                                          child: Text(
                                            'Midnattsloppet',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontFamily: 'Rubik',
                                              fontWeight: FontWeight.w500,
                                              height: 0.11,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 21.82,
                                        top: 26.74,
                                        child: Container(
                                          width: 55,
                                          height: 34,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: ShapeDecoration(
                                            color: Color(0xFF9087E5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                '890p',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontFamily: 'Rubik',
                                                  fontWeight: FontWeight.w500,
                                                  height: 0.12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 106.08,
                        top: 60,
                        child: Container(
                          width: 119.58,
                          height: 262.30,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 8.08,
                                top: 63.58,
                                child: Container(
                                  width: 103.41,
                                  height: 198.72,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        child: Container(
                                          width: 103.41,
                                          height: 198.72,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: -0,
                                                top: 12.14,
                                                child: Container(
                                                  width: 103.41,
                                                  height: 186.58,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment(0.00, -1.00),
                                                      end: Alignment(0, 1),
                                                      colors: [Color(0xFF9087E5), Color(0xFFCDC9F3)],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 31.02,
                                        top: 12.14,
                                        child: SizedBox(
                                          width: 41.37,
                                          height: 106.19,
                                          child: Text(
                                            '1',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 100,
                                              fontFamily: 'Graphik',
                                              fontWeight: FontWeight.w600,
                                              height: 0.01,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 119.58,
                                  height: 59.43,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        child: SizedBox(
                                          width: 119.58,
                                          height: 19.15,
                                          child: Text(
                                            ' Kista runners',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontFamily: 'Rubik',
                                              fontWeight: FontWeight.w500,
                                              height: 0.09,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 23.13,
                                        top: 25.43,
                                        child: Container(
                                          width: 61,
                                          height: 34,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: ShapeDecoration(
                                            color: Color(0xFF9087E5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                '1000p',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontFamily: 'Rubik',
                                                  fontWeight: FontWeight.w500,
                                                  height: 0.12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 11.57,
                top: 274,
                child: Container(
                  width: 303.78,
                  height: 72,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 42.43,
                top: 289,
                child: Container(
                  width: 254.60,
                  height: 43,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.70, 0.71),
                      end: Alignment(-0.7, -0.71),
                      colors: [Color(0xFF9B3FBF), Color(0xFFF243F6)],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'More',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Gothic A1',
                          fontWeight: FontWeight.w500,
                          height: 0.09,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

