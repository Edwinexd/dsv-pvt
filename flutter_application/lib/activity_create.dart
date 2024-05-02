import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

//test Mac

class ActivityCreatePage extends StatefulWidget {
  // Take groupId as a parameter
  const ActivityCreatePage({Key? key, required this.groupId}) : super(key: key);

  final String groupId;

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
  // TODO: Location

  // Same skillLevels as in profiles
  List<String> skillLevels = [
    'Beginner: 10 - 8 min/km',
    'Intermediate: 8 - 6 min/km',
    'Advanced: 6 - 5 min/km',
    'Professional: 5 - 4 min/km',
    'Elite: < 4 min/km'
  ];

  void _createActivity() {
    if (_formKey.currentState!.validate()) {
      // TODO: Http to backend
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Activity Created!')));
    }
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
          FlutterLocationPicker(
            initZoom: 11,
            minZoomLevel: 5,
            maxZoomLevel: 16,
            trackMyPosition: true,
            searchBarBackgroundColor: Colors.white,
            selectedLocationButtonTextstyle: const TextStyle(fontSize: 18),
            mapLanguage: 'en',
            onError: (e) => print(e),
            selectLocationButtonLeadingIcon: const Icon(Icons.check),
            onPicked: (pickedData) {
              print(pickedData.latLong.latitude);
              print(pickedData.latLong.longitude);
              print(pickedData.address);
              print(pickedData.addressData);
            },
            onChanged: (pickedData) {
              print(pickedData.latLong.latitude);
              print(pickedData.latLong.longitude);
              print(pickedData.address);
              print(pickedData.addressData);
            },
            showContributorBadgeForOSM: true,
          ));/*,
          Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Activity Title'),
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
                      Text('Skill Level:', style: TextStyle(fontSize: 16)),
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
                ElevatedButton(
                  onPressed: _createActivity,
                  child: Text('Create Activity'),
                ),
              ],
            ),
          ),
        ]));*/
  }
}
