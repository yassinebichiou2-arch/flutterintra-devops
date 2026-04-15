import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/comment_model.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/comment_box.dart';
import '../../widgets/post_card.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;
  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    final auth = context.read<AppAuthProvider>();
    final feed = context.read<FeedProvider>();
    final comment = CommentModel(
      id: '',
      postId: widget.post.id,
      authorId: auth.user!.id,
      authorName: auth.user!.name,
      authorPhotoUrl: auth.user!.photoUrl,
      content: text,
      createdAt: DateTime.now(),
    );
    await feed.addComment(comment, widget.post.authorId);
    _commentCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final feed = context.read<FeedProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  PostCard(post: widget.post),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Comments',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  StreamBuilder<List<CommentModel>>(
                    stream: feed.getComments(widget.post.id),
                    builder: (context, snap) {
                      final comments = snap.data ?? [];
                      if (comments.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No comments yet.',
                              style: TextStyle(color: Colors.grey)),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: comments.length,
                        itemBuilder: (_, i) => CommentBox(
                          comment: comments[i],
                          postAuthorId: widget.post.authorId,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Comment input
          Container(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, -2))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Write a comment...',
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




