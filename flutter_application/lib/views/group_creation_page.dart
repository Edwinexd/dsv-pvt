import 'package:flutter/material.dart';
import 'package:flutter_application/bars.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_application/models/user.dart';
import 'package:flutter_application/views/map_screen.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/views/group_page.dart';
import 'package:flutter_application/components/skill_level_slider.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:image_picker/image_picker.dart';

class GroupCreation extends StatefulWidget {
  final List<Function> onGroupCreatedCallBacks;

  const GroupCreation({super.key, required this.onGroupCreatedCallBacks});

  @override
  GroupCreationState createState() => GroupCreationState();
}

class GroupCreationState extends State<GroupCreation> {
  ImageProvider groupImage = const AssetImage('lib/images/splash.png');
  XFile? pickedImage;
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  PickedData? _location;
  bool _isPublic = false;
  int _memberLimit = 10; //Default member limit
  int _skillLevel = 0;
  bool _isGroupCreated = false;
  String _errorMessage = '';
  Group? createdGroup;

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

  Future<void> fetchImage(String groupId) async {
    if (createdGroup != null && createdGroup!.imageId != null) {
      
    }
    ImageProvider image = await BackendService().getImage(createdGroup!.imageId!);
    setState(() {
      groupImage = image;
    });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context: context,
        showBackButton: true,
        title: 'Create Group',
      ),
      body: DefaultBackground(
        child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: groupImage,
                        child: const Align(
                          alignment: Alignment.bottomRight,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 15,
                            child: Icon(Icons.camera_alt,
                                color: Colors.blue, size: 22),
                          ),
                        ),
                      ),
                    ),
                  ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Group Name'),
              ),
              const SizedBox(height: 16.0),
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
              const SizedBox(height: 16.0),
              Row(
                children: <Widget>[
                  const Text(
                    'Public',
                    style: TextStyle(fontSize: 12.0),
                  ),
                  Switch(
                    value: _isPublic,
                    onChanged: (value) {
                      setState(() {
                        _isPublic = value;
                      });
                    },
                  ),
                  const Text(
                    'Private',
                    style: TextStyle(fontSize: 12.0),
                  ),
                  const SizedBox(width: 16.0),
                  const Text(
                    'Member Limit:',
                    style: TextStyle(fontSize: 12.0),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: TextFormField(
                      initialValue: _memberLimit.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _memberLimit = int.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Group Description'),
                maxLines: 3,
              ),

              const SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    createGroup();
                  }, 
                  child: const Text('Create Group'),
                ),
              ),
              if (_isGroupCreated)
                ElevatedButton(
                  onPressed: () {
                    //Redirecting to the group page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupPage(group: createdGroup!, isMember: true),

                    ),
                    );
                  },
                  child: const Text('Go to Group Page'),
                  //
                ),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
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

  void createGroup() async {
    String name = _nameController.text.trim();
    String description = _descriptionController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Group name can not be empty!';
      });
      return;
    }

    User me = await BackendService().getMe();
    createdGroup = await BackendService().createGroup(name, description, _isPublic, me.id, _skillLevel, _location?.latLong.latitude, _location?.latLong.longitude, _location?.address);
    
    if (pickedImage != null) {
      await BackendService().uploadGroupPicture(createdGroup!.id, pickedImage!);
    }

    if (createdGroup != null) {
      if (createdGroup!.imageId != null) {
        await fetchImage(createdGroup!.id.toString());
      } 
    }

    widget.onGroupCreatedCallBacks.forEach((callback) {
      callback();
    }); //Calls refreshGroups in parent MyGroupsPage

    setState(() {
      _errorMessage = '';
    });

    setState(() {
      _isGroupCreated = true;
    });
  }
}
