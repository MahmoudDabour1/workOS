import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workos/core/services/global_method.dart';
import 'package:workos/views/task_details/view.dart';

class TaskWidget extends StatefulWidget {
  final String taskTitle;
  final String taskDescription;
  final String taskId;
  final String uploadedBy;
  final bool isDone;

  const TaskWidget({
    Key? key,
    required this.taskTitle,
    required this.taskDescription,
    required this.taskId,
    required this.uploadedBy,
    required this.isDone,
  }) : super(key: key);

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {

  final FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  TaskDetailsView(uploadedBy:widget.uploadedBy ,taskId:widget.taskId ,)),
          );
        },
        onLongPress: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  actions: [
                    TextButton(
                      onPressed: () {
                        User? user = auth.currentUser;
                        String uid = user!.uid;
                        if(uid==widget.uploadedBy){
                          FirebaseFirestore.instance.collection('tasks').doc(widget.taskId).delete();
                          Navigator.pop(context);
                        }else{
                          GlobalMethods.showErrorDialog(error: 'You don\'t have access to delete this', context: context);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.pink[800],
                          ),
                          Text(
                            "Delete",
                            style: TextStyle(
                              color: Colors.pink[800],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              });
        },
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.only(right: 12),
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(width: 1),
            ),
          ),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 25,
            child: Image.network(
              widget.isDone
                  ? 'https://cdn-icons-png.flaticon.com/512/8683/8683794.png'
                  : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTnwT_gkLQ387V3YXuk9GQt7Bq6LViCA-Appw&usqp=CAU',
            ),
          ),
        ),
        title: Text(
            widget.taskTitle,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            )),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.linear_scale,
              color: Colors.pink.shade800,
            ),
            Text(
              widget.taskDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.keyboard_arrow_right,
          size: 30,
          color: Colors.pink[800],
        ),
      ),
    );
  }
}
