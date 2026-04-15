import 'dart:io';
import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../services/storage_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final StorageService _storageService = StorageService();

  Stream<List<ConversationModel>> getConversations(String userId) =>
      _chatService.getConversations(userId);

  Stream<List<MessageModel>> getMessages(String conversationId) =>
      _chatService.getMessages(conversationId);

  Stream<List<MessageModel>> getGroupMessages(String groupId) =>
      _chatService.getGroupMessages(groupId);

  Future<ConversationModel> getOrCreateConversation(
    String currentUserId,
    String currentUserName,
    String otherUserId,
    String otherUserName,
  ) =>
      _chatService.getOrCreateConversation(
          currentUserId, currentUserName, otherUserId, otherUserName);

  Future<void> sendMessage(
    String conversationId,
    String senderId,
    String senderName,
    String? senderPhotoUrl,
    String content, {
    File? file,
    String? fileName,
  }) async {
    String? fileUrl;
    if (file != null && fileName != null) {
      fileUrl = await _storageService.uploadFile(file, 'chat_files', fileName);
    }
    await _chatService.sendMessage(
      conversationId,
      MessageModel(
        id: '',
        senderId: senderId,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        content: content,
        fileUrl: fileUrl,
        fileName: fileName,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> sendGroupMessage(
    String groupId,
    String senderId,
    String senderName,
    String? senderPhotoUrl,
    String content,
  ) async {
    await _chatService.sendGroupMessage(
      groupId,
      MessageModel(
        id: '',
        senderId: senderId,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        content: content,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> markRead(String conversationId, String userId) =>
      _chatService.markMessagesRead(conversationId, userId);
}

