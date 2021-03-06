import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../providers/post_provider.dart';
import 'android_new_post.dart';
import 'ios_new_post.dart';

class NewPostPage extends StatelessWidget {
  const NewPostPage({Key? key}) : super(key: key);
  static const String routeName = "/newPostPage";

  @override
  Widget build(BuildContext context) {
    final PostsProvider _postsProvider = Provider.of<PostsProvider>(context);

    final String _pageTitle = ModalRoute.of(context)?.settings.arguments.toString() ?? "";

    return Platform.isAndroid
        ? AndroidNewPost(pageTitle: _pageTitle, postsProvider: _postsProvider,)
        : IosNewPost(pageTitle: _pageTitle, postsProvider: _postsProvider,);
  }
}
