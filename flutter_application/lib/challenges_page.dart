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
import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/models/challenges.dart';
import 'bars.dart';

class WhiteRectangle extends StatelessWidget {
  final Widget child;

  WhiteRectangle({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(5, 20, 5, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.7),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class ChallengesPage extends StatefulWidget {
  @override
  _ChallengesPageState createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  bool _isGroupActivitiesVisible = true;
  bool _isDuringTheRaceVisible = false;

  Future<List<Challenge>> _fetchChallenges() async {
    return await BackendService().getChallenges(0, 25); // Adjust skip and limit as needed
  }

  void _toggleGroupActivitiesVisibility() {
    setState(() {
      _isGroupActivitiesVisible = !_isGroupActivitiesVisible;
    });
  }

  void _toggleDuringTheRaceVisibility() {
    setState(() {
      _isDuringTheRaceVisible = !_isDuringTheRaceVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: 'Challenges',
        context: context,
        showBackButton: true,
      ),
      body: Stack(
        children: [
          DefaultBackground(),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: MediaQuery.of(context).size.width - 60,
              child: WhiteRectangle(
                child: Padding(
                  padding: EdgeInsets.all(2.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'Challenges',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff8134ce),
                              fontFamily: 'Inter',
                              height: 0.04,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        const Text(
                          'complete challenges with a group',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xff8134ce),
                            fontFamily: 'Poppins',
                            height: 0,
                          ),
                        ),
                        const Text(
                          'during an activity to collect points',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xff8134ce),
                            fontFamily: 'Poppins',
                            height: 0,
                          ),
                        ),
                        const Text(
                          'and gain an achievement',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xff8134ce),
                            fontFamily: 'Poppins',
                            height: 0,
                          ),
                        ),
                        SizedBox(height: 30),
                        GestureDetector(
                          onTap: _toggleGroupActivitiesVisibility,
                          child: Container(
                            height: 35,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            decoration: ShapeDecoration(
                              color: Color(0xFFFE9E2C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Spacer(),
                                const Text(
                                  'Group activities',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  _isGroupActivitiesVisible
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isGroupActivitiesVisible)
                          FutureBuilder<List<Challenge>>(
                            future: _fetchChallenges(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(child: Text('Error loading challenges'));
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Center(child: Text('No challenges available'));
                              }

                              var challenges = snapshot.data!;
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                decoration: ShapeDecoration(
                                  color: Color(0xFFFFD5A3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: challenges.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            challenges[index].name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              color: Color(0xff161499),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            challenges[index].description,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xff161499),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        SizedBox(height: 30),
                        GestureDetector(
                          onTap: _toggleDuringTheRaceVisibility,
                          child: Container(
                            height: 35,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            decoration: ShapeDecoration(
                              color: Color(0xFFFE9E2C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Spacer(),
                                const Text(
                                  'During the race',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  _isDuringTheRaceVisible
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isDuringTheRaceVisible)
                          FutureBuilder<Null>(
                            future: null,
                            builder: (context, snapshot) {
                              // TODO The following is a placeholder. Replace with actual data from Midnattsloppet!
                              // Note: Examples are AI-generated and may not make sense.
                              var challenges = [
                              Challenge(
                                id: 1,
                                name: 'Hydration Station Hero',
                                description: 'Grab a drink at each hydration station.',
                                difficulty: 1,
                                expirationDate: null,
                                pointReward: 5,
                                achievementId: null,
                                imageId: null,
                              ),
                              Challenge(
                                id: 2,
                                name: 'High Five Five',
                                description: 'Give a high five to five spectators.',
                                difficulty: 2,
                                expirationDate: null,
                                pointReward: 10,
                                achievementId: null,
                                imageId: null,
                              ),
                              Challenge(
                                id: 3,
                                name: 'Pace Pusher',
                                description: 'Maintain a consistent pace for 3 consecutive miles.',
                                difficulty: 3,
                                expirationDate: null,
                                pointReward: 15,
                                achievementId: null,
                                imageId: null,
                              ),
                              Challenge(
                                id: 4,
                                name: 'Hill Climber',
                                description: 'Run up the steepest hill without stopping.',
                                difficulty: 4,
                                expirationDate: null,
                                pointReward: 20,
                                achievementId: null,
                                imageId: null,
                              ),
                              Challenge(
                                id: 5,
                                name: 'Selfie Superstar',
                                description: 'Take a selfie at a scenic spot along the route.',
                                difficulty: 1,
                                expirationDate: null,
                                pointReward: 5,
                                achievementId: null,
                                imageId: null,
                              ),
                              Challenge(
                                id: 6,
                                name: 'Speed Burst',
                                description: 'Sprint for 100 meters at the halfway point.',
                                difficulty: 3,
                                expirationDate: null,
                                pointReward: 15,
                                achievementId: null,
                                imageId: null,
                              ),
                              Challenge(
                                id: 7,
                                name: 'Running DJ',
                                description: 'Run a mile while singing along to your favorite song.',
                                difficulty: 2,
                                expirationDate: null,
                                pointReward: 10,
                                achievementId: null,
                                imageId: null,
                              ),
                              Challenge(
                                id: 8,
                                name: 'Silent Runner',
                                description: 'Run 2 miles in complete silence (no music or talking).',
                                difficulty: 3,
                                expirationDate: null,
                                pointReward: 15,
                                achievementId: null,
                                imageId: null,
                              ),
                              Challenge(
                                id: 9,
                                name: 'Post-Race Pic',
                                description: 'Take a photo with your medal at the finish line.',
                                difficulty: 1,
                                expirationDate: null,
                                pointReward: 5,
                                achievementId: null,
                                imageId: null,
                              ),
                              Challenge(
                                id: 10,
                                name: 'Finish Line Sprint',
                                description: 'Sprint the last 200 meters of the race.',
                                difficulty: 2,
                                expirationDate: null,
                                pointReward: 10,
                                achievementId: null,
                                imageId: null,
                              ),
                            ];
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                decoration: ShapeDecoration(
                                  color: Color(0xFFFFD5A3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: challenges.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            challenges[index].name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              color: Color(0xff161499),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            challenges[index].description,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xff161499),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        context: context,
      ),
    );
  }
}
