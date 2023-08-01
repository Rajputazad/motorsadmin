import 'package:flutter/material.dart';
// import 'package:motorsadmin/auth/auth2.dart';
// import 'package:motorsadmin/login/login.dart';
import 'package:motorsadmin/tools/menu.dart';

class Info extends StatefulWidget {
  const Info({super.key});
  @override
  State<Info> createState() => _Info();
}

class _Info extends State<Info> {
  // pop() {
  //   setState(() {
  //     Navigator.pushReplacement(
  //         context, MaterialPageRoute(builder: (context) => const Login()));
  //   });
  // }\
  late bool loding = true;
  @override
  void initState() {
    super.initState();
    _checkValidityAndNavigate();
  }

  Future<void> _checkValidityAndNavigate() async {
    setState(() {
      loding = false;
    });
    // bool isValid = await checkvailid();
    // if (!isValid) {
    //   // ignore: use_build_context_synchronously
    //  await Navigator.pushReplacement(
    //       context, MaterialPageRoute(builder: (context) => const Login()));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return loding
        ? Container(
            color: Colors.white,
            child: const Center(child: CircularProgressIndicator()))
        : Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 4, 12, 240),
              title: const Text("Information"),
            ),
            drawer: Drawer(
              child: MainDrawer(
                  isDashboardScreen: false,
                  isCarScreen: false,
                  isInfoScreen: true),
            ),
            body: const Center(child: Text("Information")),
          );
  }
}
