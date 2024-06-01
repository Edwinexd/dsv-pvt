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
import 'package:flutter_application/bars.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

class MapScreen extends StatelessWidget {
  final ValueChanged<PickedData> onLocationSelected;

  const MapScreen({super.key, required this.onLocationSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(
          title: 'Pick a Location', 
          context: context,
          showBackButton: true,
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
