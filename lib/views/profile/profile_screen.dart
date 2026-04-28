import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/theme_provider.dart';
import '../../widgets/post_card.dart';
import '../../widgets/user_avatar.dart';
import '../admin/admin_panel_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final isOwn = userId == null || userId == auth.user?.id;
    final targetId = userId ?? auth.user?.id;

    if (targetId == null) {
      return const Center(child: Text('Not logged in'));
    }

    return FutureBuilder<UserModel?>(
      future: context.read<UserProvider>().getUser(targetId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final user = snap.data;
        if (user == null) {
          return const Scaffold(body: Center(child: Text('User not found')));
        }
        return _ProfileBody(user: user, isOwn: isOwn);
      },
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final UserModel user;
  final bool isOwn;
  const _ProfileBody({required this.user, required this.isOwn});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final feed = context.read<FeedProvider>();
    final themeProv = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
        actions: [
          if (isOwn) ...[
            IconButton(
              icon: Icon(
                  themeProv.isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: themeProv.toggle,
            ),
            if (auth.isAdmin)
              IconButton(
                icon: const Icon(Icons.admin_panel_settings),
                tooltip: 'Admin Panel',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AdminPanelScreen()),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => EditProfileScreen(user: user)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () =>
                  context.read<AppAuthProvider>().signOut(),
            ),
          ],
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  UserAvatar(
                      photoUrl: user.photoUrl, name: user.name, radius: 44),
                  const SizedBox(height: 12),
                  Text(user.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  if (user.position != null)
                    Text(user.position!,
                        style: TextStyle(color: Colors.grey.shade600)),
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(user.bio!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14)),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: user.role == 'admin'
                          ? Colors.orange.withValues(alpha: 0.15)
                          : Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.role == 'admin' ? 'Administrator' : 'Employee',
                      style: TextStyle(
                          color: user.role == 'admin'
                              ? Colors.orange
                              : Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                  const Divider(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Posts',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      StreamBuilder<List<PostModel>>(
                        stream: feed.getFeedStream(),
                        builder: (context, snap) {
                          final count = (snap.data ?? [])
                              .where((p) => p.authorId == user.id)
                              .length;
                          return Text('$count posts',
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 13));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder<List<PostModel>>(
            stream: feed.getFeedStream(),
            builder: (context, snap) {
              final all = snap.data ?? [];
              final posts =
                  all.where((p) => p.authorId == user.id).toList();
              if (posts.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                        child: Text('No posts yet',
                            style: TextStyle(color: Colors.grey))),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => PostCard(post: posts[i]),
                  childCount: posts.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

