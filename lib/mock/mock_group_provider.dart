import 'dart:io';
import '../models/group_model.dart';
import '../providers/group_provider.dart';
import 'mock_data.dart';

class MockGroupProvider extends GroupProvider {
  final List<GroupModel> _mockGroups = List.from(mockGroups);

  @override
  Stream<List<GroupModel>> getAllGroups() =>
      Stream.value(List.from(_mockGroups));

  @override
  Stream<List<GroupModel>> getUserGroups(String userId) {
    return Stream.value(
        _mockGroups.where((g) => g.members.contains(userId)).toList());
  }

  @override
  Future<GroupModel?> getGroup(String groupId) async {
    return _mockGroups.firstWhere((g) => g.id == groupId,
        orElse: () => _mockGroups.first);
  }

  @override
  Future<GroupModel?> createGroup({
    required String name,
    required String description,
    required String adminId,
    bool isPrivate = false,
    File? coverImage,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final group = GroupModel(
      id: 'g_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      adminId: adminId,
      members: [adminId],
      isPrivate: isPrivate,
      createdAt: DateTime.now(),
    );
    _mockGroups.add(group);
    notifyListeners();
    return group;
  }

  @override
  Future<void> joinGroup(String groupId, String userId) async {
    final i = _mockGroups.indexWhere((g) => g.id == groupId);
    if (i != -1 && !_mockGroups[i].members.contains(userId)) {
      final members = List<String>.from(_mockGroups[i].members)..add(userId);
      _mockGroups[i] = GroupModel(
        id: _mockGroups[i].id,
        name: _mockGroups[i].name,
        description: _mockGroups[i].description,
        coverUrl: _mockGroups[i].coverUrl,
        adminId: _mockGroups[i].adminId,
        members: members,
        isPrivate: _mockGroups[i].isPrivate,
        createdAt: _mockGroups[i].createdAt,
      );
      notifyListeners();
    }
  }

  @override
  Future<void> leaveGroup(String groupId, String userId) async {
    final i = _mockGroups.indexWhere((g) => g.id == groupId);
    if (i != -1) {
      final members = List<String>.from(_mockGroups[i].members)
        ..remove(userId);
      _mockGroups[i] = GroupModel(
        id: _mockGroups[i].id,
        name: _mockGroups[i].name,
        description: _mockGroups[i].description,
        coverUrl: _mockGroups[i].coverUrl,
        adminId: _mockGroups[i].adminId,
        members: members,
        isPrivate: _mockGroups[i].isPrivate,
        createdAt: _mockGroups[i].createdAt,
      );
      notifyListeners();
    }
  }
}

