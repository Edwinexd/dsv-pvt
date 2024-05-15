import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'bars.dart'; // Import bars.dart

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  TextEditingController _searchController = TextEditingController();
  List<String> _filteredFriendsList = [];

  @override
  void initState() {
    super.initState();
    _filteredFriendsList.addAll(_friendsList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: 'Friends',
        context: context,
        showBackButton: false,
      ),
      body: DefaultBackground(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Friends',
                  /*Will be displayed total number of friends*/
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchTextChanged,
                  decoration: const InputDecoration(
                    labelText: 'Search friends...',
                    suffixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredFriendsList.length,
              itemBuilder: (context, index) {
                final friend = _filteredFriendsList[index];

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2.0),
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      //placeholder for users profile picture
                      child: Icon(Icons.person),
                    ),
                    title: Text(friend),
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

  void _onSearchTextChanged(String value) {
    setState(() {
      _filteredFriendsList = _friendsList
          .where((friend) => friend.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }
}

//Instance friends list
final List<String> _friendsList = [];
