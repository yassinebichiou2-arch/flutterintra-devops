import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderPhotoUrl;
  final String content;
  final String? fileUrl;
  final String? fileName;
  final bool isRead;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    required this.content,
    this.fileUrl,
    this.fileName,
    this.isRead = false,
    required this.createdAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderPhotoUrl: map['senderPhotoUrl'],
      content: map['content'] ?? '',
      fileUrl: map['fileUrl'],
      fileName: map['fileName'],
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'senderName': senderName,
        'senderPhotoUrl': senderPhotoUrl,
        'content': content,
        'fileUrl': fileUrl,
        'fileName': fileName,
        'isRead': isRead,
        'createdAt': createdAt,
      };
}

class ConversationModel {
  final String id;
  final List<String> participants;
  final List<String> participantNames;
  final String lastMessage;
  final DateTime lastMessageAt;
  final Map<String, int> unreadCount;

  ConversationModel({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCount = const {},
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map, String id) {
    return ConversationModel(
      id: id,
      participants: List<String>.from(map['participants'] ?? []),
      participantNames: List<String>.from(map['participantNames'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageAt:
          (map['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
        'participants': participants,
        'participantNames': participantNames,
        'lastMessage': lastMessage,
        'lastMessageAt': lastMessageAt,
        'unreadCount': unreadCount,
      };
}
