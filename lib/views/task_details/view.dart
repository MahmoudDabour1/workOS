import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:workos/core/constant.dart';
import 'package:workos/core/services/global_method.dart';

import '../../core/widgets/comments.dart';

class TaskDetailsView extends StatefulWidget {
  final String taskId;
  final String uploadedBy;

  const TaskDetailsView(
      {Key? key, required this.taskId, required this.uploadedBy})
      : super(key: key);

  @override
  State<TaskDetailsView> createState() => _TaskDetailsViewState();
}

class _TaskDetailsViewState extends State<TaskDetailsView> {
  bool _isCommenting = false;

  var contentsInfo = TextStyle(
    fontSize: 15,
    color: Constants.darkBlue,
    fontWeight: FontWeight.normal,
  );

  final FirebaseAuth auth = FirebaseAuth.instance;
  String? authorName;
  String? authorPosition;
  String? userImageUrl;

  String? taskDescription;
  String? taskTitle;
  String? deadlineDate;
  String? postedDate;
  bool? isDone;
  bool? isDeadlineAvailable = false;
  bool? isLoading = false;
  Timestamp? postedDateTimeStamp;
  Timestamp? deadDateTimeStamp;
  final commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    isLoading = true;
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uploadedBy)
          .get();
      if (userDoc == null) {
        return;
      } else {
        setState(() {
          authorName = userDoc.get('name');
          authorPosition = userDoc.get('positionInCompany');
          userImageUrl = userDoc.get('image');
        });
      }
      final DocumentSnapshot taskDatabase = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskId)
          .get();
      if (taskDatabase == null) {
        return;
      } else {
        setState(() {
          isDone = taskDatabase.get('isDone');
          taskDescription = taskDatabase.get('taskDescription');
          postedDateTimeStamp = taskDatabase.get('createdAt');
          deadDateTimeStamp = taskDatabase.get('deadlineDateTimeStamp');
          deadlineDate = taskDatabase.get('deadlineDate');
          var postDate = postedDateTimeStamp!.toDate();
          postedDate = '${postDate.year}-${postDate.month}-${postDate.day}';
          var date = deadDateTimeStamp!.toDate();
          isDeadlineAvailable = date.isAfter(DateTime.now());
        });
      }
    } catch (error) {
      GlobalMethods.showErrorDialog(
          error: 'An error occured', context: context);
    } finally {
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Back',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 20,
              color: Constants.darkBlue,
            ),
          ),
        ),
      ),
      body: isLoading == true
          ? const Center(
              child: CircularProgressIndicator(
              strokeWidth: 10,
              color: Colors.pink,
            ))
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      taskTitle == null ? '' : taskTitle!,
                      style: TextStyle(
                        fontSize: 30,
                        color: Constants.darkBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'uploaded by',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Constants.darkBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 3,
                                        color: Colors.pink.shade800,
                                      ),
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: NetworkImage(userImageUrl == null
                                            ? 'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png'
                                            : userImageUrl!),
                                        fit: BoxFit.fill,
                                      )),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      authorName == null ? '' : authorName!,
                                      style: contentsInfo,
                                    ),
                                    Text(
                                      authorPosition == null
                                          ? ''
                                          : authorPosition!,
                                      style: contentsInfo,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(
                              thickness: 1,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Uploaded on:',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Constants.darkBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  postedDate == null ? '' : postedDate!,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Constants.darkBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Deadline date:',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Constants.darkBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  deadlineDate == null ? '' : deadlineDate!,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Center(
                              child: Text(
                                isDeadlineAvailable == true
                                    ? 'Still have enough time'
                                    : 'No time left',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.green,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(
                              thickness: 1,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Done state:',
                              style: TextStyle(
                                fontSize: 20,
                                color: Constants.darkBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Flexible(
                                    child: TextButton(
                                  onPressed: () {
                                    User? user = auth.currentUser;
                                    String uid = user!.uid;
                                    if (uid == widget.uploadedBy) {
                                      FirebaseFirestore.instance
                                          .collection('tasks')
                                          .doc(widget.taskId)
                                          .update({'isDone': true});
                                      getData();
                                    } else {
                                      GlobalMethods.showErrorDialog(
                                          error:
                                              'You can\'t perform this action',
                                          context: context);
                                    }
                                  },
                                  child: Text(
                                    'Done',
                                    style: TextStyle(
                                      fontSize: 15,
                                      decoration: isDone == true
                                          ? TextDecoration.underline
                                          : TextDecoration.none,
                                      color: Constants.darkBlue,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                )),
                                Opacity(
                                    opacity: isDone == true ? 1 : 0,
                                    child: const Icon(
                                      Icons.check_box,
                                      color: Colors.green,
                                    )),
                                const SizedBox(
                                  width: 40,
                                ),
                                Flexible(
                                  child: TextButton(
                                    onPressed: () {
                                      User? user = auth.currentUser;
                                      String uid = user!.uid;
                                      if (uid == widget.uploadedBy) {
                                        FirebaseFirestore.instance
                                            .collection('tasks')
                                            .doc(widget.taskId)
                                            .update({'isDone': false});
                                        getData();
                                      } else {
                                        GlobalMethods.showErrorDialog(
                                            error:
                                                'You can\'t perform this action',
                                            context: context);
                                      }
                                    },
                                    child: Text(
                                      'Not done',
                                      style: TextStyle(
                                        fontSize: 15,
                                        decoration: isDone == false
                                            ? TextDecoration.underline
                                            : TextDecoration.none,
                                        color: Constants.darkBlue,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                                Opacity(
                                  opacity: isDone == false ? 1 : 0,
                                  child: const Icon(
                                    Icons.check_box,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(
                              thickness: 1,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Task description:',
                              style: TextStyle(
                                fontSize: 20,
                                color: Constants.darkBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              taskDescription == null ? '' : taskDescription!,
                              style: TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                color: Constants.darkBlue,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              child: _isCommenting
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Flexible(
                                          flex: 3,
                                          child: TextField(
                                            controller: commentController,
                                            maxLength: 200,
                                            style: const TextStyle(),
                                            maxLines: 6,
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              enabledBorder:
                                                  const UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              errorBorder:
                                                  const UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.red,
                                                ),
                                              ),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.pink,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: MaterialButton(
                                                  onPressed: () async {
                                                    if (commentController
                                                            .text.length <
                                                        7) {
                                                      GlobalMethods.showErrorDialog(
                                                          error:
                                                              'Comment can\'t be less than 7 characteres',
                                                          context: context);
                                                    } else {
                                                      final generatedId =
                                                          const Uuid().v4();
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('tasks')
                                                          .doc(widget.taskId)
                                                          .update({
                                                        'taskComments':
                                                            FieldValue
                                                                .arrayUnion([
                                                          {
                                                            'userId': widget
                                                                .uploadedBy,
                                                            'commentId':
                                                                generatedId,
                                                            'name': authorName,
                                                            'commentBody':
                                                                commentController
                                                                    .text,
                                                            'time':
                                                                Timestamp.now(),
                                                            'userImageUrl':
                                                                userImageUrl,
                                                          }
                                                        ])
                                                      });
                                                      await Fluttertoast.showToast(
                                                          msg:
                                                              "Task has been uploaded successfully",
                                                          toastLength:
                                                              Toast.LENGTH_LONG,
                                                          gravity: ToastGravity
                                                              .BOTTOM,
                                                          timeInSecForIosWeb: 1,
                                                          backgroundColor:
                                                              Colors.pink,
                                                          textColor:
                                                              Colors.white,
                                                          fontSize: 20.0);
                                                      commentController.clear();
                                                      setState(() {});
                                                    }
                                                  },
                                                  color: Colors.pink.shade700,
                                                  elevation: 10,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            13),
                                                    side: BorderSide.none,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: const [
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 14),
                                                        child: Text(
                                                          "Post",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            // fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _isCommenting =
                                                          !_isCommenting;
                                                    });
                                                  },
                                                  child: const Text('Cancel'))
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : Center(
                                      child: MaterialButton(
                                        onPressed: () {
                                          setState(() {
                                            _isCommenting = !_isCommenting;
                                          });
                                        },
                                        color: Colors.pink.shade700,
                                        elevation: 10,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(13),
                                          side: BorderSide.none,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 14),
                                              child: Text(
                                                "Add a comment",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  // fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('tasks')
                                    .doc(widget.taskId)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.pink,
                                        strokeWidth: 10,
                                      ),
                                    );
                                  } else {
                                    if (snapshot.data == null) {
                                      return Container();
                                    }
                                  }
                                  return ListView.separated(
                                      reverse: true,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return CommentWidget(
                                          commentBody:
                                              snapshot.data!['taskComments']
                                                  [index]['commentBody'],
                                          commenterId:
                                              snapshot.data!['taskComments']
                                                  [index]['userId'],
                                          commenterName:
                                              snapshot.data!['taskComments']
                                                  [index]['name'],
                                          commentImageUrl:
                                              snapshot.data!['taskComments']
                                                  [index]['userImageUrl'],
                                          commentId:
                                              snapshot.data!['taskComments']
                                                  [index]['commentId'],
                                        );
                                      },
                                      separatorBuilder: (context, index) {
                                        return const Divider(
                                          thickness: 1,
                                        );
                                      },
                                      itemCount: snapshot
                                          .data!['taskComments'].length);
                                })
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
