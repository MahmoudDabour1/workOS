import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workos/views/home/view.dart';
import 'package:workos/views/login/view.dart';

class UserState extends StatelessWidget {
  const UserState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context,userSnapshot){
      if(userSnapshot.data==null){
        return const LoginView();
      }else if(userSnapshot.hasData){
        return const TaskView();
      }
      else if(userSnapshot.hasError){
        return const Center(
          child: Text(
            'An error has been occured',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 40,
            ),
          ),
        );
      }
      return const Scaffold(
        body: Center(
          child: Text(
            'Something went wrong',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 40,
            ),
          ),
        ),
      );
    });
  }
}
