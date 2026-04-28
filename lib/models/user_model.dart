import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? position;
  final String? bio;
  final String role;
  final List<String> joinedGroups;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.position,
    this.bio,
    this.role = 'employee',
    this.joinedGroups = const [],
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return DateTime.now();
    }

    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      position: map['position'],
      bio: map['bio'],
      role: map['role'] ?? 'employee',
      joinedGroups: List<String>.from(map['joinedGroups'] ?? []),
      createdAt: parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'position': position,
        'bio': bio,
        'role': role,
        'joinedGroups': joinedGroups,
        'createdAt': FieldValue.serverTimestamp(),
      };

  bool get isAdmin => role == 'admin';

  UserModel copyWith({
    String? name,
    String? photoUrl,
    String? position,
    String? bio,
    List<String>? joinedGroups,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      position: position ?? this.position,
      bio: bio ?? this.bio,
      role: role,
      joinedGroups: joinedGroups ?? this.joinedGroups,
      createdAt: createdAt,
    );
  }
}
