import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/notification_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _iconFor(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'message':
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'like':
        return Colors.red;
      case 'comment':
        return Colors.blue;
      case 'message':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final feed = context.read<FeedProvider>();
    if (auth.user == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => feed.markAllNotificationsRead(auth.user!.id),
            child: const Text('Mark all read',
                style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: feed.getNotifications(auth.user!.id),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final notifs = snap.data ?? [];
          if (notifs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No notifications',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: notifs.length,
            itemBuilder: (_, i) {
              final n = notifs[i];
              final color = _colorFor(n.type);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(_iconFor(n.type), color: color),
                ),
                title: Text(n.title,
                    style: TextStyle(
                        fontWeight:
                            n.isRead ? FontWeight.normal : FontWeight.bold)),
                subtitle: Text(n.body),
                trailing: Text(timeago.format(n.createdAt),
                    style:
                        const TextStyle(fontSize: 11, color: Colors.grey)),
                tileColor: n.isRead
                    ? null
                    : Colors.blue.withValues(alpha: 0.05),
                onTap: () => feed.markNotificationRead(n.id),
              );
            },
          );
        },
      ),
    );
  }
}

