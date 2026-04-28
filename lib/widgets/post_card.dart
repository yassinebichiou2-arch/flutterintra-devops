import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/post_model.dart';
import '../providers/auth_provider.dart';
import '../providers/feed_provider.dart';
import '../utils/app_theme.dart';
import '../views/home/post_detail_screen.dart';
import '../views/home/edit_post_screen.dart';
import 'user_avatar.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PostCard({
    super.key,
    required this.post,
    this.onEdit,
    this.onDelete,
  });

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Post'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error, minimumSize: Size.zero),
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
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
    final isOwner = auth.user?.id == post.authorId;
    final canManage = isOwner || auth.isAdmin;
    final isLiked = auth.user != null && post.likes.contains(auth.user!.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.borderDark
              : AppTheme.borderLight,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  UserAvatar(
                      photoUrl: post.authorPhotoUrl,
                      name: post.authorName,
                      radius: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.authorName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 11, color: Colors.grey.shade500),
                            const SizedBox(width: 3),
                            Text(
                              timeago.format(post.createdAt),
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (canManage)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_horiz,
                          color: Colors.grey.shade500),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      onSelected: (v) {
                        if (v == 'edit') {
                          onEdit != null
                              ? onEdit!()
                              : Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          EditPostScreen(post: post)));
                        }
                        if (v == 'delete') _confirmDelete(context);
                      },
                      itemBuilder: (_) => [
                        if (isOwner)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(children: [
                              Icon(Icons.edit_outlined,
                                  size: 18, color: AppTheme.primary),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ]),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [
                            Icon(Icons.delete_outline,
                                size: 18, color: AppTheme.error),
                            SizedBox(width: 8),
                            Text('Delete',
                                style: TextStyle(color: AppTheme.error)),
                          ]),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Content
              Text(post.content,
                  style: const TextStyle(fontSize: 14, height: 1.5)),
              // Images
              if (post.imageUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildImages(post.imageUrls),
              ],
              // Files
              if (post.fileUrls.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...List.generate(
                  post.fileUrls.length,
                  (i) => _FileChip(
                    name: i < post.fileNames.length
                        ? post.fileNames[i]
                        : 'File ${i + 1}',
                    url: post.fileUrls[i],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              // Actions
              Row(
                children: [
                  _ActionBtn(
                    icon: isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    label: '${post.likes.length}',
                    color: isLiked ? Colors.red : Colors.grey.shade500,
                    onTap: auth.user == null
                        ? null
                        : () => feed.toggleLike(
                            post.id, auth.user!.id, post.authorId),
                  ),
                  const SizedBox(width: 16),
                  _ActionBtn(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: '${post.commentCount}',
                    color: Colors.grey.shade500,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PostDetailScreen(post: post)),
                    ),
                  ),
                  const Spacer(),
                  _ActionBtn(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    color: Colors.grey.shade500,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Link copied to clipboard'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImages(List<String> urls) {
    if (urls.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: urls[0],
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            height: 220,
            color: Colors.grey.shade100,
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (_, __, ___) => Container(
            height: 220,
            color: Colors.grey.shade100,
            child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
          ),
        ),
      );
    }
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: urls[i],
            width: 160,
            height: 160,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _FileChip extends StatelessWidget {
  final String name;
  final String url;
  const _FileChip({required this.name, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.attach_file_rounded,
              size: 14, color: AppTheme.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              name,
              style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
