import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workos/views/user_state/view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase.initializeApp();
  runApp(  MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({Key? key}) : super(key: key);
   final Future<FirebaseApp> appInitialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: appInitialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return  const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: Text(
                    'App is loading',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50),
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return  const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: Text(
                    'An error has been occured',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                    ),
                  ),
                ),
              ),
            );
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter WordOs Arabic',
            theme: ThemeData(
              scaffoldBackgroundColor: const Color(0XFFEDE7DC),
              primarySwatch: Colors.blue,
            ),
            home: const UserState(),
          );
        }
        );
  }
}
