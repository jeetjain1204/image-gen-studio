import 'package:flutter/material.dart';

void mySnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text.toString().trim(),
        style: const TextStyle(color: Color.fromARGB(255, 240, 252, 255)),
      ),
      elevation: 2,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      dismissDirection: DismissDirection.down,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
