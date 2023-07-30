import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _Login();
}

class _Login extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FC), // Suitable background color
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 80.0),
                // SvgPicture.asset(
                //   'assets/logo.svg', // Replace this with the path to your logo SVG file
                //   height: 120.0,
                // ),
                const SizedBox(height: 32.0),
                const Text(
                  'Welcome back!',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Log in to continue',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32.0),
                TextFormField(
                  keyboardType: TextInputType.phone, // Show numeric keyboard
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number', // Label for mobile number input
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password', // Label for password input
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: () {
                    // Implement login functionality with mobile number and password
                  },
                  child: const Text('LOGIN'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
