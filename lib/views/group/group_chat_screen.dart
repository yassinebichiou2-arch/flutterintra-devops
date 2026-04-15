import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/group_model.dart';
import '../../models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat_bubble.dart';

class GroupChatScreen extends StatefulWidget {
  final GroupModel group;
  const GroupChatScreen({super.key, required this.group});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    final auth = context.read<AppAuthProvider>();
    final chat = context.read<ChatProvider>();
    _msgCtrl.clear();
    await chat.sendGroupMessage(
      widget.group.id,
      auth.user!.id,
      auth.user!.name,
      auth.user!.photoUrl,
      text,
    );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final chat = context.read<ChatProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('${widget.group.name} – Forum')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: chat.getGroupMessages(widget.group.id),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final msgs = snap.data ?? [];
                _scrollToBottom();
                return ListView.builder(
                  controller: _scrollCtrl,
                  itemCount: msgs.length,
                  itemBuilder: (_, i) => ChatBubble(
                    message: msgs[i],
                    isMe: msgs[i].senderId == auth.user?.id,
                  ),
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
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
              controller: _msgCtrl,
              decoration: const InputDecoration(
                hintText: 'Write a message...',
                isDense: true,
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          IconButton(icon: const Icon(Icons.send), onPressed: _send),
        ],
      ),
    );
  }
}




