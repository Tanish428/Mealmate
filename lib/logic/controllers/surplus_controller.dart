import 'package:flutter/material.dart';

class SurplusController extends ChangeNotifier {
  int _leftoverPortions;
  String? _selectedPartner;
  bool _isAllocating = false;
  String? _successMessage;
  String? _errorMessage;

  SurplusController({int initialPortions = 5}) : _leftoverPortions = initialPortions;

  int get leftoverPortions => _leftoverPortions;
  int get portionsRemaining => _leftoverPortions;
  String? get selectedPartner => _selectedPartner;
  bool get isAllocating => _isAllocating;
  String? get successMessage => _successMessage;
  String? get errorMessage => _errorMessage;

  /// Environmental and community impact calculations
  int get peopleFed => _leftoverPortions;
  double get co2SavedKg => _leftoverPortions * 1.8; // ~1.8kg CO2e per meal saved
  double get waterSavedLiters => _leftoverPortions * 250.0; // ~250 liters saved per meal

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

  void setPortions(int count) {
    if (count >= 0) {
      _leftoverPortions = count;
      notifyListeners();
    }
  }

  void selectPartner(String partner) {
    _selectedPartner = partner;
    notifyListeners();
  }

  Future<bool> allocateSurplus({String? partnerName}) async {
    final partner = partnerName ?? _selectedPartner;
    if (_leftoverPortions <= 0) {
      _errorMessage = 'No surplus portions to allocate.';
      notifyListeners();
      return false;
    }

    _isAllocating = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Simulate dispatch latency or database recording
      await Future.delayed(const Duration(milliseconds: 300));

      _successMessage = 'Successfully allocated $_leftoverPortions portions to ${partner ?? "partner organization"}!';
      _leftoverPortions = 0;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to allocate surplus: $e';
      return false;
    } finally {
      _isAllocating = false;
      notifyListeners();
    }
  }
}
