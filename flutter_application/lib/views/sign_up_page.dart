import 'package:flutter/material.dart';
import 'package:flutter_application/components/gradient_button.dart';
import 'package:flutter_application/components/my_textfield.dart';
import 'package:flutter_application/components/square_tile.dart';
import 'package:flutter_application/create_profile_page.dart';

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
  final BackendService _backendService = BackendService();

  Future<void> registerUser() async {
    final String name = nameController.text.trim();
    final String username = usernameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (name.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      // TODO: Handle bad input
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

    await _backendService.createUser(username, email, name, password);

    // Intentionally want to disallow swipe back to login page
    Navigator.pop(context);

    Navigator.push(
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
