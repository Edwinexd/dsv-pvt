import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/models/achievement.dart';
import 'package:flutter_application/models/user.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:fuzzywuzzy/model/extracted_result.dart';
import 'package:share_plus/share_plus.dart';

class UserSelector extends StatefulWidget {
  final Function(User) onUserSelected;
  final String? finishSelectionText;
  final Function(List<User>)? onCompleted;

  UserSelector({Key? key, required this.onUserSelected, this.finishSelectionText, this.onCompleted}) : super(key: key);

  @override
  State<UserSelector> createState() => _UserSelectorState();
}

class _UserSelectorState extends State<UserSelector> {
  List<User> allUsers = [];
  List<User> displayedUsers = [];
  List<User> selectedUsers = [];
  String searchQuery = '';

  Future<void> _populateUsers() async {
    List<User> users = await BackendService().getUsers(0, 500);
    setState(() {
      allUsers = users;
    });
  }
  
  @override
  void initState() {
    super.initState();
    unawaited(_populateUsers());
  }

  @override
  Widget build(BuildContext context) {
    displayedUsers = [];
    List<ExtractedResult<User>> topFullName = extractTop(query: searchQuery, choices: allUsers, limit: 15, getter: (User user) => user.fullName);
    List<ExtractedResult<User>> topUsername = extractTop(query: searchQuery, choices: allUsers, limit: 15, getter: (User user) => user.userName);

    List<ExtractedResult<User>> topResults = [...topFullName, ...topUsername];
    // remove duplicates and keep the highest score
    topResults = topResults.map((e) => e.choice.id).toSet().map((e) => topResults.where((user) => user.choice.id == e).reduce((value, element) => value.score > element.score ? value : element)).toList();
    // Need to resort as we wen't via a set that might be unordered
    topResults.sort((a, b) => b.score.compareTo(a.score));

    displayedUsers = topResults.map((e) => e.choice).toList();

    

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select User'),
        centerTitle: true,
      ),
      body: DefaultBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search for a user',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: displayedUsers.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(displayedUsers[index].fullName),
                    subtitle: Text(displayedUsers[index].userName),
                    leading: selectedUsers.contains(displayedUsers[index]) ? Icon(Icons.check) : null,
                    onTap: () {
                      if (selectedUsers.contains(displayedUsers[index])) {
                        selectedUsers.remove(displayedUsers[index]);
                      } else {
                        selectedUsers.add(displayedUsers[index]);
                      }
                      setState(() {});
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}
