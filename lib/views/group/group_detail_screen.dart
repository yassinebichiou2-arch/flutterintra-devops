import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/group_model.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/group_provider.dart';
import '../../widgets/post_card.dart';
import '../home/create_post_screen.dart';
import '../home/edit_post_screen.dart';
import 'group_chat_screen.dart';

class GroupDetailScreen extends StatelessWidget {
  final GroupModel group;
  const GroupDetailScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final groupProv = context.read<GroupProvider>();
    final feed = context.read<FeedProvider>();
    final isMember =
        auth.user != null && group.members.contains(auth.user!.id);
    final isAdmin = auth.user?.id == group.adminId;
    final canSee = !group.isPrivate || isMember;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(group.name),
              background: group.coverUrl != null
                  ? CachedNetworkImage(
                      imageUrl: group.coverUrl!,
                      fit: BoxFit.cover,
                      color: Colors.black38,
                      colorBlendMode: BlendMode.darken,
                    )
                  : Container(
                      color: Theme.of(context).colorScheme.primary,
                    ),
            ),
            actions: [
              if (isMember)
                IconButton(
                  icon: const Icon(Icons.chat),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => GroupChatScreen(group: group)),
                  ),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.description,
                      style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${group.members.length} members',
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(width: 12),
                      Icon(
                          group.isPrivate ? Icons.lock : Icons.public,
                          size: 16,
                          color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(group.isPrivate ? 'Private' : 'Public',
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (auth.user != null && !isAdmin)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => isMember
                            ? groupProv.leaveGroup(group.id, auth.user!.id)
                            : groupProv.joinGroup(group.id, auth.user!.id),
                        child: Text(isMember ? 'Leave Group' : 'Join Group'),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (!canSee)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Join this group to see posts',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            StreamBuilder<List<PostModel>>(
              stream: feed.getGroupPostsStream(group.id),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()));
                }
                final posts = snap.data ?? [];
                if (posts.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                        child: Text('No posts in this group yet',
                            style: TextStyle(color: Colors.grey))),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => PostCard(
                      post: posts[i],
                      onEdit: auth.user?.id == posts[i].authorId
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        EditPostScreen(post: posts[i])),
                              )
                          : null,
                      onDelete: auth.user?.id == posts[i].authorId
                          ? () => feed.deletePost(posts[i].id)
                          : null,
                    ),
                    childCount: posts.length,
                  ),
                );
              },
            ),
        ],
      ),
      floatingActionButton: isMember
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        CreatePostScreen(groupId: group.id)),
              ),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}




