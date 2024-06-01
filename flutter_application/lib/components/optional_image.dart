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
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/controllers/backend_service_interface.dart';

class OptionalImage extends StatefulWidget {
  final String? imageId;
  final BackendServiceInterface backendService;

  OptionalImage({
      Key? key,
      this.imageId,
      BackendServiceInterface? backendService
    }) : backendService = backendService ?? BackendService(),
        super(key: key);

  @override
  _OptionalImageState createState() => _OptionalImageState();
}

class _OptionalImageState extends State<OptionalImage> {
  Future<ImageProvider> _fetchImage(String imageId) async {
    // Replace this with your actual method to fetch the image from backend service
    // For example: return await BackendService8().getImage(imageId);
    return await BackendService().getImage(imageId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ImageProvider>(
      future: widget.imageId != null ? _fetchImage(widget.imageId!) : null,
      builder: (BuildContext context, AsyncSnapshot<ImageProvider> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        // if future is null
        if (snapshot.data == null) {
          return const CircleAvatar(foregroundImage: AssetImage('lib/images/splash.png'));
        }
        return CircleAvatar(foregroundImage: snapshot.data!);
      },
    );
  }
}
