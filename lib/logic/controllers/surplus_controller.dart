import 'package:flutter/material.dart';

class SurplusController extends ChangeNotifier {
  int _leftoverPortions = 0;

  int get leftoverPortions => _leftoverPortions;

  void increment() {
    _leftoverPortions++;
    notifyListeners();
  }

  void decrement() {
    if (_leftoverPortions > 0) {
      _leftoverPortions--;
      notifyListeners();
    }
  }
}
