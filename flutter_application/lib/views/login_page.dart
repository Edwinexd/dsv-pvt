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
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/components/custom_divider.dart';
import 'package:flutter_application/components/my_button.dart';
import 'package:flutter_application/components/my_textfield.dart';
import 'package:flutter_application/components/sign_in_button.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/controllers/health.dart';
import 'package:flutter_application/forgot_password.dart';
import 'package:flutter_application/main.dart';
import 'package:flutter_application/views/sign_up_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  final bool darkModeEnabled;
  final ValueChanged<bool> onToggleDarkMode;

  LoginPage({
    Key? key,
    required this.darkModeEnabled,
    required this.onToggleDarkMode,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final BackendService _backendService = BackendService();
  late GoogleSignIn _googleSignIn;

  @override
  void initState() {
    super.initState();
    _googleSignIn = _getGoogleSignIn();
    _googleSignIn.onCurrentUserChanged.listen(onGoogleCurrentUserChanged);
    // _googleSignIn.signInSilently();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  GoogleSignIn _getGoogleSignIn() {
    if (kIsWeb) {
      return GoogleSignIn(
        clientId: dotenv.env['GOOGLE_WEB_CLIENT_ID']!,
        scopes: [
          'email',
        ],
      );
    }
    if (Platform.isAndroid) {
      return GoogleSignIn(
        scopes: [
          'email',
        ],
      );
    }
    if (Platform.isIOS || Platform.isMacOS) {
      return GoogleSignIn(
        clientId: dotenv.env['GOOGLE_APPLE_CLIENT_ID']!,
        scopes: [
          'email',
        ],
      );
    }
    throw Exception('Unsupported platform');
  }

  Future<void> signUserIn() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await _backendService.login(email, password);
    } on DioException catch (error) {
      if (error.response?.statusCode == 401 ||
          error.response?.statusCode == 403) {
        // TODO This sort of parsing should be done in backend_service but not sure how to manipulate the error object
        String? errorDetail;
        if (error.response != null && error.response!.data != null) {
          final errorData = error.response!.data as Map<String, dynamic>?;
          errorDetail = errorData?['detail'];
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(errorDetail ?? 'Invalid email or password')));

        Navigator.pop(context);
        return;
      }
      rethrow;
    }

    await _backendService.getMe();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MainPage(
                  darkModeEnabled: widget.darkModeEnabled,
                  onToggleDarkMode: widget.onToggleDarkMode,
                )));
  }

  Future<void> onGoogleCurrentUserChanged(GoogleSignInAccount? account) async {
    if (account == null) {
      return;
    }

    final GoogleSignInAuthentication googleAuthentication =
        await account.authentication;

    try {
      await _backendService.loginOauthGoogle(
          googleAuthentication.accessToken, googleAuthentication.idToken);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        // TODO Handle user not having account with that email and send them to sign up / display error
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not found, please sign up')));
        return;
      }
      rethrow;
    }

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MainPage(
                  darkModeEnabled: widget.darkModeEnabled,
                  onToggleDarkMode: widget.onToggleDarkMode,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 171, 171, 252),
              Color.fromARGB(255, 180, 125, 252),
              Color.fromARGB(255, 210, 120, 252),
              Color.fromARGB(200, 238, 172, 252),
              Color.fromARGB(255, 253, 253, 255)
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Image.asset(
                    'lib/images/logga.png',
                    height: 200,
                    width: 200,
                  ),
                  const SizedBox(height: 10),
                  const Text('Welcome!',
                      style: TextStyle(
                          color: Color.fromARGB(255, 16, 14, 99),
                          fontSize: 16)),
                  const SizedBox(height: 25),
                  MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ForgotPassword()),
                            );
                          },
                          child: const Text('Forgot Password?',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 16, 14, 99))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  MyButton(
                    buttonText: 'Sign In with Email',
                    onTap: signUserIn,
                  ),
                  const SizedBox(height: 50),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomDivider(),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text('Or continue with Google',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 16, 14, 99))),
                        ),
                        Expanded(
                          child: CustomDivider(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildSignInButton(onPressed: () async {
                        try {
                          await _googleSignIn.signIn();
                        } catch (error) {
                          print(error);
                        }
                      })
                    ],
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Not a member?',
                          style: TextStyle(
                              color: Color.fromARGB(255, 16, 14, 99))),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpPage()),
                          );
                        },
                        child: const Text(
                          'Register Now',
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
