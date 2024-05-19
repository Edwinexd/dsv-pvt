import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/bars.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/models/activity.dart';
import 'package:flutter_application/components/skill_level_slider.dart';
import 'package:flutter_application/models/challenges.dart';
import 'package:flutter_application/views/activity_page.dart';
import 'package:flutter_application/views/map_screen.dart';
import 'package:intl/intl.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

//test Mac

class ActivityCreatePage extends StatefulWidget {
  // Take groupId as a parameter
  ActivityCreatePage({super.key, required this.groupId});

  final int groupId;

  @override
  _ActivityCreatePageState createState() => _ActivityCreatePageState();
}

class _ActivityCreatePageState extends State<ActivityCreatePage> {
  List<Challenge> _challenges = [];
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  PickedData? _location;
  DateTime _pickedDate = DateTime.now();
  TimeOfDay _pickedTime = TimeOfDay.now();
  DateTime _pickedDateTime = DateTime.now();
  int _skillLevel = 0; // Manage skill level as an integer
  List<int> _chosenChallenges = [];

  void _createActivity() async {
    if (_titleController.text.trim().isEmpty || _location == null || _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill in all fields'),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    int groupId = widget.groupId;
    String name = _titleController.text.trim();
    DateTime dateTime = _pickedDateTime;
    int difficulty = _skillLevel;

    Activity activity = await BackendService().createActivity(
        groupId,
        name,
        dateTime,
        difficulty,
        _location!.latLong.latitude,
        _location!.latLong.longitude,
        _location!.address,
        _chosenChallenges
            .map((e) => _challenges.firstWhere((element) => element.id == e))
            .toList());

    // Make user join the activity
    await BackendService().joinActivity(groupId, activity.id, (await BackendService().getMe()).id);

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return ActivityPage(activityId: activity.id, groupId: groupId);
    }));
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 14)),
    );
    if (picked != null && picked != _pickedDate) {
      setState(() {
        _pickedDate = picked;
        _pickedDateTime = DateTime(_pickedDate.year, _pickedDate.month,
            _pickedDate.day, _pickedTime.hour, _pickedTime.minute);
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _pickedTime,
      builder: (BuildContext context, Widget? child) {
        // Force 24-hour format
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _pickedTime) {
      setState(() {
        _pickedTime = picked;
        _pickedDateTime = DateTime(_pickedDate.year, _pickedDate.month,
            _pickedDate.day, picked.hour, picked.minute);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    unawaited(BackendService().getChallenges(0, 100).then((value) {
      setState(() {
        _challenges = value;
      });
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: 'Create Activity',
        context: context,
        showBackButton: true,
      ),
      body: DefaultBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Activity Title'),
                  validator: (value) =>
                      value!.isEmpty ? 'Title cannot be empty' : null,
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreen(
                          onLocationSelected: (location) {
                            setState(() {
                              _location = location;
                              _locationController.text = location.address;
                            });
                          },
                        ),
                      ),
                    );
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        suffixIcon: Icon(Icons.location_on),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                          'Date & Time: ${DateFormat('EEEE dd MMMM hh:mm').format(_pickedDateTime.toLocal())}', // Use DateFormat to format the date
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 12.0),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: _pickDate,
                            child: Text('Select Date'),
                          ),
                          SizedBox(width: 12.0),
                          ElevatedButton(
                            onPressed: _pickTime,
                            child: Text('Select Time'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _descriptionController,
                  decoration:
                      InputDecoration(labelText: 'Activity Description'),
                  maxLines: 2,
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(8.0),
                  margin: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFFDEBB4), // May change later
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Challenges:', style: TextStyle(fontSize: 16)),
                        for (Challenge challenge in _challenges)
                          CheckboxListTile(
                            title: Text(challenge.name),
                            value: _chosenChallenges.contains(challenge.id),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value!) {
                                  _chosenChallenges.add(challenge.id);
                                } else {
                                  _chosenChallenges.remove(challenge.id);
                                }
                              });
                            },
                          ),
                      ]),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Skill Level:',
                  style: TextStyle(fontSize: 16),
                ),
                SkillLevelSlider(
                  initialSkillLevel: _skillLevel,
                  onSkillLevelChanged: (newLevel) {
                    setState(() {
                      _skillLevel = newLevel;
                    });
                  },
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _createActivity();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF9B40BF),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 26),
                    ),
                    child: const Text(
                      'Create activity',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
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
