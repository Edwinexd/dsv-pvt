import 'package:flutter/material.dart';
import 'package:flutter_application/bars.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_application/views/group_page.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:geolocator/geolocator.dart';

class AllGroupsPage extends StatefulWidget {
  final Function refreshMyGroups;
  const AllGroupsPage({
    super.key,
    required this.refreshMyGroups,
  });

  @override
  AllGroupsPageState createState() => AllGroupsPageState();
}

class AllGroupsPageState extends State<AllGroupsPage> {
  List<Group> _groups = [];
  List<Group> _myGroups = [];
  Map<String, ImageProvider> groupImages = {};
  String _searchQuery = '';
  String _selectedFilter = 'All';
  Position? _userPosition;
  bool _sortByDistance = false;

  @override
  void initState() {
    super.initState();
    fetchUserLocationAndGroups();
    fetchMyGroups();
  }

  void refreshAllGroups() async {
    fetchGroups();
  }

  Future<void> fetchUserLocationAndGroups() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _userPosition = position;
      });
    } catch (e) {
      print('Error getting user location: $e');
    }
    fetchGroups();
  }

  void fetchGroups() async {
    List<Group> fetchedGroups =
        await BackendService().getGroups(0, 100, GroupOrderType.NAME, false);
    Map<String, ImageProvider> images = {};
    for (var group in fetchedGroups) {
      if (group.imageId != null) {
        ImageProvider image =
            await BackendService().getImage(group.imageId ?? '');
        images[group.id.toString()] = image;
      } else {
        images[group.id.toString()] = const AssetImage('lib/images/splash.png');
      }
    }

    if (_sortByDistance && _userPosition != null) {
      fetchedGroups.sort((a, b) {
        if (a.latitude == null || a.longitude == null) return 1;
        if (b.latitude == null || b.longitude == null) return 1;

        double distanceA = Geolocator.distanceBetween(
            _userPosition!.latitude, _userPosition!.longitude, a.latitude!, a.longitude!);
        double distanceB = Geolocator.distanceBetween(
            _userPosition!.latitude, _userPosition!.longitude, b.latitude!, b.longitude!);
        return distanceA.compareTo(distanceB);
      });
    }

    setState(() {
      _groups = fetchedGroups;
      groupImages = images;
    });
  }

  Future<void> fetchMyGroups() async {
    _myGroups = await BackendService().getMyGroups();
  }

  @override
  Widget build(BuildContext context) {
    List<Group> filteredGroups = _groups.where((group) {
      final name = group.name.toLowerCase();
      final isPrivate = group.isPrivate;

      bool matchesSearchQuery = name.contains(_searchQuery.toLowerCase());
      bool isPublicMatch = (_selectedFilter == 'All') ||
          (_selectedFilter == 'Public' && !isPrivate) ||
          (_selectedFilter == 'Private' && isPrivate);
      return matchesSearchQuery && isPublicMatch;
    }).toList();

    return Scaffold(
      appBar: buildAppBar(
        context: context,
        showBackButton: true,
        title: 'All Groups',
      ),
      body: DefaultBackground(
        children: [
          Container(
            color: const Color(0xFFABABFC),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Search groups',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonFormField(
                    value: _selectedFilter,
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value.toString();
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(
                          value: 'Public',
                          child: Text('Show only public groups')),
                      DropdownMenuItem(
                          value: 'Private',
                          child: Text('Show only private groups')),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SwitchListTile(
                    title: Text('Sort by Distance'),
                    value: _sortByDistance,
                    onChanged: (value) {
                      setState(() {
                        _sortByDistance = value;
                        fetchGroups();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: filteredGroups.length,
              itemBuilder: (context, index) {
                final group = filteredGroups[index];
                return GestureDetector(
                  onTap: () {
                    bool isMember =
                        _myGroups.any((myGroup) => myGroup.id == group.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GroupPage(group: group, isMember: isMember),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFD5A3),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: groupImages[group.id.toString()],
                        child: groupImages[group.id.toString()] == null
                            ? Icon(Icons.group)
                            : null,
                      ),
                      title: Text(
                        group.name,
                        style: const TextStyle(
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(group.description),
                          Text(group.isPrivate ? 'Private' : 'Public'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        context: context,
      ),
    );
  }
}
