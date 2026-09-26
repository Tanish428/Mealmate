import 'package:flutter/material.dart';
import '../../data/repos/mess_repo.dart';
import '../../data/repos/attendance_repo.dart';
import '../../data/repos/menu_repo.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

class PreparationPlannerController extends ChangeNotifier {
  final MessRepository _messRepo;
  final AttendanceRepo _attendanceRepo;
  final MenuRepository _menuRepo;

  bool _isLoading = false;
  String? _errorMessage;

  DateTime _selectedDate = DateTime.now();
  String? _selectedMeal;
  List<String> _servedMeals = [];
  
  int _totalJoinedMembers = 0;
  int _optedOutCount = 0;
  int _extraPlates = 0;
  bool _safetyBufferEnabled = false;
  
  String _messId = '';
  String _messName = '';
  List<String> _menuItemsList = [];

  PreparationPlannerController({
    MessRepository? messRepo,
    AttendanceRepo? attendanceRepo,
    MenuRepository? menuRepo,
  })  : _messRepo = messRepo ?? MessRepository(),
        _attendanceRepo = attendanceRepo ?? AttendanceRepo(),
        _menuRepo = menuRepo ?? MenuRepository() {
    _init();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;
  String? get selectedMeal => _selectedMeal;
  List<String> get servedMeals => _servedMeals;
  List<String> get menuItemsList => _menuItemsList;

  int get totalJoinedMembers => _totalJoinedMembers;
  int get optedOutCount => _optedOutCount;
  int get attendingMembers => math.max(0, _totalJoinedMembers - _optedOutCount);
  int get extraPlates => _extraPlates;
  bool get safetyBufferEnabled => _safetyBufferEnabled;
  
  int get finalCookingTarget {
    final baseTarget = attendingMembers + _extraPlates;
    final multiplier = _safetyBufferEnabled ? 1.05 : 1.0;
    return (baseTarget * multiplier).ceil();
  }

  String get serviceHours {
    if (_selectedMeal == 'breakfast') return '7:30 AM - 9:30 AM';
    if (_selectedMeal == 'lunch') return '12:30 PM - 2:30 PM';
    if (_selectedMeal == 'dinner') return '7:30 PM - 9:30 PM';
    return '';
  }

  String get readyByTime {
    if (_selectedMeal == 'breakfast') return '7:15 AM';
    if (_selectedMeal == 'lunch') return '12:15 PM';
    if (_selectedMeal == 'dinner') return '7:15 PM';
    return '';
  }

  bool get isFinalized {
    if (_selectedMeal == null) return false;
    
    final now = DateTime.now();
    
    if (_selectedDate.year < now.year ||
        (_selectedDate.year == now.year && _selectedDate.month < now.month) ||
        (_selectedDate.year == now.year && _selectedDate.month == now.month && _selectedDate.day < now.day)) {
      return true; // Past date
    }
    
    if (_selectedDate.year > now.year ||
        (_selectedDate.year == now.year && _selectedDate.month > now.month) ||
        (_selectedDate.year == now.year && _selectedDate.month == now.month && _selectedDate.day > now.day)) {
      return false; // Future date
    }

    int cutoffHour = 0;
    if (_selectedMeal == 'breakfast') cutoffHour = 7;
    else if (_selectedMeal == 'lunch') cutoffHour = 10;
    else if (_selectedMeal == 'dinner') cutoffHour = 19;
    else return false;

    return now.hour >= cutoffHour;
  }
  
  String get remainingTimeUntilCutoff {
    if (isFinalized) return '';
    if (_selectedMeal == null) return '';
    
    final now = DateTime.now();
    
    int cutoffHour = 0;
    if (_selectedMeal == 'breakfast') cutoffHour = 7;
    else if (_selectedMeal == 'lunch') cutoffHour = 10;
    else if (_selectedMeal == 'dinner') cutoffHour = 19;
    
    final cutoffDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, cutoffHour, 0);
    final diff = cutoffDate.difference(now);
    
    if (diff.inHours > 24) return "Cutoff tomorrow";
    return "Cutoff in ${diff.inHours}h ${diff.inMinutes % 60}m";
  }

  String get formattedCutoffTime {
    if (_selectedMeal == 'breakfast') return '07:00 AM';
    if (_selectedMeal == 'lunch') return '10:00 AM';
    if (_selectedMeal == 'dinner') return '07:00 PM';
    return '';
  }

  String generateWhatsAppSummary() {
    final dateLabel = DateFormat('MMM dd, yyyy').format(_selectedDate);
    final statusLabel = isFinalized 
        ? 'FINAL (Cutoff Closed at $formattedCutoffTime)'
        : 'TENTATIVE (Cutoff at $formattedCutoffTime)';

    final menuItemsText = _menuItemsList.isNotEmpty 
        ? _menuItemsList.map((item) => '- $item').join('\n')
        : '- Menu not updated';

    return '''
*MEALMATE 👨‍🍳 KITCHEN PREP ORDER*

*Mess:* $_messName
*Meal:* ${_selectedMeal?.toUpperCase() ?? ''} ($dateLabel)
*Status:* $statusLabel
*Service Hours:* $serviceHours
*Ready By:* $readyByTime

*TOTAL PLATES TO COOK: $finalCookingTarget*

Attending Members: $attendingMembers
Staff / Day Guests: +$_extraPlates
Opted Out / On Leave: $_optedOutCount

*TODAY'S MENU:*
$menuItemsText

*KITCHEN NOTES:*
Ensure food is transferred to hot containers by $readyByTime

_Generated via MealMate Owner App_
'''.trim();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final messDetails = await _messRepo.getOwnerMessDetails();
      if (messDetails != null) {
        _messId = messDetails['id']?.toString() ?? '';
        _messName = messDetails['mess_name']?.toString() ?? 'Unknown Mess';
        final rawMeals = messDetails['served_meals'];
        if (rawMeals is List) {
          _servedMeals = rawMeals.map((e) => e.toString().toLowerCase()).toList();
        }
      }

      final members = await _messRepo.getMessMembers();
      _totalJoinedMembers = members.length;

      _autoSelectInitialMeal();
      await _fetchData();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void _autoSelectInitialMeal() {
    if (_servedMeals.isEmpty) return;
    
    final now = DateTime.now();
    if (now.hour < 10 && _servedMeals.contains('breakfast')) {
      _selectedMeal = 'breakfast';
    } else if (now.hour < 15 && _servedMeals.contains('lunch')) {
      _selectedMeal = 'lunch';
    } else if (now.hour < 22 && _servedMeals.contains('dinner')) {
      _selectedMeal = 'dinner';
    } else {
      _selectedDate = now.add(const Duration(days: 1));
      _selectedMeal = _servedMeals.first;
    }
  }

  Future<void> _fetchData() async {
    if (_messId.isEmpty || _selectedMeal == null) return;
    try {
      _optedOutCount = await _attendanceRepo.getOptedOutCount(
        messId: _messId,
        date: _selectedDate,
        mealType: _selectedMeal!,
      );

      final menus = await _menuRepo.getMenuForDate(_selectedDate);
      final match = menus.firstWhere(
        (m) => m['meal_type']?.toString().toLowerCase() == _selectedMeal,
        orElse: () => {},
      );

      if (match.isNotEmpty && match['items'] is List) {
        _menuItemsList = (match['items'] as List).map((e) => e.toString()).toList();
      } else {
        _menuItemsList = [];
      }
    } catch (e) {
      // Ignore
    }
  }

  void setDate(DateTime date) async {
    _selectedDate = date;
    _isLoading = true;
    notifyListeners();
    await _fetchData();
    _isLoading = false;
    notifyListeners();
  }

  void setMeal(String meal) async {
    _selectedMeal = meal;
    _isLoading = true;
    notifyListeners();
    await _fetchData();
    _isLoading = false;
    notifyListeners();
  }
  
  void incrementExtraPlates() {
    _extraPlates++;
    notifyListeners();
  }
  
  void decrementExtraPlates() {
    if (_extraPlates > 0) {
      _extraPlates--;
      notifyListeners();
    }
  }
  
  void toggleSafetyBuffer(bool value) {
    _safetyBufferEnabled = value;
    notifyListeners();
  }
}
