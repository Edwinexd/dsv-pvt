import 'package:flutter/material.dart';
import 'package:flutter_application/bars.dart';
import 'package:flutter_application/components/optional_image.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/controllers/backend_service_interface.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_application/views/group_page.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:geolocator/geolocator.dart';

class AllGroupsPage extends StatefulWidget {
  final Function refreshMyGroups;
  final BackendServiceInterface backendService;

  AllGroupsPage({
    Key? key,
    required this.refreshMyGroups,
    BackendServiceInterface? backendService,
  })  : backendService = backendService ?? BackendService(),
    super(key: key);

  @override
  AllGroupsPageState createState() => AllGroupsPageState();
}

class AllGroupsPageState extends State<AllGroupsPage> {
  List<Group> _groups = [];
  List<Group> _myGroups = [];
  String _searchQuery = '';
  String _selectedFilter = 'All';
  Position? _userPosition;
  String _sortBy = 'None'; 

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
        await widget.backendService.getGroups(0, 100, GroupOrderType.NAME, false);

    if (_sortBy == 'Distance' && _userPosition != null) {
      fetchedGroups.sort((a, b) {
        if (a.latitude == null || a.longitude == null) return 1;
        if (b.latitude == null || b.longitude == null) return 1;

        double distanceA = Geolocator.distanceBetween(
            _userPosition!.latitude, _userPosition!.longitude, a.latitude!, a.longitude!);
        double distanceB = Geolocator.distanceBetween(
            _userPosition!.latitude, _userPosition!.longitude, b.latitude!, b.longitude!);
        return distanceA.compareTo(distanceB);
      });
    } else if (_sortBy == 'Points') {
      fetchedGroups.sort((a, b) => b.points.compareTo(a.points));
    }

    setState(() {
      _groups = fetchedGroups;
    });
  }

  Future<void> fetchMyGroups() async {
    _myGroups = await widget.backendService.getMyGroups();
  }

  String getDistanceString(Group group) {
    if (_userPosition == null || group.latitude == null || group.longitude == null) {
      return '';
    }
    double distanceInMeters = Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      group.latitude!,
      group.longitude!,
    );
    double distanceInKm = distanceInMeters / 1000;
    return '${distanceInKm.toStringAsFixed(1)} km';
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
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
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
                  child: DropdownButtonFormField(
                    value: _sortBy,
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value.toString();
                        fetchGroups();
                      });
                    },
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'None', 
                        child: Text('Sort by name')),
                      DropdownMenuItem(
                          value: 'Distance',
                          child: Text('Sort by distance')),
                      DropdownMenuItem(
                          value: 'Points',
                          child: Text('Sort by points')),
                    ],
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
                      leading: OptionalImage(imageId: group.imageId),
                      title: Text(
                        group.name,
                        style: const TextStyle(
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(group.isPrivate ? 'Private' : 'Public'),
                          Text('Points: ${group.points}'),
                          if (_userPosition != null)
                            Text('Distance: ${getDistanceString(group)}'),
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
