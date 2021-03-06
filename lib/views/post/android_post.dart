import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';
import '../../repos/variables.dart';
import 'android_components.dart';
import 'common_components.dart';

class AndroidPost extends StatelessWidget {
  const AndroidPost({Key? key, required this.postsProvider, required this.userProvider}) : super(key: key);
  final PostsProvider postsProvider;
  final UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    MediaQueryData _mq = MediaQuery.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: MyColors.primary,
        title: Text(this.postsProvider.post?.title ?? ""),
        actions: [
          IconButton(
            padding: EdgeInsets.zero,
            icon: this.postsProvider.user == null ? Container() : !this.postsProvider.userLiked(this.postsProvider.user!.userUid) ? Icon(Icons.thumb_up_outlined) : Icon(Icons.thumb_up_sharp),
            onPressed: this.postsProvider.user == null ? null : () async => await this.postsProvider.like(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            minHeight: _mq.size.height - 66.0 - _mq.viewPadding.top - _mq.viewPadding.bottom,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              this.postsProvider.post?.author.userUid == this.postsProvider.user?.userUid
                ? EditDelete(delete: this.postsProvider.deletePost, userUid: this.postsProvider.user!.userUid, resetPost: this.postsProvider.resetPost, initCategory: this.postsProvider.initCategory,)
                : Container(),
              PostWidget(
                state: this.postsProvider.state,
                photos: this.postsProvider.uploadedPhotos,
                userUid: this.userProvider.user?.userUid ?? "",
                post: this.postsProvider.post!,
                follow: this.userProvider.follow, // todo show snackbar
                isFollowing: this.userProvider.isFollowing(this.postsProvider.post!.author.userUid),
              ),
              Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        final bool _save = await showModalBottomSheet<bool>(
                          context: context,
                          builder: (BuildContext ctx) {
                            final PostsProvider _postsProvider = Provider.of<PostsProvider>(ctx);
                            return CommentBottomSheet(
                              isPrivate: _postsProvider.isPrivate,
                              onComment:  _postsProvider.onComment,
                              changePrivate: _postsProvider.changePrivate,
                            );
                          },
                        ) ?? false;
                        if (!_save) return;
                        await this.postsProvider.addComment();
                      },
                      child: const Text("add comment", style: const TextStyle(fontWeight: FontWeight.w600, color: MyColors.primary, fontSize: 15.0)),
                    ),
                  ),
                ],
              ),
              this.postsProvider.comments.isNotEmpty
                ? Comments(postsProvider: this.postsProvider)
                : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
