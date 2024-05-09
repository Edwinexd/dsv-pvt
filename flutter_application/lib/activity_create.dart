import 'package:flutter/material.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/models/activity.dart';
import 'package:intl/intl.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

//test Mac

class ActivityCreatePage extends StatefulWidget {
  // Take groupId as a parameter
  ActivityCreatePage({Key? key, required this.groupId}) : super(key: key);

  final int groupId;
  // TODO Get from backend
  final List<dynamic> challenges = [{"id": 0, "name": 'Spring 0 km'}, {"id": 1, "name": 'Gå 1 km'}, {"id": 2, "name": 'Hoppa 200 ggr'}];


  @override
  _ActivityCreatePageState createState() => _ActivityCreatePageState();
}

class _ActivityCreatePageState extends State<ActivityCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime _pickedDate = DateTime.now();
  TimeOfDay _pickedTime = TimeOfDay.now();
  DateTime _pickedDateTime = DateTime.now();
  int _difficultyCode = 0; // Manage skill level as an integer
  PickedData? _pickedData;
  // Chosen challenges (ids)
  List<String> _chosenChallenges = [];


  // Same skillLevels as in profiles
  List<String> skillLevels = [
    'Beginner: 10 - 8 min/km',
    'Intermediate: 8 - 6 min/km',
    'Advanced: 6 - 5 min/km',
    'Professional: 5 - 4 min/km',
    'Elite: < 4 min/km'
  ];

  void _createActivity() async {
    if (_formKey.currentState!.validate()) {
      // int groupId = widget.groupId;
      String name = _titleController.text.trim();
      DateTime dateTime = _pickedDateTime;
      int difficulty = _difficultyCode;

      Activity activity = await BackendService().createActivity(widget.groupId, name, dateTime, difficulty);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Activity created for $widget.groupId!')));
    }
    // TODO: Navigate to newly created activity
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Activity')),
      body: /*ListView(padding: EdgeInsets.all(16.0), children: <Widget>[*/
          _pickedData == null
              ? FlutterLocationPicker(
                  selectLocationButtonText: 'Select Location',
                  initZoom: 11,
                  minZoomLevel: 5,
                  maxZoomLevel: 16,
                  trackMyPosition: true,
                  searchBarBackgroundColor: Colors.white,
                  selectedLocationButtonTextstyle:
                      const TextStyle(fontSize: 18),
                  mapLanguage: 'sv',
                  onError: (e) => print(e),
                  selectLocationButtonLeadingIcon: const Icon(Icons.check),
                  onPicked: (pickedData) {
                    setState(() {
                      _pickedData = pickedData;
                    });
                  },
                  showContributorBadgeForOSM: true,
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.all(16.0),
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Location: ${_pickedData!.address}',
                              style: TextStyle(fontSize: 16)),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _pickedData = null;
                              });
                            },
                            child: Text('Change Location'),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: _titleController,
                        decoration:
                            InputDecoration(labelText: 'Activity Title'),
                        validator: (value) =>
                            value!.isEmpty ? 'Title cannot be empty' : null,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                                'Date & Time: ${DateFormat('EEEE dd MMMM hh:mm').format(_pickedDateTime.toLocal())}', // Use DateFormat to format the date
                                style: TextStyle(fontSize: 16)),
                            Column(
                              // TODO: Frontend people help me place these buttons nicely! / Edwin
                              children: [
                                ElevatedButton(
                                  onPressed: _pickDate,
                                  child: Text('Select Date'),
                                ),
                                ElevatedButton(
                                  onPressed: _pickTime,
                                  child: Text('Select Time'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Skill Level:',
                                style: TextStyle(fontSize: 16)),
                            Slider(
                              value: _difficultyCode.toDouble(),
                              min: 0,
                              max: 4,
                              divisions: 4,
                              onChanged: (double value) {
                                setState(() {
                                  _difficultyCode = value.toInt();
                                });
                              },
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: Text('${skillLevels[_difficultyCode]}',
                                  style: TextStyle(fontSize: 12)),
                            )
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Challenges:', style: TextStyle(fontSize: 16)),
                          for (dynamic challenge in widget.challenges)
                            CheckboxListTile(
                              title: Text(challenge["name"]),
                              value: _chosenChallenges.contains(challenge["id"].toString()),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value!) {
                                    _chosenChallenges.add(challenge["id"].toString());
                                  } else {
                                    _chosenChallenges.remove(challenge["id"].toString());
                                  }
                                });
                              },
                            ),
                        ]
                      ),
                      
                      ElevatedButton(
                        onPressed: _createActivity,
                        child: Text('Create Activity'),
                      ),
                    ],
                  ),
                ),
      //],
      //),
    );
  }
}
