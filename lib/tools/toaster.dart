// ignore: file_names
import 'package:flutter/material.dart';

void showToast(BuildContext context,Color color,String text) {
  // var colors = "blue";
  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(
      content:  Text(text),
      backgroundColor: color,
      action: SnackBarAction(
          label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar,
          textColor: const Color.fromARGB(255, 255, 255, 255),
          ),
           
    ),
  );
}
