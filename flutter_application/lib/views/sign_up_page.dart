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
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/components/gradient_button.dart';
import 'package:flutter_application/components/my_textfield.dart';
import 'package:flutter_application/components/square_tile.dart';
import 'package:flutter_application/controllers/backend_service_interface.dart';
import 'package:flutter_application/create_profile_page.dart';

import '../controllers/backend_service.dart';

class SignUpPage extends StatefulWidget {
  final BackendServiceInterface backendService;

  SignUpPage({
    Key? key,
    BackendServiceInterface? backendService,
  })  : backendService = backendService ?? BackendService(),
        super(key: key);


  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  static final EMAIL_REGEX = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> registerUser() async {
    final String name = nameController.text.trim();
    final String username = usernameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (name.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all the fields')));
      return;
    }
    // Validate email
    if (!EMAIL_REGEX.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid email')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await widget.backendService.createUser(username, email, name, password);
    } on DioException catch (error) {
      if (error.response!.statusCode! >= 400 && error.response!.statusCode! < 500) { 
        // TODO This sort of parsing should be done in backend_service but not sure how to manipulate the error object
        String? errorDetail;
        if (error.response != null && error.response!.data != null) {
          final errorData = error.response!.data as Map<String, dynamic>?;
          errorDetail = errorData?['detail'];
        }
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorDetail ?? 'Email unavailable')));
        
        Navigator.pop(context);
        return;
      }
      rethrow;
    }

    // Intentionally want to disallow swipe back
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CreateProfilePage(forced: true)),
    );
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_pin,
                      size: 100, color: Color.fromARGB(255, 16, 14, 99)),
                  const SizedBox(height: 20),
                  const Text('Sign Up',
                      style: TextStyle(
                          color: Color.fromARGB(255, 16, 14, 99),
                          fontSize: 24)),
                  const SizedBox(height: 20),
                  MyTextField(
                      controller: nameController,
                      hintText: 'Full Name',
                      obscureText: false),
                  const SizedBox(height: 10),
                  MyTextField(
                      controller: usernameController,
                      hintText: 'Username',
                      obscureText: false),
                  const SizedBox(height: 10),
                  MyTextField(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false),
                  const SizedBox(height: 10),
                  MyTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true),
                  const SizedBox(height: 20),
                  GradientButton(
                    buttonText: "Create account",
                    onTap: registerUser,
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?',
                          style: TextStyle(
                              color: Color.fromARGB(255, 16, 14, 99))),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(' Sign In',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold)),
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
