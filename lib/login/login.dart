import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:motorsadmin/app/home.dart';
import 'package:motorsadmin/auth/token.dart';
import 'package:motorsadmin/tools/toaster.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _Login();
}

class _Login extends State<Login> {
  final apiurl = dotenv.get('API_URL');
  final login = dotenv.get('API_URL_LOGIN');
  final _formKey = GlobalKey<FormState>();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final logger = Logger();
  late bool loding = true;
  bool passwordVisible = false; // To toggle password visibility
  bool isLoading = false;
  @override
  void initState() {
    // check();
    super.initState();
  }

  bool _isFormValid() {
    // Validate the form using the _formKey
    return _formKey.currentState?.validate() ?? false;
  }

  @override
  void dispose() {
    mobileNumberController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }
  // void check() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   var sp = prefs.getString("token");
  //   logger.d(sp);
  //   if (sp!.isEmpty) {
  //     logger.d(sp.isEmpty);
  //   } else {
  //     // ignore: use_build_context_synchronously
  //     Navigator.push(
  //         context, MaterialPageRoute(builder: (context) => const Home()));
  //   }
  // }

  Future<void> loginUser() async {
    bool isConnected = await checkInternetConnectivity();

    if (isConnected) {
      setState(() {
        isLoading = true; // Set loading to true when login starts
      });
      // Replace with your actual API endpoint for login
      // check();
      final loginData = {
        'mobile': mobileNumberController.text.trim(),
        'password': passwordController.text,
      };
      var body = jsonEncode(loginData);
      // logger.d(body);
      var headers = {
        'Content-Type': 'application/json',
      };
      try {
        var url = Uri.parse(apiurl + login);
        final response = await http.post(url, headers: headers, body: body);
        // logger.d(response.body);
        if (response.statusCode == 200) {
          setState(() {
            isLoading = false;
          });
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final String token = responseData['token'];
          await TokenManager.setToken("Bearer $token");
          // ignore: use_build_context_synchronously
          showToast(context, Colors.green, responseData["message"]);
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const Home())); // Replace '/home' with your home page route
        } else {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          setState(() {
            isLoading = false;
          });

          // ignore: use_build_context_synchronously
          showToast(context, Colors.red, responseData["message"]);
        }
      } catch (e) {
        // Error occurred during login
        // ignore: use_build_context_synchronously
        showToast(context, Colors.red, e.toString());
        setState(() {
          isLoading = false;
        });
        logger.d('Error: $e');
      }
    } else {
      // ignore: use_build_context_synchronously
      showToast(
          context, Colors.red, "Check your internet connection and try again");
    }
  }

  String? validateMobileNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required.';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FC), // Suitable background color
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
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
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Log in to continue',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32.0),
                  SizedBox(
                    height: 80.0,
                    child: TextFormField(
                      controller: mobileNumberController,
                      keyboardType:
                          TextInputType.phone, // Show numeric keyboard
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText:
                            'Mobile Number', // Label for mobile number input
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: validateMobileNumber,
                    ),
                  ),
                  // const SizedBox(height: 16.0),
                  SizedBox(
                    height: 80.0,
                    child: TextFormField(
                      validator: validatePassword,
                      controller: passwordController,
                      obscureText:
                          !passwordVisible, // Toggle password visibility
                      decoration: InputDecoration(
                        labelText: 'Password', // Label for password input
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Show/hide password icon based on passwordVisible
                            passwordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              passwordVisible =
                                  !passwordVisible; // Toggle visibility on tap
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  // const SizedBox(height: 32.0),
                  ElevatedButton(
                    onPressed: () {
                      // loginUser();
                      isLoading || !_isFormValid() ? null : loginUser();
                      // Implement login functionality with mobile number and password
                    },
                    child: isLoading
                        ? LoadingAnimationWidget.prograssiveDots(
                            // LoadingAnimationwidget that call the
                            color: const Color.fromARGB(255, 255, 255,
                                255), // staggereddotwave animation
                            size: 35,
                          )
                        : const Text('LOGIN'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
