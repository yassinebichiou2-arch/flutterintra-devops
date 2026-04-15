import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AppAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _loading = false;
  String? _error;

  UserModel? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.role == 'admin';

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  // Protected setters for mock subclass
  void setLoadingPublic(bool v) { _loading = v; notifyListeners(); }
  void setErrorPublic(String? e) { _error = e; notifyListeners(); }
  void setUserPublic(UserModel? u) { _user = u; notifyListeners(); }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    String? position,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      _user = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        position: position,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      _user = await _authService.signIn(email: email, password: password);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> loadUser(String uid) async {
    _user = await _authService.getUser(uid);
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? name,
    String? position,
    String? bio,
    String? photoUrl,
  }) async {
    if (_user == null) return false;
    _setLoading(true);
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (position != null) data['position'] = position;
      if (bio != null) data['bio'] = bio;
      if (photoUrl != null) data['photoUrl'] = photoUrl;

      await _authService.updateUser(_user!.id, data);
      _user = _user!.copyWith(
        name: name,
        position: position,
        bio: bio,
        photoUrl: photoUrl ?? _user!.photoUrl,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(String email) =>
      _authService.resetPassword(email);
}


