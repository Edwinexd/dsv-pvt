/*
Lace Up & Lead The Way - A pre-race training app and social platform for runners.
Copyright (C) 2024 Group 71 (PVT 7.5) Stockholm University

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
*/
import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/views/generic_info_page.dart';
import 'package:flutter_application/views/login_page.dart';

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

  Future<void> signOut() async {
    await BackendService().logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage(darkModeEnabled: darkModeEnabled, onToggleDarkMode: widget.onToggleDarkMode)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Settings', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text(
              'Account Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A3068),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('Change password'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Implement change password functionality
              },
            ),
            SwitchListTile(
              title: const Text('Dark mode'),
              value: darkModeEnabled,
              activeColor: Color.fromARGB(255, 255, 92, 0),
              inactiveThumbColor: Colors.purple,
              inactiveTrackColor: Colors.purple[800],
              onChanged: (value) {
                setState(() {
                  darkModeEnabled = value;
                  widget.onToggleDarkMode(value);
                });
              },
            ),
            const SizedBox(height: 10),
            const Text(
              'More',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A3068),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('About us'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutUsPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Privacy policy'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Terms and conditions'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsAndConditionsPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Center(
                child: Text(
                  'SIGN OUT',
                  style: TextStyle(
                    //fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: signOut,
            ),
          ],
        ),
      ),
    );
  }
}

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const GenericInfoPage(
      title: 'About Us',
      content:
          'This app is designed for Middnatsloppet, a popular event for running enthusiasts. '
          'With this app, users can track their training progress, participate in events, '
          'connect with other runners, and more.',
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const GenericInfoPage(
      title: 'Privacy Policy',
      content:
          'Your privacy is important to us. This privacy policy explains how we handle your personal data and protect your privacy when you use our app.',
    );
  }
}

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const GenericInfoPage(
      title: 'Terms and Conditions',
      content:
          'By using this app, you agree to the following terms and conditions. Please read them carefully.',
    );
  }
}
