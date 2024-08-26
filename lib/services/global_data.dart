import 'package:flutter/material.dart';
import 'package:sandbox_demo/services/local_storage.dart';

class GlobalData with ChangeNotifier {
  static final GlobalData _singleton = GlobalData._internal();
  LocalStorage storage = LocalStorage();
  String? _userToken;
  String? userRole; // Field to store user role
  bool isLoggedIn = false;

  factory GlobalData() {
    return _singleton;
  }

  GlobalData._internal();

  String? get authToken {
    if (_userToken == null) {
      _userToken = storage.read('authToken');
    }
    return _userToken;
  }

  void setUserToken({required String authToken}) {
    storage.write('authToken', authToken);
    _userToken = authToken;
    notifyListeners();
  }

  void login(String userId, String role) {
    setUserToken(authToken: userId);
    this.userRole = role;
    isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _userToken = null;
    userRole = null;
    isLoggedIn = false;
    storage.remove('authToken');
    notifyListeners();
  }

  bool checkIfUserIsLoggedIn() {
    _userToken = storage.read('authToken');
    if (_userToken != null && _userToken!.isNotEmpty) {
      isLoggedIn = true;
      notifyListeners();
      return true;
    } else {
      isLoggedIn = false;
      notifyListeners();
      return false;
    }
  }
}
