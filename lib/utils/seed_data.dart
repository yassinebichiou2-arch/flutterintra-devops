import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Run this once to create test accounts in Firebase
Future<void> seedTestData() async {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  final testUsers = [
    {
      'email': 'admin@flutterintra.com',
      'password': 'Admin123',
      'name': 'Admin User',
      'position': 'Administrator',
      'role': 'admin',
    },
    {
      'email': 'alice@flutterintra.com',
      'password': 'Alice123',
      'name': 'Alice Martin',
      'position': 'Flutter Developer',
      'role': 'employee',
    },
    {
      'email': 'bob@flutterintra.com',
      'password': 'Bob12345',
      'name': 'Bob Dupont',
      'position': 'UI/UX Designer',
      'role': 'employee',
    },
  ];

  for (final u in testUsers) {
    try {
      final cred = await auth.createUserWithEmailAndPassword(
        email: u['email']!,
        password: u['password']!,
      );
      await db.collection('users').doc(cred.user!.uid).set({
        'name': u['name'],
        'email': u['email'],
        'position': u['position'],
        'role': u['role'],
        'bio': null,
        'photoUrl': null,
        'joinedGroups': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
      // ignore: avoid_print
      print('✅ Created: ${u['email']}');
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ ${u['email']}: $e');
    }
  }
}
