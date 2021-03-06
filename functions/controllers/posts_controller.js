const functions = require("firebase-functions"),
    admin = require("firebase-admin"),
    uuid = require("uuid"),
    { getStorage } = require("firebase-admin/storage");

const addPost = async (req, res) => {
    const postUid = uuid.v1();
    req.body.post.postUid = postUid;
    let createdTime = new Date().toISOString();
    req.body.post.createdTime = createdTime;
    try {
        await admin.database().ref("/posts").child(postUid).set(req.body.post);
        res.send({ postUid, createdTime });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

const previewText = (text) => {
    const subText = text.substring(0, 250);
    let lastSpace = subText.lastIndexOf(" ");
    if (lastSpace == -1) lastSpace = text.length;
    let lastPeriod = subText.lastIndexOf(".");
    if (lastPeriod == -1) lastPeriod = text.length;
    return subText.substring(0, lastSpace > lastPeriod ? lastSpace : lastPeriod);
}

const addPreview = functions.region("asia-northeast3").database.instance("mooky-post-default-rtdb").ref('/posts/{postUid}')
    .onCreate((snapshot, context) => {
        const original = snapshot.val();
        functions.logger.log("adding post preview", context.params.postUid, original);
        const textPreview = previewText(original.text);
        const preview = {
            postUid: context.params.postUid,
            title: original.title,
            text: textPreview,
            userName: original.author.userName,
            createdTime: original.createdTime,
            category: original.category,
        };
        return snapshot.ref.database.ref("/previews").child(context.params.postUid).set(preview);
    });

// realtime db function
const deletePreviewCommentPhoto = functions.region("asia-northeast3").database.instance("mooky-post-default-rtdb").ref("/posts/{postUid}")
    .onDelete(async (snapshot, context) => {
        functions.logger.log("deleting preview, comment, photos", context.params.postUid);

        const bucket = getStorage().bucket();
        await bucket.deleteFiles({ prefix: context.params.postUid });

        await snapshot.ref.database.ref("/previews").child(context.params.postUid).remove();
        return snapshot.ref.database.ref("/comments").child(context.params.postUid).remove();
    
    });

const getPreviews = async (_, res) => {
    try {
        let previews = [];
        await admin.database().ref("/previews").orderByChild("createdTime").once("value", async (snapshot) => {
            snapshot.forEach(child => {
                previews.push(child.val());
            });
        });
        res.send({ previews: previews });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

const refreshPreviews = async (_, res) => {
    try {
        let previews = [];
        await admin.database().ref("/previews").orderByChild("createdTime").once("value", async (snapshot) => {
            snapshot.forEach(child => {
                previews.push(child.val());
            });
        });
        res.send({ previews: previews });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

const getPost = async (req, res) => {
    console.log("getting post");
    try {
        const _dataSnapshot = await admin.database().ref(`/posts/${req.params.postUid}`).once("value");
        if (_dataSnapshot.val() != null) {
            let post = _dataSnapshot.val();
            if (post.likedUsers) post.likedUsers = Object.keys(_dataSnapshot.val().likedUsers);
            // if (post.images) {
            //     const images = await getImage(Object.entries(post.images), req.params.postUid);
            //     post.images = images;
            // }
            res.send({ post });
        }
        if (_dataSnapshot.val() == null) res.send({ error: "couldn't find post" });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

const like = async (req, res) => {
    try {
        await admin.database().ref(`/posts/${req.body.postUid}`).update({ numOfLikes: req.body.numOfLikes, [`likedUsers/${req.body.userUid}`]: "liked" });
        res.send({ data: "success" });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

const unlike = async (req, res) => {
    try {
        await admin.database().ref(`/posts/${req.body.postUid}/likedUsers`).child(req.body.userUid).remove();
        await admin.database().ref(`/posts/${req.body.postUid}`).child("numOfLikes").set(req.body.numOfLikes);
        res.send({ data: "success" });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

const verifyPostAuthor = functions.https.onRequest(async (req, _) => {
    const _dataSnapshot = await admin.database().ref(`/users/${req.body.userUid}/idToken`).get();
    if (_dataSnapshot.val() == req.body.idToken) return true;
    if (_dataSnapshot.val() != req.body.idToken) return false;
});

const deletePost = async (req, res) => {
    try {
        const _verified = await verifyPostAuthor(req, res);
        if (_verified) await admin.database().ref("/posts").child(req.body.postUid).remove();
        res.send({ deleted: _verified });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

const edit = async (req, res) => {
    try {
        const _verified = await verifyPostAuthor(req, res);
        if (_verified) {
            let modifiedTime = new Date().toISOString();
            req.body.updateInfo.modifiedTime = modifiedTime;
            await admin.database().ref("/posts").child(req.body.postUid).update(req.body.updateInfo);
            
            let previewBody = {};
            if (req.body.updateInfo.title) previewBody.title = req.body.updateInfo.title;
            if (req.body.previewText) previewBody.text = req.body.previewText;
            if (previewBody.title || previewBody.text) {
                await admin.database().ref("/previews").child(req.body.postUid).update(previewBody);
            }
            res.send({ modifiedTime });
        }
        if (!_verified) res.send({ error: "user not verified" });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

const editPreview = functions.region("asia-northeast3").database.instance("mooky-post-default-rtdb").ref("/posts/{postUid}")
    .onUpdate(async (change, context) => {
        functions.logger.log("editing preview");
        const oldTitle = change.before.val().title;
        const newTitle = change.after.val().title;

        const oldText = change.before.val().text.substring(0, 250);
        const newText = change.after.val().text.substring(0, 250);

        const oldCategory = change.before.val().category;
        const newCategory = change.after.val().category;
        let preview = {};
        functions.logger.log(`prev category: ${oldCategory}`, `new category: ${newCategory}`);
        if (oldTitle != newTitle) preview.title = newTitle;
        if (oldText != newText) preview.text = previewText(newText);
        if (oldCategory != newCategory) preview.category = newCategory;
    
        return change.after.ref.database.ref("/previews").child(context.params.postUid).update(preview);
    });

const category = async (req, res) => {
    console.log(req.query.category);
    try {
        const previews = await new Promise(resolve => {
            let previews = [];
            req.query.category.forEach(async (category) => {
                const _dataSnapshot = await admin.database().ref("/previews").orderByChild("category").equalTo(category).get();
                if (_dataSnapshot.val() != null) {
                    Object.values(_dataSnapshot.val()).forEach(snapshot => previews.push(snapshot));
                }
            });
            setTimeout(_ => resolve(previews), 1000);
        });
        res.send({ previews: previews });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}
 
module.exports = {
    addPost, getPreviews, refreshPreviews, getPost, like, unlike, deletePost, edit, category, previewText,
    addPreview, deletePreviewCommentPhoto, editPreview, verifyPostAuthor
}