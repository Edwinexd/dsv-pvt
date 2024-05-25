import 'package:flutter/material.dart';
import 'package:flutter_application/controllers/backend_service.dart';

class OptionalImage extends StatefulWidget {
  final String? imageId;

  OptionalImage({Key? key, this.imageId}) : super(key: key);

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
