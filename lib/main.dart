import 'package:flutter/material.dart';
// import 'package:motorsadmin/app/home.dart';
import 'package:motorsadmin/login/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Motors Admin",
      home: Login(),
    );
  }
}
