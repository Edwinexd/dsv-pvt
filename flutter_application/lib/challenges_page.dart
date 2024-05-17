import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'bars.dart'; // Import bars.dart

class WhiteRectangle extends StatelessWidget {
  final Widget child;

  WhiteRectangle({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(30, 30, 30, 30), // Adjust the margin here
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
  bool _isSecondContainerVisible = false;

  void _toggleContainerVisibility() {
    setState(() {
      _isSecondContainerVisible = !_isSecondContainerVisible;
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
              width: MediaQuery.of(context).size.width -
                  60, // Adjust the width here
              child: WhiteRectangle(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(10.0), // Add 10px padding
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
                      SizedBox(height: 20), // Add more space
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
                        'and gain an achivment',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xff8134ce),
                          fontFamily: 'Poppins',
                          height: 0,
                        ),
                      ),
                      SizedBox(height: 20), // Space before the first container
                      GestureDetector(
                        onTap: _toggleContainerVisibility,
                        child: Container(
                          height: 35,
                          margin: EdgeInsets.symmetric(
                              horizontal: 20), // 20px padding from the sides
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
                              Spacer(), // Adds space to push the text to the center
                              const Text(
                                'Group activities',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              Spacer(), // Adds space to push the text to the center
                              Icon(
                                _isSecondContainerVisible
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_isSecondContainerVisible) ...[
                        Container(
                          height: 263,
                          margin: EdgeInsets.symmetric(
                              horizontal: 20), // 20px padding from the sides
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
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        context: context,
      ),
    );
  }
}
