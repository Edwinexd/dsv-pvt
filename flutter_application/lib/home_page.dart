import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultBackground( 
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            CountdownWidget(),
            SignupButton(),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFCFBAEA), 
              ),
              onPressed: () {},
              child: Text('Challenges'),
            ),
          ],
        ),
      ),
    );
  }
}

class CountdownWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final raceDate = DateTime(2024, 8, 17);
    final currentDate = DateTime.now();
    final difference = raceDate.difference(currentDate).inDays;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 90.0), 
      child: Container(
        width: double.infinity,
        color: Colors.deepOrange,
        padding: const EdgeInsets.all(10),
        child: Text(
          '$difference DAYS TO RACE',
          textAlign: TextAlign.center, 
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

class SignupButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 90.0), 
      child: Container(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, 
            ),
          ),
          onPressed: () async {
            const url = 'https://midnattsloppet.com/midnattsloppet-stockholm/';
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
          },
          child: const Text(
            'Sign up for midnattsloppet now!',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}