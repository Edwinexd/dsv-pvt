import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application/components/my_textfield.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: const SafeArea(
            child: Center(
          child: Column(
            children: [
              SizedBox(height: 50),
              //logo
              Icon(
                Icons.person,
                size: 100,
              ),
                           
              SizedBox(height: 50),

              //welcome back, youve been missed
              Text(
                'Welcome back!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                )
              ),

              SizedBox(height: 25),

              // username textfield
              MyTextField(
                controller: usernameController,
                hintText: 'Username',
                obscureText: false,
              ),

              SizedBox(height: 10),
              
              //password textfield
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              //forgot password?

              //sign in button

              //or continue with

              //google + apple sign in
            ],
          ),
        )));
  }
}
