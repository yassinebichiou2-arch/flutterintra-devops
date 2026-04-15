import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/user_avatar.dart';

class ChatDetailScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserId;
  final String otherUserName;

  const ChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AppAuthProvider>();
    context.read<ChatProvider>().markRead(widget.conversationId, auth.user!.id);
  }

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

  Future<void> _send({File? file, String? fileName}) async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty && file == null) return;
    final auth = context.read<AppAuthProvider>();
    final chat = context.read<ChatProvider>();
    _msgCtrl.clear();
    await chat.sendMessage(
      widget.conversationId,
      auth.user!.id,
      auth.user!.name,
      auth.user!.photoUrl,
      text,
      file: file,
      fileName: fileName,
    );
    _scrollToBottom();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      await _send(
        file: File(result.files.single.path!),
        fileName: result.files.single.name,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final chat = context.read<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            FutureBuilder(
              future: context.read<UserProvider>().getUser(widget.otherUserId),
              builder: (_, snap) => UserAvatar(
                photoUrl: snap.data?.photoUrl,
                name: widget.otherUserName,
                radius: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.otherUserName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: chat.getMessages(widget.conversationId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final msgs = snap.data ?? [];
                _scrollToBottom();
                if (msgs.isEmpty) {
                  return const Center(
                      child: Text('Say hello!',
                          style: TextStyle(color: Colors.grey)));
                }
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
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _pickFile,
          ),
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                isDense: true,
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          IconButton(icon: const Icon(Icons.send), onPressed: () => _send()),
        ],
      ),
    );
  }
}




