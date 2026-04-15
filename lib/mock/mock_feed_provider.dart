import '../models/comment_model.dart';
import '../models/notification_model.dart';
import '../models/post_model.dart';
import '../providers/feed_provider.dart';
import 'mock_data.dart';

class MockFeedProvider extends FeedProvider {
  final List<PostModel> _mockPosts = List.from(mockPosts);
  final List<CommentModel> _mockComments = List.from(mockComments);
  final List<NotificationModel> _mockNotifs = List.from(mockNotifications);

  @override
  Stream<List<PostModel>> getFeedStream({String? groupId}) {
    var posts = _mockPosts.where((p) => p.groupId == groupId).toList();
    if (sortBy == 'popular') {
      posts.sort((a, b) => b.likes.length.compareTo(a.likes.length));
    } else {
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return Stream.value(posts);
  }

  @override
  Stream<List<PostModel>> getGroupPostsStream(String groupId) {
    return Stream.value(
        _mockPosts.where((p) => p.groupId == groupId).toList());
  }

  @override
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
    await Future.delayed(const Duration(milliseconds: 500));
    _mockPosts.insert(
      0,
      PostModel(
        id: 'p_${DateTime.now().millisecondsSinceEpoch}',
        authorId: authorId,
        authorName: authorName,
        authorPhotoUrl: authorPhotoUrl,
        content: content,
        imageUrls: imageUrls,
        groupId: groupId,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return true;
  }

  @override
  Future<void> updatePost(String postId, String content) async {
    final i = _mockPosts.indexWhere((p) => p.id == postId);
    if (i != -1) {
      _mockPosts[i] = _mockPosts[i].copyWith(content: content);
      notifyListeners();
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    _mockPosts.removeWhere((p) => p.id == postId);
    notifyListeners();
  }

  @override
  Future<void> toggleLike(
      String postId, String userId, String postAuthorId) async {
    final i = _mockPosts.indexWhere((p) => p.id == postId);
    if (i != -1) {
      final likes = List<String>.from(_mockPosts[i].likes);
      likes.contains(userId) ? likes.remove(userId) : likes.add(userId);
      _mockPosts[i] = _mockPosts[i].copyWith(likes: likes);
      notifyListeners();
    }
  }

  @override
  Future<void> addComment(CommentModel comment, String postAuthorId) async {
    _mockComments.add(comment);
    final i = _mockPosts.indexWhere((p) => p.id == comment.postId);
    if (i != -1) {
      _mockPosts[i] = _mockPosts[i]
          .copyWith(commentCount: _mockPosts[i].commentCount + 1);
    }
    notifyListeners();
  }

  @override
  Stream<List<CommentModel>> getComments(String postId) {
    return Stream.value(
        _mockComments.where((c) => c.postId == postId).toList());
  }

  @override
  Future<void> deleteComment(String commentId, String postId) async {
    _mockComments.removeWhere((c) => c.id == commentId);
    final i = _mockPosts.indexWhere((p) => p.id == postId);
    if (i != -1 && _mockPosts[i].commentCount > 0) {
      _mockPosts[i] = _mockPosts[i]
          .copyWith(commentCount: _mockPosts[i].commentCount - 1);
    }
    notifyListeners();
  }

  @override
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return Stream.value(
        _mockNotifs.where((n) => n.userId == userId).toList());
  }

  @override
  Future<void> markNotificationRead(String notifId) async {
    final i = _mockNotifs.indexWhere((n) => n.id == notifId);
    if (i != -1) {
      _mockNotifs[i] = NotificationModel(
        id: _mockNotifs[i].id,
        userId: _mockNotifs[i].userId,
        type: _mockNotifs[i].type,
        title: _mockNotifs[i].title,
        body: _mockNotifs[i].body,
        referenceId: _mockNotifs[i].referenceId,
        isRead: true,
        createdAt: _mockNotifs[i].createdAt,
      );
      notifyListeners();
    }
  }
}

