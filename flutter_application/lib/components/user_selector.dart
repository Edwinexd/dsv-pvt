import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/bars.dart';
import 'package:flutter_application/components/optional_image.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/controllers/backend_service_interface.dart';
import 'package:flutter_application/models/user.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:fuzzywuzzy/model/extracted_result.dart';

class UserSelector extends StatefulWidget {
  final Function(User) onUserSelected;
  final String? finishSelectionText;
  final String? navbarTitle;
  final Function(List<User>)? onCompleted;
  final BackendServiceInterface backendService;

  UserSelector({
    Key? key,
    required this.onUserSelected,
    this.finishSelectionText,
    this.navbarTitle,
    this.onCompleted,
    BackendServiceInterface? backendService,
  })  : backendService = backendService ?? BackendService(),
        super(key: key);

  @override
  State<UserSelector> createState() => _UserSelectorState();
}

class _UserSelectorState extends State<UserSelector> {
  List<User> allUsers = [];
  List<User> displayedUsers = [];
  List<User> selectedUsers = [];
  String searchQuery = '';

  Future<void> _populateUsers() async {
    List<User> users = await widget.backendService.getUsers(0, 500);
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
    List<ExtractedResult<User>> topFullName = extractTop(
        query: searchQuery,
        choices: allUsers,
        limit: 15,
        getter: (User user) => user.fullName);
    List<ExtractedResult<User>> topUsername = extractTop(
        query: searchQuery,
        choices: allUsers,
        limit: 15,
        getter: (User user) => user.userName);

    List<ExtractedResult<User>> topResults = [...topFullName, ...topUsername];
    // remove duplicates and keep the highest score
    // Aware of unnecessary complexity, but it's a small list (30 elements max)
    topResults = topResults
        .map((e) => e.choice.id)
        .toSet()
        .map((e) => topResults.where((user) => user.choice.id == e).reduce(
            (value, element) => value.score > element.score ? value : element))
        .toList();
    // Need to resort as we wen't via a set that might be unordered
    topResults.sort((a, b) => b.score.compareTo(a.score));

    displayedUsers = topResults.map((e) => e.choice).toList();

    return Scaffold(
      appBar: buildAppBar(
        title: 'Select user',
        context: context,
        showBackButton: true,
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
                return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  leading: OptionalImage(imageId: displayedUsers[index].imageId),
                  title: Text(displayedUsers[index].fullName),
                  subtitle: Text(displayedUsers[index].userName),
                  trailing: selectedUsers.contains(displayedUsers[index])
                    ? Icon(Icons.check)
                    : null,
                  onTap: () {
                  setState(() {
                    if (selectedUsers.contains(displayedUsers[index])) {
                    selectedUsers.remove(displayedUsers[index]);
                    } else {
                    selectedUsers.add(displayedUsers[index]);
                    widget.onUserSelected(displayedUsers[index]);
                    }
                  });
                  },
                ),
                );
              },
              ),
            ),
            selectedUsers.isEmpty
                ? Container()
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.check),
                      onPressed: () {
                        if (widget.onCompleted != null) {
                          widget.onCompleted!(selectedUsers);
                        }
                        Navigator.pop(context);
                      },
                      label: Text(
                          widget.finishSelectionText ?? 'Finish Selection'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 30.0),
                      ),
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
