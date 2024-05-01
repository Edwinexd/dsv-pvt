import 'package:flutter/material.dart';
import 'package:flutter_application/forgot_password.dart';
import 'package:flutter_application/main.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('Sign In')),
        body: _isLoading ? CircularProgressIndicator() : Container(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _header(context),
                _inputField(context),
                _forgotPassword(context),
                _signup(context),
                _googleSignIn(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _header(context) {
    return const Text(
      "Enter your credentials to sign in",
      style: TextStyle(fontSize: 16),
    );
  }

  _inputField(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(labelText: "Email"),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(labelText: "Password"),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _signIn,
          child: const Text("Sign In"),
        )
      ],
    );
  }

  _forgotPassword(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ForgotPassword()),
        );
      },
      child: const Text("Forgot password?"),
    );
  }

  _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? "),
        TextButton(
            onPressed: () {
            },
            child: const Text("Sign Up")
        )
      ],
    );
  }

  _googleSignIn(context) {
    return TextButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.account_circle),
      label: const Text("Sign in with Google"),
    );
  }

  _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        // TODO: Here we Perform sign in operation and  If sign in succeeds, navigate to next page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email address or password.'),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}