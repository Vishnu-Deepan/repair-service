import 'package:flutter/material.dart';

import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  late User _user;

  User get user => _user;

  void updateUser(String name, String email) {
    _user = User(name, email);
    notifyListeners(); 
  }
}