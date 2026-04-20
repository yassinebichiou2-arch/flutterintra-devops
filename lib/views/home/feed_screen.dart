import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/post_card.dart';
import '../search/search_screen.dart';
import 'create_post_screen.dart';
import 'edit_post_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final feed = context.watch<FeedProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterIntra'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: feed.setSortBy,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'recent', child: Text('Most Recent')),
              PopupMenuItem(value: 'popular', child: Text('Most Popular')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: feed.getFeedStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final posts = snap.data ?? [];
          if (posts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No posts yet. Be the first!',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {},
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (_, i) => PostCard(
                post: posts[i],
                onEdit: auth.user?.id == posts[i].authorId
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => EditPostScreen(post: posts[i])),
                        )
                    : null,
                onDelete: (auth.user?.id == posts[i].authorId || auth.isAdmin)
                    ? () => _confirmDelete(context, feed, posts[i])
                    : null,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreatePostScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, FeedProvider feed, PostModel post) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              feed.deletePost(post.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}




