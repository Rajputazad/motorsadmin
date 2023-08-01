import 'package:flutter/material.dart';
import 'package:motorsadmin/app/home.dart';
import 'package:motorsadmin/auth/auth2.dart';
import 'package:motorsadmin/login/login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Auth auth = Auth();
  // bool isUserAuthenticated = await auth.home();
  //  print(isUserAuthenticated);
    await dotenv.load();

  runApp(const MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  
// final  bool auth;
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Motors Admin",
      home: FutureBuilder<bool>(
        future: checkvailid(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            if (snapshot.data == true) {
              return const Home();
            } else {
              return const Login();
            }
          }
        },
      ),
    );
  }
}
