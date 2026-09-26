import 'package:flutter/material.dart';
import '../../data/repos/mess_repo.dart';
import '../../data/repos/feedback_repo.dart';
import '../../data/repos/broadcast_repo.dart';
import '../../data/repos/menu_repo.dart';
import '../../data/repos/profile_repo.dart';
import '../../data/repos/attendance_repo.dart';
import 'dart:math' as math;

class OwnerDashboardStats {
  final String messName;
  final String? avatarUrl;
  final int activeMembersCount;
  final double averageRating;
  final int feedbackCount;
  final int broadcastCount;
  final String nextMealTitle;
  final String nextMealTime;
  final List<String> nextMealItems;
  final int attendingCount;
  final int optedOutCount;
  final double attendanceRate;
  final String nextMealKey;

  const OwnerDashboardStats({
    required this.messName,
    this.avatarUrl,
    required this.activeMembersCount,
    required this.averageRating,
    required this.feedbackCount,
    required this.broadcastCount,
    required this.nextMealTitle,
    required this.nextMealTime,
    this.nextMealItems = const [],
    this.attendingCount = 0,
    this.optedOutCount = 0,
    this.attendanceRate = 0.0,
    this.nextMealKey = '',
  });
}

class OwnerDashboardController extends ChangeNotifier {
  final MessRepository _messRepo;
  final FeedbackRepo _feedbackRepo;
  final BroadcastRepo _broadcastRepo;
  final MenuRepository _menuRepo;
  final AttendanceRepo _attendanceRepo;

  bool _isLoading = false;
  String? _errorMessage;
  OwnerDashboardStats? _stats;

  OwnerDashboardController({
    MessRepository? messRepo,
    FeedbackRepo? feedbackRepo,
    BroadcastRepo? broadcastRepo,
    MenuRepository? menuRepo,
    AttendanceRepo? attendanceRepo,
    bool autoLoad = true,
  })  : _messRepo = messRepo ?? MessRepository(),
        _feedbackRepo = feedbackRepo ?? FeedbackRepo(),
        _broadcastRepo = broadcastRepo ?? BroadcastRepo(),
        _menuRepo = menuRepo ?? MenuRepository(),
        _attendanceRepo = attendanceRepo ?? AttendanceRepo() {
    if (autoLoad) {
      loadDashboard();
    }
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  OwnerDashboardStats? get stats => _stats;
  String get messName => _stats?.messName ?? 'Your Mess';

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final messDetailsFuture = _messRepo.getOwnerMessDetails();
      final membersFuture = _messRepo.getMessMembers();
      final feedbackListFuture = _feedbackRepo.getMessFeedback();
      final broadcastsFuture = _broadcastRepo.getMessBroadcasts();
      final todayMenuFuture = _menuRepo.getTodayMenu();
      final profileFuture = ProfileRepository().getMemberProfileDetails();

      final results = await Future.wait([
        messDetailsFuture,
        membersFuture,
        feedbackListFuture,
        broadcastsFuture,
        todayMenuFuture,
        profileFuture,
      ]);

      final messDetails = results[0] as Map<String, dynamic>?;
      final messName = messDetails?['mess_name'] as String? ?? 'Your Mess';
      final messId = messDetails?['id']?.toString() ?? '';
      
      final rawServedMeals = messDetails?['served_meals'];
      List<String> servedMeals = [];
      if (rawServedMeals is List) {
        servedMeals = rawServedMeals.map((e) => e.toString().toLowerCase()).toList();
      }

      final mealTimings = messDetails?['meal_timings'] as Map<String, dynamic>? ?? {};
      
      final members = results[1] as List<Map<String, dynamic>>? ?? [];
      final feedbacks = results[2] as List<Map<String, dynamic>>? ?? [];
      final broadcasts = results[3] as List<Map<String, dynamic>>? ?? [];
      final todayMenu = results[4] as List<Map<String, dynamic>>? ?? [];
      final profileData = results[5] as Map<String, dynamic>?;
      final avatarUrl = profileData?['avatar_url'] as String?;

      double totalRating = 0.0;
      int ratedCount = 0;
      for (final entry in feedbacks) {
        final rawRating = entry['rating'];
        final num? r = rawRating is num
            ? rawRating
            : (rawRating != null ? num.tryParse(rawRating.toString()) : null);
        if (r != null && r > 0) {
          totalRating += r.toDouble();
          ratedCount++;
        }
      }
      final double avgRating = ratedCount > 0 ? (totalRating / ratedCount) : 0.0;

      final nextMealData = _computeNextMeal(todayMenu, servedMeals, mealTimings);
      
      int optedOutCount = 0;
      if (messId.isNotEmpty && nextMealData.$1.isNotEmpty) {
        // If meal is tomorrow, we use tomorrow's date? No, logic says skip_date == today for now, but wait, if it's tomorrow, skip_date might be tomorrow.
        // Actually, user spec: count of skips where skip_date == today. But let's use the actual meal date.
        DateTime mealDate = DateTime.now();
        if (nextMealData.$5) {
          mealDate = mealDate.add(const Duration(days: 1));
        }
        optedOutCount = await _attendanceRepo.getOptedOutCount(
          messId: messId, 
          date: mealDate, 
          mealType: nextMealData.$1
        );
      }
      
      final totalJoinedMembers = members.length;
      final attendingCount = math.max(0, totalJoinedMembers - optedOutCount);
      final attendanceRate = totalJoinedMembers > 0 ? (attendingCount / totalJoinedMembers) * 100 : 0.0;

      _stats = OwnerDashboardStats(
        messName: messName,
        avatarUrl: avatarUrl,
        activeMembersCount: totalJoinedMembers,
        averageRating: avgRating,
        feedbackCount: feedbacks.length,
        broadcastCount: broadcasts.length,
        nextMealKey: nextMealData.$1,
        nextMealTitle: nextMealData.$2,
        nextMealTime: nextMealData.$3,
        nextMealItems: nextMealData.$4,
        attendingCount: attendingCount,
        optedOutCount: optedOutCount,
        attendanceRate: attendanceRate,
      );
    } catch (e) {
      _errorMessage = 'Failed to load dashboard: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  (String, String, String, List<String>, bool) _computeNextMeal(
      List<Map<String, dynamic>> todayMenu, List<String> servedMeals, Map<String, dynamic> mealTimings) {
    if (servedMeals.isEmpty) {
      return ('', 'No Meals configured', '', [], false);
    }

    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final time = hour + minute / 60.0;

    String mealKey = '';
    String mealTitle = '';
    String mealTime = '';
    bool isTomorrow = false;

    // Helper to get end time from timings or use default
    double getEndTime(String m) {
      final data = mealTimings[m];
      if (data != null && data['end'] != null) {
        final parts = data['end'].split(':');
        return int.parse(parts[0]) + int.parse(parts[1]) / 60.0;
      }
      if (m == 'breakfast') return 10.0;
      if (m == 'lunch') return 15.0;
      if (m == 'dinner') return 22.0;
      return 24.0;
    }

    String getFormattedTime(String m) {
      final data = mealTimings[m];
      if (data != null && data['start'] != null && data['end'] != null) {
        return '${_formatTime12Hour(data['start'])} - ${_formatTime12Hour(data['end'])}';
      }
      if (m == 'breakfast') return '7:30 AM - 9:30 AM';
      if (m == 'lunch') return '12:30 PM - 2:30 PM';
      if (m == 'dinner') return '7:30 PM - 9:30 PM';
      return '';
    }

    if (servedMeals.contains('breakfast') && time < getEndTime('breakfast')) {
      mealKey = 'breakfast';
      mealTitle = 'Breakfast';
      mealTime = getFormattedTime('breakfast');
    } else if (servedMeals.contains('lunch') && time < getEndTime('lunch')) {
      mealKey = 'lunch';
      mealTitle = 'Lunch';
      mealTime = getFormattedTime('lunch');
    } else if (servedMeals.contains('dinner') && time < getEndTime('dinner')) {
      mealKey = 'dinner';
      mealTitle = 'Dinner';
      mealTime = getFormattedTime('dinner');
    } else {
      isTomorrow = true;
      mealKey = servedMeals.first;
      mealTitle = '${mealKey[0].toUpperCase()}${mealKey.substring(1)} (Tomorrow)';
      mealTime = getFormattedTime(mealKey);
    }

    List<String> items = [];
    final match = todayMenu.firstWhere(
      (m) => m['meal_type']?.toString().toLowerCase() == mealKey,
      orElse: () => {},
    );

    if (match.isNotEmpty && match['items'] is List) {
      items = (match['items'] as List).map((e) => e.toString()).toList();
    }

    return (mealKey, mealTitle, mealTime, items, isTomorrow);
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
}
