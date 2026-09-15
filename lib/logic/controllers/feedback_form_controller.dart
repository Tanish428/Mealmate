import 'package:flutter/material.dart';

class FeedbackFormController extends ChangeNotifier {
  String? _selectedMeal;
  int _rating = 0;

  String? get selectedMeal => _selectedMeal;
  int get rating => _rating;

  void setMeal(String meal) {
    _selectedMeal = meal;
    notifyListeners();
  }

  void setRating(int newRating) {
    _rating = newRating;
    notifyListeners();
  }
}
