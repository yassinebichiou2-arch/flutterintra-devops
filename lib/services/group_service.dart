import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_model.dart';

class GroupService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<GroupModel> createGroup(GroupModel group) async {
    final ref = await _db.collection('groups').add(group.toMap());
    return GroupModel.fromMap(group.toMap(), ref.id);
  }

  Future<void> updateGroup(String groupId, Map<String, dynamic> data) =>
      _db.collection('groups').doc(groupId).update(data);

  Future<void> deleteGroup(String groupId) =>
      _db.collection('groups').doc(groupId).delete();

  Stream<List<GroupModel>> getAllGroups() {
    return _db.collection('groups').orderBy('createdAt', descending: true)
        .snapshots().map((s) => s.docs
            .map((d) => GroupModel.fromMap(d.data(), d.id)).toList());
  }

  Stream<List<GroupModel>> getUserGroups(String userId) {
    return _db.collection('groups')
        .where('members', arrayContains: userId)
        .snapshots().map((s) => s.docs
            .map((d) => GroupModel.fromMap(d.data(), d.id)).toList());
  }

  Future<GroupModel?> getGroup(String groupId) async {
    final doc = await _db.collection('groups').doc(groupId).get();
    if (!doc.exists) return null;
    return GroupModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> joinGroup(String groupId, String userId) async {
    await _db.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayUnion([userId]),
    });
    await _db.collection('users').doc(userId).update({
      'joinedGroups': FieldValue.arrayUnion([groupId]),
    });
  }

  Future<void> leaveGroup(String groupId, String userId) async {
    await _db.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([userId]),
    });
    await _db.collection('users').doc(userId).update({
      'joinedGroups': FieldValue.arrayRemove([groupId]),
    });
  }
}
