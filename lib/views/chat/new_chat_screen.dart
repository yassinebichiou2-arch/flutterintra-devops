import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/user_avatar.dart';
import 'chat_detail_screen.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final _searchCtrl = TextEditingController();
  List<UserModel> _users = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    final auth = context.read<AppAuthProvider>();
    final all = await context.read<UserProvider>().getAllUsers();
    setState(() {
      _users = all.where((u) => u.id != auth.user?.id).toList();
      _loading = false;
    });
  }

  List<UserModel> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return _users;
    return _users
        .where((u) =>
            u.name.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final chat = context.read<ChatProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('New Message')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final u = _filtered[i];
                      return ListTile(
                        leading: UserAvatar(
                            photoUrl: u.photoUrl, name: u.name, radius: 22),
                        title: Text(u.name),
                        subtitle: Text(u.position ?? u.email),
                        onTap: () async {
                          final conv =
                              await chat.getOrCreateConversation(
                            auth.user!.id,
                            auth.user!.name,
                            u.id,
                            u.name,
                          );
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatDetailScreen(
                                  conversationId: conv.id,
                                  otherUserId: u.id,
                                  otherUserName: u.name,
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}




