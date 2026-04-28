import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';
import '../models/notification_model.dart';
import '../models/post_model.dart';

class PostService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createPost(PostModel post) async {
    await _db.collection('posts').add(post.toMap());
  }

  Future<void> updatePost(String postId, Map<String, dynamic> data) =>
      _db.collection('posts').doc(postId).update(data);

  Future<void> deletePost(String postId) async {
    await _db.collection('posts').doc(postId).delete();
    final comments = await _db
        .collection('comments')
        .where('postId', isEqualTo: postId)
        .get();
    for (final d in comments.docs) {
      await d.reference.delete();
    }
  }

  // Simplified query — no composite index needed
  Stream<List<PostModel>> getFeedPosts({String? groupId, String? sortBy}) {
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) {
      var posts = s.docs
          .map((d) => PostModel.fromMap(d.data(), d.id))
          .toList();
      // Filter client-side to avoid composite index
      if (groupId != null) {
        posts = posts.where((p) => p.groupId == groupId).toList();
      } else {
        posts = posts.where((p) => p.groupId == null).toList();
      }
      if (sortBy == 'popular') {
        posts.sort((a, b) => b.likes.length.compareTo(a.likes.length));
      }
      return posts;
    });
  }

  Stream<List<PostModel>> getGroupPosts(String groupId) {
    return _db
        .collection('posts')
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .map((s) {
      final posts = s.docs
          .map((d) => PostModel.fromMap(d.data(), d.id))
          .toList();
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    });
  }

  Future<void> toggleLike(String postId, String userId) async {
    final doc = await _db.collection('posts').doc(postId).get();
    final likes = List<String>.from(doc.data()?['likes'] ?? []);
    likes.contains(userId) ? likes.remove(userId) : likes.add(userId);
    await _db.collection('posts').doc(postId).update({'likes': likes});
  }

  Future<void> addComment(CommentModel comment) async {
    await _db.collection('comments').add(comment.toMap());
    await _db
        .collection('posts')
        .doc(comment.postId)
        .update({'commentCount': FieldValue.increment(1)});
  }

  Stream<List<CommentModel>> getComments(String postId) {
    return _db
        .collection('comments')
        .where('postId', isEqualTo: postId)
        .snapshots()
        .map((s) {
      final comments = s.docs
          .map((d) => CommentModel.fromMap(d.data(), d.id))
          .toList();
      comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return comments;
    });
  }

  Future<void> deleteComment(String commentId, String postId) async {
    await _db.collection('comments').doc(commentId).delete();
    await _db
        .collection('posts')
        .doc(postId)
        .update({'commentCount': FieldValue.increment(-1)});
  }

  Future<void> sendNotification(NotificationModel notif) async {
    await _db.collection('notifications').add(notif.toMap());
  }

  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((s) {
      final notifs = s.docs
          .map((d) => NotificationModel.fromMap(d.data(), d.id))
          .toList();
      notifs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifs.take(30).toList();
    });
  }

  Future<void> markNotificationRead(String notifId) =>
      _db.collection('notifications').doc(notifId).update({'isRead': true});

  Future<void> markAllNotificationsRead(String userId) async {
    final snap = await _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> deleteNotification(String notifId) =>
      _db.collection('notifications').doc(notifId).delete();
}
