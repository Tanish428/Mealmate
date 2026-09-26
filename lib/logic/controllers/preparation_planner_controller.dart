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
  Map<String, dynamic> _mealTimings = {};

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
    if (_selectedMeal == null) return '';
    final data = _mealTimings[_selectedMeal];
    if (data != null && data['start'] != null && data['end'] != null) {
      return '${_formatTime12Hour(data['start'])} - ${_formatTime12Hour(data['end'])}';
    }
    
    
    
    return '';
  }

  String get readyByTime {
    if (_selectedMeal == null) return '';
    final data = _mealTimings[_selectedMeal];
    if (data != null && data['start'] != null) {
      final parts = data['start'].split(':');
      final dt = DateTime(2020, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
      final readyBy = dt.subtract(const Duration(minutes: 15));
      return "${readyBy.hour > 12 ? readyBy.hour - 12 : (readyBy.hour == 0 ? 12 : readyBy.hour)}:${readyBy.minute.toString().padLeft(2, '0')} ${readyBy.hour >= 12 ? 'PM' : 'AM'}";
    }
    return '';
  }
  
  String _formatTime12Hour(String time) {
    try {
      final parts = time.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final dt = DateTime(2020, 1, 1, h, m);
      return "${dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour)}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}";
    } catch (_) {
      return time;
    }
  }

  DateTime? get _cutoffDateTime {
    if (_selectedMeal == null) return null;
    int cutoffHour = 0;
    int cutoffMinute = 0;
    
    final data = _mealTimings[_selectedMeal];
    if (data != null && data['cutoff'] != null) {
      final parts = data['cutoff'].split(':');
      cutoffHour = int.parse(parts[0]);
      cutoffMinute = int.parse(parts[1]);
    } else {
      return null;
    }
    
    return DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, cutoffHour, cutoffMinute);
  }

  bool get isFinalized {
    if (_selectedMeal == null) return false;
    
    final now = DateTime.now();
    final cutoffDate = _cutoffDateTime;
    if (cutoffDate == null) return false;
    
    return now.isAfter(cutoffDate) || now.isAtSameMomentAs(cutoffDate);
  }
  
  String get remainingTimeUntilCutoff {
    if (isFinalized) return '';
    if (_selectedMeal == null) return '';
    
    final now = DateTime.now();
    final cutoffDate = _cutoffDateTime;
    if (cutoffDate == null) return '';
    
    final diff = cutoffDate.difference(now);
    
    if (diff.inHours > 24) return "Cutoff tomorrow";
    return "Cutoff in ${diff.inHours}h ${diff.inMinutes % 60}m";
  }

  String get formattedCutoffTime {
    if (_selectedMeal == null) return '';
    final data = _mealTimings[_selectedMeal];
    if (data != null && data['cutoff'] != null) {
      return _formatTime12Hour(data['cutoff']);
    }
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
    final time = now.hour + now.minute / 60.0;

    double getEndTime(String m) {
      final data = _mealTimings[m];
      if (data != null && data['end'] != null) {
        final parts = data['end'].split(':');
        return int.parse(parts[0]) + int.parse(parts[1]) / 60.0;
      }
      if (m == 'breakfast') return 10.0;
      if (m == 'lunch') return 15.0;
      if (m == 'dinner') return 22.0;
      return 24.0;
    }

    if (time < getEndTime('breakfast') && _servedMeals.contains('breakfast')) {
      _selectedMeal = 'breakfast';
    } else if (time < getEndTime('lunch') && _servedMeals.contains('lunch')) {
      _selectedMeal = 'lunch';
    } else if (time < getEndTime('dinner') && _servedMeals.contains('dinner')) {
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
