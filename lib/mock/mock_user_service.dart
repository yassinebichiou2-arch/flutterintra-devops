import '../models/user_model.dart';
import '../services/user_service.dart';
import 'mock_data.dart';

class MockUserService extends UserService {
  @override
  Future<UserModel?> getUser(String uid) async {
    return mockUsers.firstWhere(
      (u) => u.id == uid,
      orElse: () => mockUsers.first,
    );
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    return mockUsers
        .where((u) => u.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<List<UserModel>> getAllUsers() async => mockUsers;
}

