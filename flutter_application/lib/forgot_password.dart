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
import 'package:flutter_application/components/my_button.dart';
import 'package:flutter_application/home_page.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _validateAndSubmit() async {
    if (_validateAndSave()) {
      // TODO: Call your authentication service's method to send a password reset email
      // After the email has been sent, navigate to the reset code page
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ResetCodePage(email: emailController.text)),
      );
    } else {
      // TODO: Show an error message if the email is not in the database
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Forgot Password', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text('Please enter your email to reset the password'),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Your Email'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    }
                    // TODO: Add more email validation logic here
                    return null;
                  },
                  onSaved: (value) => emailController.text = value!,
                ),
                const SizedBox(height: 16.0),
                MyButton( 
                  onTap: _validateAndSubmit,
                  buttonText: 'Reset Password',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResetCodePage extends StatefulWidget {
  final String email;

  ResetCodePage({required this.email});

  @override
  _ResetCodePageState createState() => _ResetCodePageState();
}

class _ResetCodePageState extends State<ResetCodePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController resetCodeController = TextEditingController();

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _validateAndSubmit() async {
    if (_validateAndSave()) {
      // TODO: Call your authentication service's method to verify the reset code
      // After the code has been verified, navigate to the new password page
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NewPasswordPage(email: widget.email)),
      );
    } else {
      // TODO: Show an error message if the code is incorrect
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Check your email'),
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('We sent a reset link to ${widget.email}'),
                const Text(
                    'Enter the 5-digit code that was mentioned in the email'),
                TextFormField(
                  controller: resetCodeController,
                  decoration: const InputDecoration(labelText: '5-digit code'),
                  validator: (value) {
                    if (value!.isEmpty || value.length != 5) {
                      return 'Please enter the 5-digit code';
                    }
                    // TODO: Add more code validation logic here
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                MyButton( 
                  onTap: _validateAndSubmit,
                  buttonText: 'Verify Code',
                ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    // TODO: Resend the email
                  },
                  child: const Text('Haven’t got the email yet? Resend email'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NewPasswordPage extends StatefulWidget {
  final String email;

  NewPasswordPage({required this.email});

  @override
  _NewPasswordPageState createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _validateAndSubmit() async {
    if (_validateAndSave()) {
      // TODO: Call your authentication service's method to reset the password
      // After the password has been reset, navigate to the main page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('New Password'),
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(labelText: 'New Password'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your new password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration:
                      const InputDecoration(labelText: 'Confirm Password'),
                  validator: (value) {
                    if (value != newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                MyButton(
                  onTap: _validateAndSubmit,
                  buttonText: 'Confirm',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
