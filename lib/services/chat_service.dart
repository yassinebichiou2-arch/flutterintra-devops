import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _convId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Future<ConversationModel> getOrCreateConversation(
    String currentUserId,
    String currentUserName,
    String otherUserId,
    String otherUserName,
  ) async {
    final id = _convId(currentUserId, otherUserId);
    final doc = await _db.collection('conversations').doc(id).get();
    if (doc.exists) {
      return ConversationModel.fromMap(doc.data()!, doc.id);
    }
    final conv = ConversationModel(
      id: id,
      participants: [currentUserId, otherUserId],
      participantNames: [currentUserName, otherUserName],
      lastMessage: '',
      lastMessageAt: DateTime.now(),
    );
    await _db.collection('conversations').doc(id).set(conv.toMap());
    return conv;
  }

  // Uses simple query — no composite index needed
  // Admin: get all conversations
  Stream<List<ConversationModel>> getAllConversations() {
    return _db
        .collection('conversations')
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => ConversationModel.fromMap(d.data(), d.id))
            .toList());
  }

  Stream<List<ConversationModel>> getConversations(String userId) {
    return _db
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((s) {
      final convs = s.docs
          .map((d) => ConversationModel.fromMap(d.data(), d.id))
          .toList();
      convs.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
      return convs;
    });
  }

  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .snapshots()
        .map((s) {
      final msgs = s.docs
          .map((d) => MessageModel.fromMap(d.data(), d.id))
          .toList();
      msgs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return msgs;
    });
  }

  Future<void> sendMessage(
      String conversationId, MessageModel message) async {
    await _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .add(message.toMap());
    await _db.collection('conversations').doc(conversationId).update({
      'lastMessage': message.content.isNotEmpty
          ? message.content
          : (message.fileName ?? 'File'),
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markMessagesRead(
      String conversationId, String userId) async {}

  Stream<List<MessageModel>> getGroupMessages(String groupId) {
    return _db
        .collection('group_chats')
        .doc(groupId)
        .collection('messages')
        .snapshots()
        .map((s) {
      final msgs = s.docs
          .map((d) => MessageModel.fromMap(d.data(), d.id))
          .toList();
      msgs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return msgs;
    });
  }

  Future<void> sendGroupMessage(
      String groupId, MessageModel message) async {
    await _db
        .collection('group_chats')
        .doc(groupId)
        .collection('messages')
        .add(message.toMap());
  }
}
