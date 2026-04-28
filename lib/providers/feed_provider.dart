import 'package:flutter/material.dart';
import '../models/comment_model.dart';
import '../models/notification_model.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

class FeedProvider extends ChangeNotifier {
  final PostService _postService = PostService();

  bool _loading = false;
  String? _error;
  String _sortBy = 'recent';

  bool get loading => _loading;
  String? get error => _error;
  String get sortBy => _sortBy;

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  Stream<List<PostModel>> getFeedStream({String? groupId}) {
    return _postService.getFeedPosts(groupId: groupId, sortBy: _sortBy);
  }

  Stream<List<PostModel>> getGroupPostsStream(String groupId) {
    return _postService.getGroupPosts(groupId);
  }

  Future<bool> createPost({
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
    List<dynamic> images = const [],
    List<dynamic> files = const [],
    List<String> fileNames = const [],
    String? groupId,
    List<String> imageUrls = const [],
    List<String> fileUrls = const [],
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _postService.createPost(PostModel(
        id: '',
        authorId: authorId,
        authorName: authorName,
        authorPhotoUrl: authorPhotoUrl,
        content: content,
        imageUrls: imageUrls,
        fileUrls: fileUrls,
        fileNames: fileNames,
        groupId: groupId,
        createdAt: DateTime.now(),
      ));
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updatePost(String postId, String content) async {
    await _postService.updatePost(postId, {'content': content});
  }

  Future<void> deletePost(String postId) async {
    await _postService.deletePost(postId);
  }

  Future<void> toggleLike(
      String postId, String userId, String postAuthorId) async {
    await _postService.toggleLike(postId, userId);
    if (userId != postAuthorId) {
      await _postService.sendNotification(NotificationModel(
        id: '',
        userId: postAuthorId,
        type: 'like',
        title: 'New Like',
        body: 'Someone liked your post',
        referenceId: postId,
        createdAt: DateTime.now(),
      ));
    }
  }

  Future<void> addComment(CommentModel comment, String postAuthorId) async {
    await _postService.addComment(comment);
    if (comment.authorId != postAuthorId) {
      await _postService.sendNotification(NotificationModel(
        id: '',
        userId: postAuthorId,
        type: 'comment',
        title: 'New Comment',
        body: '${comment.authorName} commented on your post',
        referenceId: comment.postId,
        createdAt: DateTime.now(),
      ));
    }
  }

  Stream<List<CommentModel>> getComments(String postId) =>
      _postService.getComments(postId);

  Future<void> deleteComment(String commentId, String postId) =>
      _postService.deleteComment(commentId, postId);

  Stream<List<NotificationModel>> getNotifications(String userId) =>
      _postService.getNotifications(userId);

  Future<void> markNotificationRead(String notifId) =>
      _postService.markNotificationRead(notifId);

  Future<void> markAllNotificationsRead(String userId) =>
      _postService.markAllNotificationsRead(userId);

  Future<void> deleteNotification(String notifId) =>
      _postService.deleteNotification(notifId);
}

