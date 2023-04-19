import 'package:flutter/material.dart';
import 'package:workos/views/profile/view.dart';

class CommentWidget extends StatelessWidget {
  CommentWidget(
      {Key? key,
      required this.commentId,
      required this.commentBody,
      required this.commentImageUrl,
      required this.commenterName,
      required this.commenterId})
      : super(key: key);

  final String commentId;
  final String commentBody;
  final String commentImageUrl;
  final String commenterName;
  final String commenterId;

  final List<Color> _colors = [
    Colors.orangeAccent,
    Colors.pink,
    Colors.amber,
    Colors.purple,
    Colors.brown,
    Colors.blue,
  ];

  @override
  Widget build(BuildContext context) {
    _colors.shuffle();
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileView(
              userID: commenterId,
            ),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 5,
          ),
          Flexible(
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: _colors[0],
                  ),
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(commentImageUrl),
                    fit: BoxFit.fill,
                  )),
            ),
          ),
          Flexible(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    commenterName,
                    style: const TextStyle(
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    commentBody,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
