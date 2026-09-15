import 'package:flutter/material.dart';

class MemberDashboardController extends ChangeNotifier {
  bool _isActiveTab = true;

  bool get isActiveTab => _isActiveTab;

  void setTab(bool isActive) {
    if (_isActiveTab != isActive) {
      _isActiveTab = isActive;
      notifyListeners();
    }
  }
}
