import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String content;
  final List<String> imageUrls;
  final List<String> fileUrls;
  final List<String> fileNames;
  final List<String> likes;
  final int commentCount;
  final String? groupId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.content,
    this.imageUrls = const [],
    this.fileUrls = const [],
    this.fileNames = const [],
    this.likes = const [],
    this.commentCount = 0,
    this.groupId,
    required this.createdAt,
    this.updatedAt,
  });

  factory PostModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return DateTime.now();
    }

    return PostModel(
      id: id,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorPhotoUrl: map['authorPhotoUrl'],
      content: map['content'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      fileUrls: List<String>.from(map['fileUrls'] ?? []),
      fileNames: List<String>.from(map['fileNames'] ?? []),
      likes: List<String>.from(map['likes'] ?? []),
      commentCount: map['commentCount'] ?? 0,
      groupId: map['groupId'],
      createdAt: parseDate(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? parseDate(map['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'authorId': authorId,
        'authorName': authorName,
        'authorPhotoUrl': authorPhotoUrl,
        'content': content,
        'imageUrls': imageUrls,
        'fileUrls': fileUrls,
        'fileNames': fileNames,
        'likes': likes,
        'commentCount': commentCount,
        'groupId': groupId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      };

  PostModel copyWith({
    String? content,
    List<String>? imageUrls,
    List<String>? fileUrls,
    List<String>? fileNames,
    List<String>? likes,
    int? commentCount,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorPhotoUrl: authorPhotoUrl,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      fileUrls: fileUrls ?? this.fileUrls,
      fileNames: fileNames ?? this.fileNames,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
      groupId: groupId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
