import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import 'mock_data.dart';

class MockAuthProvider extends AppAuthProvider {
  @override
  Future<bool> signIn({required String email, required String password}) async {
    setLoadingPublic(true);
    setErrorPublic(null);
    await Future.delayed(const Duration(milliseconds: 800));
    final found = mockUsers.where(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    ).toList();
    if (found.isNotEmpty && password.length >= 6) {
      setUserPublic(found.first);
      setLoadingPublic(false);
      return true;
    }
    setErrorPublic('Invalid email or password. Try alice@FlutterIntra.com / 123456');
    setLoadingPublic(false);
    return false;
  }

  @override
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    String? position,
  }) async {
    setLoadingPublic(true);
    await Future.delayed(const Duration(milliseconds: 800));
    setUserPublic(UserModel(
      id: 'u_new',
      name: name,
      email: email,
      position: position,
      role: 'employee',
      createdAt: DateTime.now(),
    ));
    setLoadingPublic(false);
    return true;
  }

  @override
  Future<void> signOut() async {
    setUserPublic(null);
    notifyListeners();
  }

  @override
  Future<void> loadUser(String uid) async {}

  @override
  Future<bool> updateProfile({
    String? name,
    String? position,
    String? bio,
    String? photoUrl,
  }) async {
    setLoadingPublic(true);
    await Future.delayed(const Duration(milliseconds: 600));
    setUserPublic(user?.copyWith(name: name, position: position, bio: bio));
    setLoadingPublic(false);
    return true;
  }

  @override
  Future<void> resetPassword(String email) async {}
}

