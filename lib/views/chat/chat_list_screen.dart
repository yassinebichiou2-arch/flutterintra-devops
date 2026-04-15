import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/user_avatar.dart';
import 'chat_detail_screen.dart';
import 'new_chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final chat = context.read<ChatProvider>();
    if (auth.user == null) {
      return const Center(child: Text('Login to access messages'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: StreamBuilder<List<ConversationModel>>(
        stream: chat.getConversations(auth.user!.id),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final convs = snap.data ?? [];
          if (convs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No conversations yet',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: convs.length,
            itemBuilder: (_, i) {
              final conv = convs[i];
              final otherIdx =
                  conv.participants.indexOf(auth.user!.id) == 0 ? 1 : 0;
              final otherName = conv.participantNames.length > otherIdx
                  ? conv.participantNames[otherIdx]
                  : 'Unknown';
              final otherId = conv.participants.length > otherIdx
                  ? conv.participants[otherIdx]
                  : '';
              final unread = conv.unreadCount[auth.user!.id] ?? 0;

              return ListTile(
                leading: FutureBuilder(
                  future: context.read<UserProvider>().getUser(otherId),
                  builder: (_, snap) => UserAvatar(
                    photoUrl: snap.data?.photoUrl,
                    name: otherName,
                    radius: 22,
                  ),
                ),
                title: Text(otherName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  conv.lastMessage.isEmpty ? 'No messages' : conv.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(timeago.format(conv.lastMessageAt),
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    if (unread > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('$unread',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11)),
                      ),
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatDetailScreen(
                      conversationId: conv.id,
                      otherUserId: otherId,
                      otherUserName: otherName,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const NewChatScreen())),
        child: const Icon(Icons.edit),
      ),
    );
  }
}




