import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:workos/core/widgets/all_workers.dart';
import 'package:workos/core/widgets/drawer.dart';

class AllWorkersView extends StatelessWidget {
  const AllWorkersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text(
          'All worker',
          style: TextStyle(
            color: Colors.pink,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.pink[800],
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data!.docs.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return AllWorkersWidget(
                    userID: snapshot.data!.docs[index]['id'],
                    userEmail: snapshot.data!.docs[index]['email'],
                    userImageUrl: snapshot.data!.docs[index]['image'],
                    userName: snapshot.data!.docs[index]['name'],
                    positionInCompany: snapshot.data!.docs[index]
                        ['positionInCompany'],
                    phoneNumber: snapshot.data!.docs[index]['phoneNumber'],
                  );
                },
              );
            } else {
              return const Center(
                child: Text('No user found'),
              );
            }
          }
          return const Center(
            child: Text('Something went wrong'),
          );
        },
      ),
    );
  }
}
