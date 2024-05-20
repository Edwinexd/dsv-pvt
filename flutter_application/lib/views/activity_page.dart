import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/bars.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/models/activity.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_application/models/user.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

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
    unawaited(_loadData());
  }

  Future<void> _loadData() async {
    final activity = await BackendService().getActivity(widget.groupId, widget.activityId);
    final group = await BackendService().getGroup(widget.groupId);
    final participants = await BackendService().getActivityParticipants(widget.groupId, widget.activityId, 0, 250);
    final user = await BackendService().getMe();

    ImageProvider? groupImage;
    if (group.imageId != null) {
      groupImage = await BackendService().getImage(group.imageId!);
    }

    setState(() {
      this.activity = activity;
      this.group = group;
      this.participants = participants;
      this.user = user;
      this.groupImage = groupImage;
    });
  }


  Widget _buildActionButton(String text, Color color, VoidCallback? onPressed, IconData? icon) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 20),
          if (icon != null) SizedBox(width: 8), // Spacing between icon and text
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getActionButton() {
    if (activity == null || group == null || participants == null || user == null) {
      return SizedBox.shrink();
    }

    // if activity owner_id is the same as the user id
    if (!activity!.isCompleted && activity!.ownerId == user!.id) {
      // User is able to complete the activity
      return _buildActionButton('Complete activity', Colors.orange, () async {
        await BackendService().updateActivity(group!.id, activity!.id, isCompleted: true);
        // reload data
        await _loadData();
      }, Icons.check);
    }
    if (activity!.isCompleted && !participants!.any((participant) => participant.id == user!.id)) {
      // Activity is completed
      return _buildActionButton('Activity Completed', Colors.grey, null, Icons.done);
    }
    if (activity!.isCompleted && participants!.any((participant) => participant.id == user!.id)) {
      // Activity is completed and user had joined it (share button)
      return _buildActionButton('Share Completion', Colors.blue, () async {
        XFile shareImage = await BackendService().getActivityShareImage(user!.id, activity!.id, group!.id);
        Share.shareXFiles([shareImage]);
      }, Icons.share);
    }
    if (!activity!.isCompleted && !participants!.any((participant) => participant.id == user!.id)) {
      // Activity isn't completed and the user hasn't joined (join button)
      return _buildActionButton('Join Activity', Colors.green, () async {
        await BackendService().joinActivity(group!.id, activity!.id, user!.id);
        // reload data
        await _loadData();
      }, Icons.add);
    }
    if (!activity!.isCompleted && participants!.any((participant) => participant.id == user!.id)) {
      // Activity isn't completed and the user has joined (leave button)
      return _buildActionButton('Leave Activity', Colors.red, () async {
        await BackendService().leaveActivity(group!.id, activity!.id, user!.id);
        // reload data
        await _loadData();
      }, Icons.remove);
    }
    return SizedBox.shrink();
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

    Widget? actionButton = _getActionButton();
  
    return Scaffold(
      appBar: buildAppBar(
        context: context,
        title: 'Leaderboard',
        showBackButton: true,
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
                actionButton,
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
