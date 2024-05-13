import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

class MapScreen extends StatelessWidget {
  final ValueChanged<PickedData> onLocationSelected;

  const MapScreen({super.key, required this.onLocationSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Pick a location'),
        ),
        body: FlutterLocationPicker(
          selectLocationButtonStyle: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white),
          ),
          selectedLocationButtonTextstyle: const TextStyle(
            fontSize: 18,
          ),
          selectLocationButtonText: 'Set Current Location',
          selectLocationButtonLeadingIcon: const Icon(Icons.check),
          initZoom: 11,
          minZoomLevel: 5,
          maxZoomLevel: 16,
          trackMyPosition: true,
          mapLanguage: 'sv',
          onError: (e) => print(e),
          onPicked: (pickedData) {
            onLocationSelected(pickedData);
            //Navigate back to the previous screen
            Navigator.pop(context);
          },
        ));
  }
}
