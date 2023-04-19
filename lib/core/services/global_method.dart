import 'package:flutter/material.dart';

import '../constant.dart';

class GlobalMethods{
  static void showErrorDialog({required String error,required BuildContext context}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: const [
                Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: 20,
                ),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text('Error occured'),
                )
              ],
            ),
            content: Text(
              error,
              style: TextStyle(
                  color: Constants.darkBlue,
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: const Text(
                  'Ok',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          );
        });
  }
}