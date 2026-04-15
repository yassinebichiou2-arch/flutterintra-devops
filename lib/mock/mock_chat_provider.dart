import 'dart:io';
import '../models/message_model.dart';
import '../providers/chat_provider.dart';
import 'mock_data.dart';

class MockChatProvider extends ChatProvider {
  final List<ConversationModel> _convs = List.from(mockConversations);
  final Map<String, List<MessageModel>> _msgs = {
    'u1_u2': List.from(mockMessages),
    'u1_u3': [],
  };
  final Map<String, List<MessageModel>> _groupMsgs = {};

  @override
  Stream<List<ConversationModel>> getConversations(String userId) {
    return Stream.value(
        _convs.where((c) => c.participants.contains(userId)).toList());
  }

  @override
  Stream<List<MessageModel>> getMessages(String conversationId) {
    return Stream.value(_msgs[conversationId] ?? []);
  }

  @override
  Stream<List<MessageModel>> getGroupMessages(String groupId) {
    return Stream.value(_groupMsgs[groupId] ?? []);
  }

  @override
  Future<ConversationModel> getOrCreateConversation(
    String currentUserId,
    String currentUserName,
    String otherUserId,
    String otherUserName,
  ) async {
    final ids = [currentUserId, otherUserId]..sort();
    final id = '${ids[0]}_${ids[1]}';
    final existing = _convs.where((c) => c.id == id).toList();
    if (existing.isNotEmpty) return existing.first;
    final conv = ConversationModel(
      id: id,
      participants: [currentUserId, otherUserId],
      participantNames: [currentUserName, otherUserName],
      lastMessage: '',
      lastMessageAt: DateTime.now(),
    );
    _convs.add(conv);
    _msgs[id] = [];
    notifyListeners();
    return conv;
  }

  @override
  Future<void> sendMessage(
    String conversationId,
    String senderId,
    String senderName,
    String? senderPhotoUrl,
    String content, {
    File? file,
    String? fileName,
  }) async {
    final msg = MessageModel(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      senderName: senderName,
      senderPhotoUrl: senderPhotoUrl,
      content: content,
      fileName: fileName,
      createdAt: DateTime.now(),
    );
    _msgs[conversationId] ??= [];
    _msgs[conversationId]!.add(msg);
    final i = _convs.indexWhere((c) => c.id == conversationId);
    if (i != -1) {
      _convs[i] = ConversationModel(
        id: _convs[i].id,
        participants: _convs[i].participants,
        participantNames: _convs[i].participantNames,
        lastMessage: content.isNotEmpty ? content : (fileName ?? 'File'),
        lastMessageAt: DateTime.now(),
      );
    }
    notifyListeners();
  }

  @override
  Future<void> sendGroupMessage(
    String groupId,
    String senderId,
    String senderName,
    String? senderPhotoUrl,
    String content,
  ) async {
    final msg = MessageModel(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      senderName: senderName,
      senderPhotoUrl: senderPhotoUrl,
      content: content,
      createdAt: DateTime.now(),
    );
    _groupMsgs[groupId] ??= [];
    _groupMsgs[groupId]!.add(msg);
    notifyListeners();
  }

  @override
  Future<void> markRead(String conversationId, String userId) async {}
}

