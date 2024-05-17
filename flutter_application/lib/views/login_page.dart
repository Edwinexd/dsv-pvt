import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/components/custom_divider.dart';
import 'package:flutter_application/components/my_button.dart';
import 'package:flutter_application/components/my_textfield.dart';
import 'package:flutter_application/components/sign_in_button.dart';
import 'package:flutter_application/controllers/backend_service.dart';
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
  final TextEditingController usernameController = TextEditingController();
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
  
  GoogleSignIn _getGoogleSignIn() {
    if (kIsWeb) {
      return GoogleSignIn(
        clientId:
            dotenv.env['GOOGLE_WEB_CLIENT_ID']!,
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
        clientId:
            dotenv.env['GOOGLE_APPLE_CLIENT_ID']!,
        scopes: [
          'email',
        ],
      );
    }
    throw Exception('Unsupported platform');
  }

  Future<void> signUserIn() async {
    final String email = usernameController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      // TODO: Handle email and password is empty
      return;
    }

    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    await _backendService.login(email, password);

    if (_backendService.token == null) {
      // TODO: Handle login failure
      return;
    }

    await _backendService.getMyUser();

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

    final GoogleSignInAuthentication googleAuthentication = await account.authentication;

    try {
      await _backendService.loginOauthGoogle(googleAuthentication.accessToken, googleAuthentication.idToken);
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Icon(Icons.person,
                    size: 100, color: Color.fromARGB(255, 16, 14, 99)),
                const SizedBox(height: 40),
                const Text('Welcome!',
                    style: TextStyle(
                        color: Color.fromARGB(255, 16, 14, 99), fontSize: 16)),
                const SizedBox(height: 25),
                MyTextField(
                  controller: usernameController,
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
                  buttonText: 'Sign In',
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
                        child: Text('Or continue with',
                            style: TextStyle(
                                color: Color.fromARGB(255, 16, 14, 99))),
                      ),
                      Expanded(
                        child: CustomDivider(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildSignInButton(
                      onPressed: () async {
                        try {
                          await _googleSignIn.signIn();
                        } catch (error) {
                          print(error);
                        }
                      }
                    )
                  ],
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not a member?',
                        style:
                            TextStyle(color: Color.fromARGB(255, 16, 14, 99))),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        );
                      },
                      child: const Text(
                        'Register Now',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
