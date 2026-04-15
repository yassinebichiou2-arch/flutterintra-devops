import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Stream<UserModel?> watchUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!, doc.id);
    });
  }

  Future<List<UserModel>> searchUsers(String query) async {
    final snap = await _db
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();
    return snap.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
  }

  Future<List<UserModel>> getAllUsers() async {
    final snap = await _db.collection('users').get();
    return snap.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
  }
}
