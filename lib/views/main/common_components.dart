import 'package:flutter/widgets.dart';

import '../../class/preview_class.dart';
import '../post/post_page.dart';

class PostPreviewTile extends StatelessWidget {
  const PostPreviewTile({Key? key, required this.post, required this.getPost}) : super(key: key);
  final Preview post;
  final Future<void> Function(String postUid) getPost;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        this.getPost(this.post.postUid);
        await Navigator.of(context).pushNamed(PostPage.routeName);
      },
      child: Container(
        height: 115.0,
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(this.post.title, style: const TextStyle(overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w600, color: Color.fromRGBO(0, 0, 0, 1.0), fontSize: 20.0), maxLines: 2),
            Text(this.post.text, style: const TextStyle(overflow: TextOverflow.ellipsis, fontSize: 16.0), maxLines: 2,),
            Align(
              alignment: Alignment.centerRight,
              child: Text(this.post.userName, style: const TextStyle(fontSize: 15.0)),
            ),
          ],
        ),
      ),
    );
  }
}
