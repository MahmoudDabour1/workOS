import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workos/views/all_workers/view.dart';
import 'package:workos/views/home/view.dart';
import 'package:workos/views/profile/view.dart';
import 'package:workos/views/user_state/view.dart';

import '../../views/add_task/view.dart';
import '../constant.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.cyan,
              ),
              child: Column(
                children: [
                  Flexible(
                    child: Image.network(
                        'https://cdn-icons-png.flaticon.com/512/3067/3067260.png'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Flexible(
                    child: Text(
                      'work OS Arabic',
                      style: TextStyle(
                        color: Constants.darkBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              )),
          const SizedBox(
            height: 30,
          ),
          _listTiles(
            label: "All tasks",
            fct: () {
              navigateToTaskScreen(context);
            },
            icon: Icons.task_outlined,
          ),
          _listTiles(
            label: "My account",
            fct: () {
              navigateToProfileScreen(context);
            },
            icon: Icons.settings_outlined,
          ),
          _listTiles(
            label: "Registered workers",
            fct: () {
              navigateToAllWorkerScreen(context);
            },
            icon: Icons.workspaces_outline,
          ),
          _listTiles(
            label: "Add task",
            fct: () {
              navigateToAddTaskScreen(context);
            },
            icon: Icons.add_task_outlined,
          ),
          const Divider(
            thickness: 1,
          ),
          _listTiles(
            label: "Logout",
            fct: () {
              logOut(context);
            },
            icon: Icons.logout_outlined,
          ),
        ],
      ),
    );
  }

  void navigateToProfileScreen(context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user!.uid;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  ProfileView(userID:uid,)),
    );
  }

  void navigateToAllWorkerScreen(context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AllWorkersView()),
    );
  }

  void navigateToAddTaskScreen(context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskView()),
    );
  }

  void navigateToTaskScreen(context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TaskView()),
    );
  }

  void logOut(context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: const [
                Icon(
                  Icons.login_outlined,
                  color: Colors.red,
                  size: 20,
                ),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text('Sign out'),
                )
              ],
            ),
            content: Text(
              'Do you wanna Sign out',
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
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await auth.signOut();
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const UserState(),
                    ),
                  );
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

  Widget _listTiles(
      {required String label, required Function fct, required IconData icon}) {
    return ListTile(
      onTap: () {
        fct();
      },
      leading: Icon(
        icon,
        color: Constants.darkBlue,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: Constants.darkBlue,
          fontSize: 20,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
