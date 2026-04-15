import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final String? referenceId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.referenceId,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return DateTime.now();
    }

    return NotificationModel(
      id: id,
      userId: map['userId'] ?? '',
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      referenceId: map['referenceId'],
      isRead: map['isRead'] ?? false,
      createdAt: parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'type': type,
        'title': title,
        'body': body,
        'referenceId': referenceId,
        'isRead': isRead,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
