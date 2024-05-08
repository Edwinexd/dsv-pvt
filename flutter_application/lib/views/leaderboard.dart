import 'package:flutter/material.dart';

class LeaderboardEntry {
  final String name;
  final int points;
  final int rank;

  LeaderboardEntry(this.name, this.points, this.rank);
}

class Leaderboard extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  Leaderboard(this.entries);

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
              for (var entry in entries)
                Positioned(
                  left: 106.08 + (entry.rank - 1) * 111.92,
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
                                      entry.rank.toString(),
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
                                      entry.name,
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
                                          '${entry.points}p',
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
