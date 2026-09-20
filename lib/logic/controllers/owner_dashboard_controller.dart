import 'package:flutter/material.dart';
import '../../data/repos/mess_repo.dart';
import '../../data/repos/feedback_repo.dart';
import '../../data/repos/broadcast_repo.dart';
import '../../data/repos/menu_repo.dart';

class OwnerDashboardStats {
  final String messName;
  final int activeMembersCount;
  final double averageRating;
  final int feedbackCount;
  final int broadcastCount;
  final String nextMealTitle;
  final String nextMealTime;
  final List<String> nextMealItems;

  const OwnerDashboardStats({
    required this.messName,
    required this.activeMembersCount,
    required this.averageRating,
    required this.feedbackCount,
    required this.broadcastCount,
    required this.nextMealTitle,
    required this.nextMealTime,
    this.nextMealItems = const [],
  });
}

class OwnerDashboardController extends ChangeNotifier {
  final MessRepository _messRepo;
  final FeedbackRepo _feedbackRepo;
  final BroadcastRepo _broadcastRepo;
  final MenuRepository _menuRepo;

  bool _isLoading = false;
  String? _errorMessage;
  OwnerDashboardStats? _stats;

  OwnerDashboardController({
    MessRepository? messRepo,
    FeedbackRepo? feedbackRepo,
    BroadcastRepo? broadcastRepo,
    MenuRepository? menuRepo,
    bool autoLoad = true,
  })  : _messRepo = messRepo ?? MessRepository(),
        _feedbackRepo = feedbackRepo ?? FeedbackRepo(),
        _broadcastRepo = broadcastRepo ?? BroadcastRepo(),
        _menuRepo = menuRepo ?? MenuRepository() {
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
      // 1. Fetch mess name
      final nameFuture = _messRepo.getOwnerMessName();

      // 2. Fetch members list for accurate count
      final membersFuture = _messRepo.getMessMembers();

      // 3. Fetch feedback
      final feedbackListFuture = _feedbackRepo.getMessFeedback();

      // 4. Fetch broadcasts
      final broadcastsFuture = _broadcastRepo.getMessBroadcasts();

      // 5. Fetch today's menu
      final todayMenuFuture = _menuRepo.getTodayMenu();

      final results = await Future.wait([
        nameFuture,
        membersFuture,
        feedbackListFuture,
        broadcastsFuture,
        todayMenuFuture,
      ]);

      final messName = (results[0] as String?) ?? 'Your Mess';
      final members = results[1] as List<Map<String, dynamic>>? ?? [];
      final feedbacks = results[2] as List<Map<String, dynamic>>? ?? [];
      final broadcasts = results[3] as List<Map<String, dynamic>>? ?? [];
      final todayMenu = results[4] as List<Map<String, dynamic>>? ?? [];

      // Calculate dynamic average rating
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

      // Determine next meal based on current hour
      final nextMealData = _computeNextMeal(todayMenu);

      _stats = OwnerDashboardStats(
        messName: messName,
        activeMembersCount: members.length,
        averageRating: avgRating,
        feedbackCount: feedbacks.length,
        broadcastCount: broadcasts.length,
        nextMealTitle: nextMealData.$1,
        nextMealTime: nextMealData.$2,
        nextMealItems: nextMealData.$3,
      );
    } catch (e) {
      _errorMessage = 'Failed to load dashboard: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  (String, String, List<String>) _computeNextMeal(List<Map<String, dynamic>> todayMenu) {
    final now = DateTime.now();
    final hour = now.hour;

    String mealKey;
    String mealTitle;
    String mealTime;

    if (hour < 10) {
      mealKey = 'breakfast';
      mealTitle = 'Breakfast';
      mealTime = '7:30 AM - 9:30 AM';
    } else if (hour < 15) {
      mealKey = 'lunch';
      mealTitle = 'Lunch';
      mealTime = '12:30 PM - 2:30 PM';
    } else if (hour < 21) {
      mealKey = 'dinner';
      mealTitle = 'Dinner';
      mealTime = '7:30 PM - 9:30 PM';
    } else {
      mealKey = 'breakfast';
      mealTitle = 'Breakfast (Tomorrow)';
      mealTime = '7:30 AM - 9:30 AM';
    }

    List<String> items = [];
    final match = todayMenu.firstWhere(
      (m) => m['meal_type']?.toString().toLowerCase() == mealKey,
      orElse: () => {},
    );

    if (match.isNotEmpty && match['items'] is List) {
      items = (match['items'] as List).map((e) => e.toString()).toList();
    }

    return (mealTitle, mealTime, items);
  }
}
