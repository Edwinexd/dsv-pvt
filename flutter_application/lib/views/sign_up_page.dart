import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/components/gradient_button.dart';
import 'package:flutter_application/components/my_textfield.dart';
import 'package:flutter_application/components/square_tile.dart';

import '../controllers/backend_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> registerUser() async {
    if (nameController.text.isEmpty ||
        usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please fill all the fields')));
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
      await BackendService().createUser(
          usernameController.text,
          emailController.text,
          nameController.text,
          passwordController.text);
    } on DioException catch (error) {
      if (error.response?.statusCode == 400) {
        // TODO This sort of parsing should be done in backend_service but not sure how to manipulate the error object
        String? errorDetail;
        if (error.response != null && error.response!.data != null) {
          final errorData = error.response!.data as Map<String, dynamic>?;
          errorDetail = errorData?['detail'];
        }
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorDetail ?? 'Invalid email or password')));
        
        Navigator.pop(context);
        return;
      }
    }

    Navigator.pop(context);
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
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: Divider(
                                color: Color.fromARGB(255, 16, 14, 99),
                                thickness: 0.5)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text('Or continue with',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 16, 14, 99))),
                        ),
                        Expanded(
                            child: Divider(
                                color: Color.fromARGB(255, 16, 14, 99),
                                thickness: 0.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SquareTile(imagePath: 'lib/images/google.png')
                      ]),
                  const SizedBox(height: 20),
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
