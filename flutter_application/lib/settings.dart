import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final ValueChanged<bool> onToggleDarkMode;
  final bool initialDarkMode;

  const SettingsPage({
    Key? key,
    required this.onToggleDarkMode,
    required this.initialDarkMode,
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    darkModeEnabled = widget.initialDarkMode;
  }

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
                  darkModeEnabled = value;
                  widget.onToggleDarkMode(value);
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Clear Cache'),
            onTap: () {
            },
          ),
          ListTile(
            title: const Text('Notification Settings'),
            onTap: () {
            },
          ),
          ListTile(
            title: const Text('About App'),
            onTap: () {
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
              'Middnatsloppet Now',
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
