import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String name;
  final String description;
  final String? coverUrl;
  final String adminId;
  final List<String> members;
  final bool isPrivate;
  final DateTime createdAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    this.coverUrl,
    required this.adminId,
    this.members = const [],
    this.isPrivate = false,
    required this.createdAt,
  });

  factory GroupModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return DateTime.now();
    }

    return GroupModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      coverUrl: map['coverUrl'],
      adminId: map['adminId'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      isPrivate: map['isPrivate'] ?? false,
      createdAt: parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'coverUrl': coverUrl,
        'adminId': adminId,
        'members': members,
        'isPrivate': isPrivate,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
