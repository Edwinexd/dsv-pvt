import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkModeEnabled = false; // Track dark mode state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  darkModeEnabled = value; // Update dark mode state
                  // Implement dark mode theme change here
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Clear Cache'),
            onTap: () {
              // Implement clear cache functionality
            },
          ),
          ListTile(
            title: const Text('Notification Settings'),
            onTap: () {
              // Navigate to notification settings page
            },
          ),
          ListTile(
            title: const Text('Font Size Adjustments'),
            onTap: () {
              // Navigate to font size settings page
            },
          ),
          ListTile(
            title: const Text('About App'),
            onTap: () {
              // Navigate to About App page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutAppPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About App'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Middnatsloppet App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'This app is designed for Middnatsloppet, a popular event for running enthusiasts. '
              'With this app, users can track their training progress, participate in events, '
              'connect with other runners, and more.',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
