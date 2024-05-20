import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/bars.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_application/views/all_group_pages.dart';
import 'package:flutter_application/views/group_creation_page.dart';
import 'package:flutter_application/views/group_page.dart';
import 'package:flutter_application/views/group_invitations_page.dart';
import 'package:image_picker/image_picker.dart';

class MyGroups extends StatefulWidget {
  MyGroups({super.key});

  @override
  State<MyGroups> createState() => _MyGroupsState();
}

class _MyGroupsState extends State<MyGroups> {
  List<Group> myGroups = [];
  XFile? pickedImage;
  ImageProvider groupImage = const AssetImage('lib/images/splash.png');

  @override
  void initState() {
    super.initState();
    fetchMyGroups();
  }

  void refreshMyGroups() {
    fetchMyGroups();
  }

  void fetchMyGroups() async {
    List<Group> groups = await BackendService().getMyGroups();
    setState(() {
      myGroups = groups;
    });
  }

    Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final ImageSource? source = await showDialog<ImageSource?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  child: const Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
    if (source == null) {
      return;
    }
    final XFile? image = await picker.pickImage(
      source: source,
      requestFullMetadata: false,
    );
    if (image == null) {
      return;
    }

    pickedImage = image;

    ImageProvider temp = MemoryImage(await image.readAsBytes());
    setState(() {
      groupImage = temp;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context: context,
        showBackButton: false,
        title: 'Groups',
      ),
      body: DefaultBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  /*Text(
                    'Groups',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),*/
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllGroupsPage(
                              refreshMyGroups: refreshMyGroups,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Search groups'),
                          Icon(Icons.search),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupCreation(
                              onGroupCreatedCallBacks: [refreshMyGroups],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Create a group'),
                          Icon(Icons.add),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GroupInvitationsPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Invitations'),
                          Icon(Icons.insert_invitation),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16), // Add some space before My Groups section
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text('My Groups',
                  style: TextStyle(
                    fontSize: 20,
                  )),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: ListView.builder(
                itemCount: myGroups.length,
                itemBuilder: (context, index) {
                  final group = myGroups[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 254, 192, 173),
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: group.imageId != null ? NetworkImage('URL_TO_YOUR_IMAGE_API/${group.imageId}')
                          : const AssetImage('lib/images/splash.png') as ImageProvider,
                          ),
                        title: Text(group.name),
                        trailing: const Row(
                          mainAxisSize: MainAxisSize.min,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: ((context) =>
                                  GroupPage(group: group, isMember: true)),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        context: context,
      ),
    );
  }
}
