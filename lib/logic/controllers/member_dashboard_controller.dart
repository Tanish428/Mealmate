import 'package:flutter/material.dart';
import 'dart:convert';
import '../../data/repos/menu_repo.dart';
import '../../data/repos/profile_repo.dart';
import '../../data/repos/broadcast_repo.dart';
import '../../data/repos/attendance_repo.dart';
import '../../data/models/skip_model.dart';

class MemberDashboardController extends ChangeNotifier {
  final MenuRepository _menuRepo;
  final ProfileRepository _profileRepo;
  final BroadcastRepo _broadcastRepo;
  final AttendanceRepo _attendanceRepo;

  String? _memberName;
  String _selectedMeal = 'Lunch';
  bool _isActiveTab = true;
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> _todayMenu = [];
  List<Map<String, dynamic>> _tomorrowMenu = [];
  List<Map<String, dynamic>> _announcements = [];

  List<SkipModel> _allSkips = [];
  double _attendancePercentage = 0.0;
  String? _messId;
  DateTime? _profileCreatedAt;

  MemberDashboardController({
    MenuRepository? menuRepo,
    ProfileRepository? profileRepo,
    BroadcastRepo? broadcastRepo,
    AttendanceRepo? attendanceRepo,
    bool autoLoad = true,
  })  : _menuRepo = menuRepo ?? MenuRepository(),
        _profileRepo = profileRepo ?? ProfileRepository(),
        _broadcastRepo = broadcastRepo ?? BroadcastRepo(),
        _attendanceRepo = attendanceRepo ?? AttendanceRepo() {
    if (autoLoad) {
      loadDashboard();
      loadAttendanceData();
    }
  }

  String? get memberName => _memberName;
  String get selectedMeal => _selectedMeal;
  bool get isActiveTab => _isActiveTab;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get announcements => _announcements;
  double get attendancePercentage => _attendancePercentage;
  
  bool isCutoffPassed(DateTime date, String mealType) {
    final now = DateTime.now();
    final checkDate = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    
    if (checkDate.isBefore(today)) return true;
    if (checkDate.isAfter(today)) return false;
    
    final hour = now.hour;
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return hour >= 7;
      case 'lunch':
        return hour >= 10;
      case 'dinner':
        return hour >= 17;
      default:
        return false;
    }
  }

  bool isMealSkipped(DateTime date, String mealType) {
    final lowerMeal = mealType.toLowerCase();
    return _allSkips.any((skip) => 
      skip.skipDate.year == date.year &&
      skip.skipDate.month == date.month &&
      skip.skipDate.day == date.day &&
      skip.mealType.toLowerCase() == lowerMeal
    );
  }

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      
      final nameFuture = _profileRepo.getUserFullName();
      final todayMenuFuture = _menuRepo.getMenuForDate(now);
      final tomorrowMenuFuture = _menuRepo.getMenuForDate(tomorrow);
      final announcementsFuture = _broadcastRepo.getMessBroadcasts();

      final results = await Future.wait([
        nameFuture,
        todayMenuFuture,
        tomorrowMenuFuture,
        announcementsFuture,
      ]);

      _memberName = results[0] as String?;
      _todayMenu = results[1] as List<Map<String, dynamic>>? ?? [];
      _tomorrowMenu = results[2] as List<Map<String, dynamic>>? ?? [];
      _announcements = results[3] as List<Map<String, dynamic>>? ?? [];
    } catch (e) {
      _errorMessage = 'Failed to load member dashboard: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAttendanceData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (_messId == null || _profileCreatedAt == null) {
        final profile = await _profileRepo.getMemberProfileDetails();
        if (profile == null) throw 'Profile not found';
        
        _messId = profile['mess_id']?.toString();
        final createdAtStr = profile['created_at']?.toString();
        if (_messId == null || createdAtStr == null) throw 'Mess ID or Join Date not found';

        _profileCreatedAt = DateTime.parse(createdAtStr);
      }

      _allSkips = await _attendanceRepo.getMemberSkips();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final totalPossibleMeals = ((now.difference(_profileCreatedAt!).inDays) + 1) * 3;
      final totalPastSkips = _allSkips.where((skip) {
        final skipDay = DateTime(skip.skipDate.year, skip.skipDate.month, skip.skipDate.day);
        if (skipDay.isBefore(today)) return true;
        if (skipDay.isAtSameMomentAs(today)) {
          return isCutoffPassed(today, skip.mealType);
        }
        return false;
      }).length;

      _attendancePercentage = totalPossibleMeals > 0 
          ? ((totalPossibleMeals - totalPastSkips) / totalPossibleMeals) * 100 
          : 0.0;
      
    } catch (e) {
      _errorMessage = 'Failed to load attendance: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleMealSkip(DateTime date, String mealType) async {
    final lowerMeal = mealType.toLowerCase();
    if (isCutoffPassed(date, lowerMeal)) {
      _errorMessage = 'Cutoff passed for $mealType. Cannot change attendance.';
      notifyListeners();
      return;
    }
    if (_messId == null) return;
    
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final shouldSkip = !isMealSkipped(date, lowerMeal);
      await _attendanceRepo.toggleMealSkip(
        messId: _messId!, 
        date: date, 
        mealType: lowerMeal, 
        shouldSkip: shouldSkip
      );
      await loadAttendanceData();
    } catch (e) {
      _errorMessage = 'Failed to toggle $mealType attendance: $e';
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> planMultiDayLeave(DateTimeRange range) async {
    if (_messId == null) return;
    
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _attendanceRepo.addDateRangeSkips(
        messId: _messId!,
        startDate: range.start,
        endDate: range.end,
      );
      await loadAttendanceData();
    } catch (e) {
      _errorMessage = 'Failed to plan leave: $e';
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  List<String> getMenuForMeal(DateTime date, String mealType) {
    final lower = mealType.toLowerCase();
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final menuList = isToday ? _todayMenu : _tomorrowMenu;
    
    final match = menuList.firstWhere(
      (m) => m['meal_type']?.toString().toLowerCase() == lower,
      orElse: () => {},
    );

    if (match.isEmpty || match['items'] == null) {
      return ['Menu to be announced'];
    }

    final rawList = match['items'] as List<dynamic>;
    final List<String> items = [];

    for (final val in rawList) {
      if (val is String) {
        if (val.startsWith('{')) {
          try {
            final decoded = jsonDecode(val);
            if (decoded is Map && decoded['name'] != null) {
              items.add(decoded['name'].toString());
              continue;
            }
          } catch (_) {}
        }
        items.add(val);
      } else if (val is Map && val['name'] != null) {
        items.add(val['name'].toString());
      }
    }

    return items.isNotEmpty ? items : ['Menu to be announced'];
  }
}
