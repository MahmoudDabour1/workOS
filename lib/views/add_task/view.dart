import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:workos/core/constant.dart';
import 'package:workos/core/services/global_method.dart';
import 'package:workos/core/widgets/drawer.dart';

class AddTaskView extends StatefulWidget {
  const AddTaskView({Key? key}) : super(key: key);

  @override
  State<AddTaskView> createState() => _AddTaskViewState();
}

class _AddTaskViewState extends State<AddTaskView> {
  final categoryController = TextEditingController(text: 'Task Category');
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final deadlineController = TextEditingController(text: 'pick up a date');
  final formKey = GlobalKey<FormState>();
  DateTime? picked;
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isLoading = false;
  Timestamp? deadlineDateTimeStamp;

  @override
  void dispose() {
    categoryController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    deadlineController.dispose();
    super.dispose();
  }

  void upload() async{
    User? user = auth.currentUser;
    String uid = user!.uid;
    final isValid = formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      if(deadlineController.text=='pick up a date'||categoryController.text=='Task Category'){
        GlobalMethods.showErrorDialog(error: 'Please pick up everything', context: context);
        return;
      }
      setState((){
        isLoading = true;
      });
      final taskID = const Uuid().v4();
      try{
        await FirebaseFirestore.instance.collection('tasks').doc(taskID).set({
          'taskId':taskID,
          'uploadedBy':uid,
          'taskTitle':titleController.text,
          'taskDescription':descriptionController.text,
          'deadlineDate':deadlineController.text,
          'deadlineDateTimeStamp':deadlineDateTimeStamp,
          'taskCategory':categoryController.text,
          'taskComments':[],
          'isDone':false,
          'createdAt':Timestamp.now(),
        });
        Fluttertoast.showToast(
            msg: "Task has been uploaded successfully",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.pink,
            textColor: Colors.white,
            fontSize: 20.0
        );
        descriptionController.clear();
        titleController.clear();
        setState((){
          categoryController.text = 'Task Category';
          deadlineController.text='pick up a date';
        });
      }finally{
        setState((){
          isLoading = false;
        });
      }

    } else {
      print('Form unValid');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(
          color: Constants.darkBlue,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      drawer: const DrawerWidget(),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 8,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'All field are required',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Constants.darkBlue,
                      ),
                    ),
                  ),
                ),
                const Divider(
                  thickness: 1,
                ),
                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      textWidget(textLabel: "Task category*"),
                      textFormField(
                        valueKey: 'Task category',
                        controller: categoryController,
                        enabled: false,
                        fct: () {
                          showTaskCategoryDialog(size);
                        },
                        maxLength: 100,
                      ),
                      textWidget(textLabel: "Task title*"),
                      textFormField(
                        valueKey: 'Task title',
                        controller: titleController,
                        enabled: true,
                        fct: () {},
                        maxLength: 100,
                      ),
                      textWidget(textLabel: "Task Description*"),
                      textFormField(
                        valueKey: 'TaskDescription',
                        controller: descriptionController,
                        enabled: true,
                        fct: () {},
                        maxLength: 1000,
                      ),
                      textWidget(textLabel: "Task Deadline date*"),
                      textFormField(
                        valueKey: 'DeadlineDate',
                        controller: deadlineController,
                        enabled: false,
                        fct: () {
                          pickDate();
                        },
                        maxLength: 1000,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: isLoading?const CircularProgressIndicator(color: Colors.pink,):MaterialButton(
                            onPressed: upload,
                            color: Colors.pink.shade700,
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                              side: BorderSide.none,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 14),
                                  child: Text(
                                    "Upload",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.upload_file,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void pickDate() async {
    picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(
        const Duration(days: 0),
      ),
      lastDate: DateTime(2100),
    );
    if(picked != null){
      setState(() {
        deadlineDateTimeStamp = Timestamp.fromMicrosecondsSinceEpoch(picked!.microsecondsSinceEpoch);
        deadlineController.text =
        '${picked!.year}-${picked!.month}-${picked!.day}';
      });
    }

  }

  void showTaskCategoryDialog(size) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Task category',
              style: TextStyle(
                color: Colors.pink[300],
                fontSize: 20,
              ),
            ),
            content: SizedBox(
              // width: size.width * 0.9 ,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: Constants.taskCategoryList.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          categoryController.text =
                              Constants.taskCategoryList[index];
                        });
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.red[200],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              Constants.taskCategoryList[index],
                              style: TextStyle(
                                color: Constants.darkBlue,
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: const Text('Close'),
              ),
            ],
          );
        });
  }

  textWidget({required String textLabel}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        textLabel,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.pink[800],
        ),
      ),
    );
  }

  textFormField({
    required valueKey,
    required TextEditingController controller,
    required bool enabled,
    required Function fct,
    required int maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          fct();
        },
        child: TextFormField(
          controller: controller,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Field is missing';
            }
            return null;
          },
          enabled: enabled,
          maxLines: valueKey == 'TaskDescription' ? 3 : 1,
          maxLength: maxLength,
          style: TextStyle(
            color: Constants.darkBlue,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            fontSize: 18,
          ),
          key: ValueKey(valueKey),
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.red,
                ),
              ),
              focusedErrorBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.red,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.pink.shade800),
              )),
        ),
      ),
    );
  }
}
