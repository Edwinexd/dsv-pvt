import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

class MapScreen extends StatelessWidget {
  final ValueChanged<String> onLocationSelected;

  const MapScreen({super.key, required this.onLocationSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick a Location'),
      ),
      body: FlutterLocationPicker(
        onPicked: (location) {
          onLocationSelected(location.address);
          //Navigate back to the previous screen
          Navigator.pop(context);
        },
      ),
    );
  }
}
