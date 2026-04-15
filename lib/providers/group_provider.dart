import 'dart:io';
import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../services/group_service.dart';
import '../services/storage_service.dart';

class GroupProvider extends ChangeNotifier {
  final GroupService _groupService = GroupService();
  final StorageService _storageService = StorageService();

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  Stream<List<GroupModel>> getAllGroups() => _groupService.getAllGroups();
  Stream<List<GroupModel>> getUserGroups(String userId) =>
      _groupService.getUserGroups(userId);

  Future<GroupModel?> createGroup({
    required String name,
    required String description,
    required String adminId,
    bool isPrivate = false,
    File? coverImage,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      String? coverUrl;
      if (coverImage != null) {
        coverUrl = await _storageService.uploadImage(coverImage, 'groups');
      }
      return await _groupService.createGroup(GroupModel(
        id: '',
        name: name,
        description: description,
        coverUrl: coverUrl,
        adminId: adminId,
        members: [adminId],
        isPrivate: isPrivate,
        createdAt: DateTime.now(),
      ));
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> joinGroup(String groupId, String userId) =>
      _groupService.joinGroup(groupId, userId);

  Future<void> leaveGroup(String groupId, String userId) =>
      _groupService.leaveGroup(groupId, userId);

  Future<GroupModel?> getGroup(String groupId) =>
      _groupService.getGroup(groupId);
}

