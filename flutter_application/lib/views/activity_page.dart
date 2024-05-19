
// Stateful widget that injects a completed activity page or upcoming activity page depending on the activity status

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/bars.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/models/activity.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_application/models/user.dart';
import 'package:intl/intl.dart';

class ActivityPage extends StatefulWidget {
  final int groupId;
  final int activityId;

  ActivityPage({required this.groupId, required this.activityId});

  @override
  _ActivityPageState createState() => _ActivityPageState();

}

class _ActivityPageState extends State<ActivityPage> {
  Activity? activity;
  Group? group;
  List<User>? participants;
  User? user;
  ImageProvider? groupImage;

  @override
  void initState() {
    super.initState();
    unawaited(BackendService().getActivity(widget.groupId, widget.activityId).then((activity) {
      setState(() {
        this.activity = activity;
      });
    }));
    unawaited(BackendService().getGroup(widget.groupId).then((group) {
      setState(() {
        this.group = group;
      });
      if (group.imageId != null) {
        unawaited(BackendService().getImage(group.imageId!).then((image) {
          setState(() {
            this.groupImage = image;
          });
        }));
      }
    }));
    unawaited(BackendService().getActivityParticipants(widget.groupId, widget.activityId, 0, 250).then((participants) {
      setState(() {
        this.participants = participants;
      });
    }));
    unawaited(BackendService().getMe().then((user) {
      setState(() {
        this.user = user;
      });
    }));
  }

  @override
  Widget build(BuildContext context) {
    if (activity == null || group == null || participants == null || user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Activity'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

   return Scaffold(
      appBar: AppBar(
        title: Text('Activity'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
            body: DefaultBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  activity!.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: groupImage,
                        ),
                        SizedBox(width: 10),
                        Text(
                          group!.name,
                          style: TextStyle(
                            fontSize: 22,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Date",
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              DateFormat('EEEE dd MMMM y HH:mm').format(activity!.scheduledDateTime),
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Location",
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              activity!.address,
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Challenges",
                          style: TextStyle(
                            fontSize: 22,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Column(
                          children: activity!.challenges.map<Widget>((challenge) {
                            return Row(
                              children: [
                                Icon(Icons.check_box, color: Colors.purple),
                                SizedBox(width: 10),
                                Text(
                                  challenge.name,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Handle complete activity
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  ),
                  child: Text(
                    'Complete activity',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
