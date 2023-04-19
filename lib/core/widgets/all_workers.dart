import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../views/profile/view.dart';

class AllWorkersWidget extends StatefulWidget {
  final String userID;
  final String userName;
  final String userEmail;
  final String userImageUrl;
  final String positionInCompany;
  final String phoneNumber;

  const AllWorkersWidget({
    required this.userID,
    required this.userName,
    required this.userEmail,
    required this.userImageUrl,
    required this.positionInCompany,
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<AllWorkersWidget> createState() => _AllWorkersWidgetState();
}

class _AllWorkersWidgetState extends State<AllWorkersWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  ProfileView(userID:widget.userID,)),
          );
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
            radius: 20,
            child:  Image.network(
              widget.userImageUrl==null ?'https://uxwing.com/wp-content/themes/uxwing/download/peoples-avatars/man-person-icon.png':widget.userImageUrl,
            ),
          ),
        ),
        title: Text(widget.userName,
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
              '${widget.positionInCompany}/${widget.phoneNumber}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: _mailTo,
          icon: Icon(
            Icons.mail_outline,
            size: 30,
            color: Colors.pink[800],
          ),
        ),
      ),
    );
  }
  void _mailTo() async {
    var url = 'mailto:${widget.userEmail}';
    await launch(url);
  }
}
