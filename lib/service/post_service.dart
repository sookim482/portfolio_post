import '../class/comment_class.dart';
import '../class/post_class.dart';
import '../class/user_class.dart';
import '../repos/connect.dart';

class PostService {
  Connect _connect = Connect();

  Future<Map<String, dynamic>> getPreviews() async {
    try {
      final Map<String, dynamic> _res = await this._connect.reqGetServer(path: "/post/getPreviews", cb: (ReqModel rm) {});
      if (_res.containsKey("previews")) {
        List<Map<String, dynamic>>? _previews = List<Map<String, dynamic>>.from(_res["previews"]);
        List<Preview> _previewList = [];
        _previews.forEach((Map<String, dynamic> json) => _previewList.add(Preview.fromJson(json)));
        return {"previews": _previewList};
      }
      if (_res.containsKey("error")) {
        // todo error handling
      }
    } catch (e) {
      print(e);
    }
    return {};
  }

  // todo 질문: 이렇게 parameter 다 받아와서 여기서 body로 변경? 아니면 provider에서 부터 body로 변경해서 줌?
  Future<Map<String, dynamic>> addPost({required String title, required String text, required Author author}) async {
    final Map<String, dynamic> _body = {
      "title": title,
      "text": text,
      "author": author.toJson(),
    };
    try {
      final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "/post/addPost", cb: (ReqModel rm) {}, body: {"post": _body});
      if (_res.containsKey("postUid") && _res.containsKey("createdTime")) return {
        "post": Post(createdTime: _res["createdTime"], author: author, text: text, title: title, postUid: _res["postUid"], numOfLikes: 0, likedUsers: []),
        "preview": Preview(userName: author.userName, title: title, text: text, postUid: _res["postUid"]),
      };
      return _res;
    } catch (e) {
      print(e);
    }
    return {};
  }

  Future<Map<String, dynamic>> getPost({required String postUid}) async {
    try {
      final Map<String, dynamic> _res = await this._connect.reqGetServer(
        path: "/post/getPost/${postUid}", cb: (ReqModel rm) {}, );
      if (_res.containsKey("post")) {
        Map<String, dynamic> _post = _res["post"] as Map<String, dynamic>;
        if (_post["likedUsers"] != null) _post["likedUsers"] = List<String>.from(_post["likedUsers"]);
        return {"post": Post.fromJson(_res["post"] as Map<String, dynamic>)};
      }
      return _res;
    } catch (e) {
      print(e);
    }
    return {};
  }

  Future<Map<String, dynamic>> getComments({required String postUid}) async {
    try {
      final Map<String, dynamic> _res = await this._connect.reqGetServer(
        path: "/comment/get/${postUid}", cb: (ReqModel rm) {}, );
      if (_res.containsKey("comments")) {
        List<Comment> _commentsList = [];
        if (_res["comments"] == null) {
          print("no comments");
          return {"comments": _commentsList};
        }
        print("comments: ${_res["comments"]}");
        List<Map<String, dynamic>> _comments = List<Map<String, dynamic>>.from(_res["comments"]);
        _comments.forEach((Map<String, dynamic> json) => _commentsList.add(Comment.fromJson(json)));
        return {"comments": _commentsList};
      }
      return _res;
    } catch (e) {
      print(e);
    }
    return {};
  }

  Future<Map<String, dynamic>> like({required String postUid, required int numOfLikes, required String userUid}) async {
    final Map<String, dynamic> _body = {
      "postUid": postUid,
      "numOfLikes": numOfLikes,
      "userUid": userUid,
    };
    try {
      final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "/post/like", cb: (ReqModel rm) {}, body: _body);
      return _res;
    } catch (e) {
      print(e);
    }
    return {};
  }

  Future<Map<String, dynamic>> unlike({required String postUid, required int numOfLikes, required String userUid}) async {
    final Map<String, dynamic> _body = {
      "postUid": postUid,
      "numOfLikes": numOfLikes,
      "userUid": userUid,
    };
    try {
      final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "/post/unlike", cb: (ReqModel rm) {}, body: _body);
      return _res;
    } catch (e) {
      print(e);
    }
    return {};
  }

  Future<Map<String, dynamic>> addComment({required CommentBody body, bool commentOnComment = false}) async {
    String _param = "comment";
    if (commentOnComment) _param = "commentOnComment";
    try {
      final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "/comment/add/${_param}", cb: (ReqModel rm) {}, body: body.toJson());
      if (_res.containsKey("commentUid") && _res.containsKey("createdTime")) {
        return {"comment": Comment(
          comments: [],
          createdTime: _res["createdTime"].toString(),
          commentUid: _res["commentUid"].toString(),
          author: body.author,
          text: body.text,
          isPrivate: body.isPrivate,
        )};
      };
    } catch (e) {
      print(e);
    }
    return {};
  }

  Future deletePost({required String postUid, required User user}) async {
    final Map<String, dynamic> _body = {"postUid": postUid, "userUid": user.userUid, "idToken": user.idToken};
    try {
      final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "/post/delete", cb: (ReqModel rm) {}, body: _body);
      return _res;
    } catch (e) {
      print(e);
    }
    return {};
  }

  // 여기까지 왔다는건 이미 verified 된건데 또 verify해야되나?
  Future editPost({required Map<String, dynamic> body}) async {
    try {
      final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "/post/edit", cb: (ReqModel rm) {}, body: body);
      return _res;
    } catch (e) {
      print(e);
    }
    return {};
  }

}