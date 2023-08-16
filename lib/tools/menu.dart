import 'package:flutter/material.dart';
import 'package:motorsadmin/app/home.dart';
import 'package:motorsadmin/app/info.dart';
import 'package:motorsadmin/auth/token.dart';
import 'package:motorsadmin/login/login.dart';
import 'package:motorsadmin/tools/dailog2.dart';

// ignore: must_be_immutable
class MainDrawer extends StatefulWidget {
  late bool isDashboardScreen;
  late bool isCarScreen;
  late bool isInfoScreen;
  MainDrawer(
      {super.key,
      required this.isDashboardScreen,
      required this.isCarScreen,
      required this.isInfoScreen});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  Color color = Colors.white10;
  Color active = const Color.fromARGB(255, 202, 199, 199);
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // ignore: avoid_unnecessary_containers
          Container(
            // color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Text(
                  //   "Gajanand motors",
                  //   style: TextStyle(
                  //     fontSize: 25.0,
                  //     fontWeight: FontWeight.w500,
                  //     color: Colors.blue[300],
                  //   //textAlign: TextAlign.left,
                  //   ),
                  // ),
                  SizedBox(
                    height: 140,
                    child: ClipRRect(
                      child: Image.network(
                          "https://ik.imagekit.io/b4x27zdza/Uday_Motors/logo4.png?updatedAt=1692080640756"),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          ListTile(
            tileColor: widget.isDashboardScreen ? active : color,
            onTap: () {
              setState(() {
                // if (!widget.isDashboardScreen) {
                // Navigator.pop(context); //
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const Home()));
                // print(widget.isDashboardScreen);
                // }
              });
            },
            leading: const Icon(
              Icons.inbox,
              color: Colors.black,
            ),
            // trailing: const Text(
            //   "99+"
            // ),
            title: const Text("Dashboard"),
          ),
          ListTile(
            tileColor: widget.isInfoScreen ? active : color,
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Info()));
              // Navigator.pushNamed(context, '/'); // Navigate to the dashboard screen
            },
            leading: const Icon(
              Icons.star_border,
              color: Colors.black,
            ),
            title: const Text("Information"),
          ),
          ListTile(
            onTap: () async {
              var title = "Logout?";
              var message = "Do you want to log out?";
              dynamic res = await dialog2(context, title, message);
              if (res == true) {
                await TokenManager.removeToken();
                // ignore: use_build_context_synchronously
                await Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const Login()));
              }
            },
            leading: const Icon(
              Icons.logout,
              color: Colors.black,
            ),
            title: const Text("Logout"),
          ),
          // ListTile(
          //   onTap: () {},
          //   leading: const Icon(
          //     Icons.label_important,
          //     color: Colors.black,
          //   ),
          //   title: const Text("Important"),
          // ),
          // ListTile(
          //   onTap: () {},
          //   leading: const Icon(
          //     Icons.inbox,
          //     color: Colors.black,
          //   ),
          //   title: const Text("draft"),
          // ),
          // ListTile(
          //   onTap: () {},
          //   leading: const Icon(
          //     Icons.inbox,
          //     color: Colors.black,
          //   ),
          //   title: const Text("sent"),
          // )
        ],
      ),
    );
  }
}
