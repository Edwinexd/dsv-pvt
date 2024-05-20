import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'bars.dart'; 

class WhiteRectangle extends StatelessWidget {
  final Widget child;

  WhiteRectangle({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(30, 30, 30, 30), 
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

  // The list of group activities can be replaced with the actual data
  final List<Map<String, String>> groupActivities = [
    {
      'title': 'Activity 1',
      'description': 'Description for Activity 1',
    },
    {
      'title': 'Activity 2',
      'description': 'Description for Activity 2',
    },
    {
      'title': 'Activity 3',
      'description': 'Description for Activity 3',
    },
    {
      'title': 'Activity 2',
      'description': 'Description for Activity 2',
    },
    {
      'title': 'Activity 2',
      'description': 'Description for Activity 2',
    },
    {
      'title': 'Activity 2',
      'description': 'Description for Activity 2',
    },
    {
      'title': 'Activity 2',
      'description': 'Description for Activity 2',
    },
  ];

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
                  padding: EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(10.0), 
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
                        if (_isGroupActivitiesVisible) ...[
                          Container(
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
                              itemCount: groupActivities.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        groupActivities[index]['title']!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Color(0xff161499),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        groupActivities[index]['description']!,
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
                          ),
                        ],
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
                        if (_isDuringTheRaceVisible) ...[
                          Container(
                            height: 263,
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                            decoration: ShapeDecoration(
                              color: Color(0xFFFFD5A3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ],
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
