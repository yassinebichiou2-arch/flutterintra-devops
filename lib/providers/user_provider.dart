import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _service;
  UserProvider({UserService? service}) : _service = service ?? UserService();

  Future<UserModel?> getUser(String uid) => _service.getUser(uid);
  Future<List<UserModel>> searchUsers(String q) => _service.searchUsers(q);
  Future<List<UserModel>> getAllUsers() => _service.getAllUsers();
}

