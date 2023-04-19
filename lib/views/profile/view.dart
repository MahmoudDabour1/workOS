import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workos/core/constant.dart';

import '../../core/services/global_method.dart';
import '../../core/widgets/drawer.dart';
import '../user_state/view.dart';

class ProfileView extends StatefulWidget {
  final String userID;
  const ProfileView({Key? key, required this.userID}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  var titleTextStyle = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.normal,
  );

  bool isLoading = false;
  String phoneNumber = "";
  String email = "";
  String name = "";
  String job = "";
  String? imageUrl;
  String joinedAt = "";
  bool isSameUser = false;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    isLoading = true;
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userID)
          .get();
      if (userDoc == null) {
        return;
      } else {
        setState(() {
          email = userDoc.get('email');
          name = userDoc.get('name');
          phoneNumber = userDoc.get('phoneNumber');
          job = userDoc.get('positionInCompany');
          imageUrl = userDoc.get('image');
          Timestamp joinedAtTimeStamp = userDoc.get('createdAt');
          var joinedDate = joinedAtTimeStamp.toDate();
          joinedAt = '${joinedDate.year}-${joinedDate.month}-${joinedDate.day}';
        });
        User? user = auth.currentUser;
        String uid = user!.uid;
        setState((){
          isSameUser = uid == widget.userID;
        });
      }
    } catch (error) {
      GlobalMethods.showErrorDialog(error: 'error', context: context);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      drawer:  const DrawerWidget(),
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: isLoading == true
          ? const Center(
          child: CircularProgressIndicator(
            strokeWidth: 10,
            color: Colors.pink,
          ))
          : SingleChildScrollView(
        child: Center(
          child: Stack(
            children: [
              Card(
                margin: const EdgeInsets.all(30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 80,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          name ==null?"":name,
                          style: titleTextStyle,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          '$job Since joined $joinedAt',
                          style: TextStyle(
                            color: Constants.darkBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        'Contact Info',
                        style: titleTextStyle,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      socialInfo(label: "Email:", content: email),
                      const SizedBox(
                        height: 10,
                      ),
                      socialInfo(label: "Phone number:", content: phoneNumber),
                      const SizedBox(
                        height: 30,
                      ),
                      isSameUser?Container():   Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          socialButton(
                              color: Colors.green,
                              icon: Icons.whatsapp_outlined,
                              fct: () {
                                openWhatsAppChat();
                              }),
                          socialButton(
                              color: Colors.red,
                              icon: Icons.email_outlined,
                              fct: () {
                                _mailTo();
                              }),
                          socialButton(
                              color: Colors.deepPurple,
                              icon: Icons.phone,
                              fct: () {
                                callPhoneNumber();
                              }),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      isSameUser?Container(): const Divider(
                        thickness: 1,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                     !isSameUser?Container(): Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: MaterialButton(
                            onPressed: () async {
                              await auth.signOut();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const UserState(),
                                ),
                              );
                            },
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
                                Icon(
                                  Icons.logout_outlined,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Text(
                                    "Logout",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: size.width * 0.26,
                    height: size.width * 0.26,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 5,
                      ),
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageUrl == null
                            ? const NetworkImage(
                                'https://uxwing.com/wp-content/themes/uxwing/download/peoples-avatars/man-person-icon.png',
                              )
                            : NetworkImage(imageUrl!),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openWhatsAppChat() async {
    var urlWhatsApp = 'https://wa.me/$phoneNumber?text=HelloThere';
    await launch(urlWhatsApp);
  }

  void _mailTo() async {
    var url = 'mailto:$email';
    await launch(url);
  }

  void callPhoneNumber() async {
    var phoneUrl = 'tel://$phoneNumber';
    await launch(phoneUrl);
  }

  Widget socialInfo({required String label, required String content}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.normal,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            content,
            style: TextStyle(
              color: Constants.darkBlue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget socialButton(
      {required Color color, required IconData icon, required Function fct}) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 25,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 23,
        child: IconButton(
          icon: Icon(
            icon,
            color: color,
          ),
          onPressed: () {
            fct();
          },
        ),
      ),
    );
  }
}
