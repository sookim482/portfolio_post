import 'package:flutter/material.dart';
import 'package:portfolio_post/views/components/android_checkbox.dart';
import 'package:portfolio_post/views/post/post_page.dart';
import 'package:provider/provider.dart';

import '../../class/checkbox_class.dart';
import '../../class/photo_class.dart';
import '../../providers/post_provider.dart';
import '../../repos/variables.dart';
import 'common_components.dart';

class AndroidNewPost extends StatefulWidget {
  const AndroidNewPost({Key? key, required this.postsProvider, required this.pageTitle}) : super(key: key);
  final PostsProvider postsProvider;
  final String pageTitle;

  @override
  State<AndroidNewPost> createState() => _AndroidNewPostState();
}

class _AndroidNewPostState extends State<AndroidNewPost> {
  final TextEditingController _titleCt = TextEditingController();
  final TextEditingController _textCt = TextEditingController();
  bool _isExpanded = false;

  @override
  void initState() {
    if (this.widget.postsProvider.post != null) {
      this._titleCt.text = this.widget.postsProvider.post!.title;
      this._textCt.text = this.widget.postsProvider.post!.text;
    }
    super.initState();
  }

  @override
  void dispose() {
    this._textCt.dispose();
    this._titleCt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        this.widget.postsProvider.resetNewPhotos();
        return await true;
      },
      child: GestureDetector(
        onTap: FocusManager.instance.primaryFocus?.unfocus,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: MyColors.primary,
            title: Text(this.widget.pageTitle),
            actions: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.add),
                onPressed: () async {
                  bool _success;
                  if (this.widget.postsProvider.post != null) {
                    _success = await this.widget.postsProvider.editPost(title: this._titleCt.text, text: this._textCt.text);
                  } else {
                    _success = await this.widget.postsProvider.addPost(
                      text: this._textCt.text,
                      title: this._titleCt.text,
                    );
                  }
                  if (!_success) return; // todo tell user "couldn't add post"
                  Navigator.of(context).pop(PostPage.routeName);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
              child: this.widget.postsProvider.user == null
                ? Center(child: Text("로그인을 해야지 글을 쓸 수 있습니다."),)
                : Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 20.0),
                        child: Column(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                this.setState(() {
                                  this._isExpanded = !this._isExpanded;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 7.0),
                                child: const Text("Choose a Category", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
                              ),
                            ),
                            this._isExpanded
                              ? Container(
                                  child: Column(
                                      children: this.widget.postsProvider.viewCategories.map((CheckboxClass c) => AndroidCheckbox(
                                          data: c, onChanged: this.widget.postsProvider.onCheckView)).toList()
                                  ),
                                )
                              : Container()
                          ],
                        ),
                      ),
                      TextField(
                        controller: this._titleCt,
                        decoration: InputDecoration(
                          constraints: BoxConstraints(),
                          isDense: true,
                          contentPadding: const EdgeInsets.only(bottom: 5.0, left: 5.0),
                          border: UnderlineInputBorder(),
                          hintText: "Title"
                        ),
                      ),
                      Container(
                        alignment: Alignment.topCenter,
                        margin: EdgeInsets.only(top: 25.0),
                        height: 500.0,
                        decoration: BoxDecoration(border: Border.all()),
                        child: TextField(
                          controller: this._textCt,
                          maxLines: null,
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(left: 10.0),
                              border: InputBorder.none,
                              hintText: "Text"
                          ),
                        ),
                      ),
                      TextButton(
                        child: Text("Add Image"),
                        onPressed: () async {
                          await showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (BuildContext ctx) {
                              PostsProvider _pp = Provider.of<PostsProvider>(ctx);
                              return Dialog(
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  color: Colors.white,
                                  width: 70.0,
                                  height: 100.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      CameraGalleryButton(
                                        icon: Icons.camera,
                                        text: "Camera",
                                        onTap: _pp.selectPhotos,
                                      ),
                                      CameraGalleryButton(
                                        icon: Icons.photo,
                                        text: "Gallery",
                                        onTap: _pp.takePhoto,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      ...this.widget.postsProvider.newPhotos.map((String path) => new NewPhoto(
                          path: path, deleteNewPhoto: this.widget.postsProvider.deleteNewPhoto, icon: Icons.delete)),
                      ...?this.widget.postsProvider.uploadedPhotos?.map((Photo photo) => new OldPhoto(
                        icon: Icons.delete, deleteOldPhoto: this.widget.postsProvider.deleteOldPhoto, photo: photo,
                      )),
                    ],
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
