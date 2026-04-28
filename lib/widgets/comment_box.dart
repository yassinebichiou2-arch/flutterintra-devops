import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/comment_model.dart';
import '../providers/auth_provider.dart';
import '../providers/feed_provider.dart';
import 'user_avatar.dart';

class CommentBox extends StatelessWidget {
  final CommentModel comment;
  final String postAuthorId;

  const CommentBox({
    super.key,
    required this.comment,
    required this.postAuthorId,
  });

  void _confirmDelete(BuildContext context, FeedProvider feed) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              feed.deleteComment(comment.id, comment.postId);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final feed = context.read<FeedProvider>();
    final isOwner = auth.user?.id == comment.authorId;
    final isPostOwner = auth.user?.id == postAuthorId;
    final canDelete = isOwner || isPostOwner || (auth.isAdmin);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            photoUrl: comment.authorPhotoUrl,
            name: comment.authorName,
            radius: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.authorName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      if (comment.authorId == postAuthorId) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Author',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        timeago.format(comment.createdAt),
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600),
                      ),
                      if (canDelete) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _confirmDelete(context, feed),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.delete_outline,
                                size: 14, color: Colors.red),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(comment.content,
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
