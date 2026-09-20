import 'package:flutter/material.dart';
import 'dart:convert';
import '../../data/repos/menu_repo.dart';
import '../../data/repos/profile_repo.dart';
import '../../data/repos/broadcast_repo.dart';

class MemberMealInfo {
  final String title;
  final String timeRange;
  final List<String> items;
  final String statusText;
  final Color statusColor;
  final IconData statusIcon;

  const MemberMealInfo({
    required this.title,
    required this.timeRange,
    required this.items,
    required this.statusText,
    required this.statusColor,
    required this.statusIcon,
  });
}

class MemberDashboardController extends ChangeNotifier {
  final MenuRepository _menuRepo;
  final ProfileRepository _profileRepo;
  final BroadcastRepo _broadcastRepo;

  String? _memberName;
  String _selectedMeal = 'Lunch';
  bool _isActiveTab = true;
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> _todayMenu = [];
  List<Map<String, dynamic>> _announcements = [];

  MemberDashboardController({
    MenuRepository? menuRepo,
    ProfileRepository? profileRepo,
    BroadcastRepo? broadcastRepo,
    bool autoLoad = true,
  })  : _menuRepo = menuRepo ?? MenuRepository(),
        _profileRepo = profileRepo ?? ProfileRepository(),
        _broadcastRepo = broadcastRepo ?? BroadcastRepo() {
    if (autoLoad) {
      loadDashboard();
    }
  }

  String? get memberName => _memberName;
  String get selectedMeal => _selectedMeal;
  bool get isActiveTab => _isActiveTab;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get todayMenu => _todayMenu;
  List<Map<String, dynamic>> get announcements => _announcements;

  void setTab(bool isActive) {
    if (_isActiveTab != isActive) {
      _isActiveTab = isActive;
      notifyListeners();
    }
  }

  void setSelectedMeal(String meal) {
    if (_selectedMeal != meal) {
      _selectedMeal = meal;
      notifyListeners();
    }
  }

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final nameFuture = _profileRepo.getUserFullName();
      final menuFuture = _menuRepo.getTodayMenu();
      final announcementsFuture = _broadcastRepo.getMessBroadcasts();

      final results = await Future.wait([
        nameFuture,
        menuFuture,
        announcementsFuture,
      ]);

      _memberName = results[0] as String?;
      _todayMenu = results[1] as List<Map<String, dynamic>>? ?? [];
      _announcements = results[2] as List<Map<String, dynamic>>? ?? [];
    } catch (e) {
      _errorMessage = 'Failed to load member dashboard: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Extracts dynamic menu dish items for a meal type (breakfast, lunch, dinner).
  List<String> getItemsForMeal(String mealType) {
    final lower = mealType.toLowerCase();
    final match = _todayMenu.firstWhere(
      (m) => m['meal_type']?.toString().toLowerCase() == lower,
      orElse: () => {},
    );

    if (match.isEmpty || match['items'] == null) {
      return _defaultItemsForMeal(mealType);
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

    return items.isNotEmpty ? items : _defaultItemsForMeal(mealType);
  }

  MemberMealInfo getMealInfo(String mealType) {
    final items = getItemsForMeal(mealType);
    final now = DateTime.now();
    final hour = now.hour;

    switch (mealType.toLowerCase()) {
      case 'breakfast':
        final isPast = hour >= 10;
        final isNow = hour >= 7 && hour < 10;
        return MemberMealInfo(
          title: 'Breakfast',
          timeRange: '7:00 AM – 9:30 AM',
          items: items,
          statusText: isPast ? 'Attended' : (isNow ? 'Serving Now' : 'Upcoming'),
          statusColor: isPast
              ? const Color(0xFF4A9054)
              : (isNow ? const Color(0xFFC74330) : Colors.grey),
          statusIcon: isPast
              ? Icons.check_circle
              : (isNow ? Icons.circle : Icons.schedule),
        );
      case 'dinner':
        final isPast = hour >= 22;
        final isNow = hour >= 19 && hour < 22;
        return MemberMealInfo(
          title: 'Dinner',
          timeRange: '7:00 PM – 9:30 PM',
          items: items,
          statusText: isPast ? 'Attended' : (isNow ? 'Serving Now' : 'Upcoming'),
          statusColor: isPast
              ? const Color(0xFF4A9054)
              : (isNow ? const Color(0xFFC74330) : Colors.grey),
          statusIcon: isPast
              ? Icons.check_circle
              : (isNow ? Icons.circle : Icons.schedule),
        );
      case 'lunch':
      default:
        final isPast = hour >= 15;
        final isNow = hour >= 12 && hour < 15;
        return MemberMealInfo(
          title: 'Lunch',
          timeRange: '12:30 PM – 2:30 PM',
          items: items,
          statusText: isPast ? 'Attended' : (isNow ? 'Serving Now' : 'Upcoming'),
          statusColor: isPast
              ? const Color(0xFF4A9054)
              : (isNow ? const Color(0xFFC74330) : Colors.grey),
          statusIcon: isPast
              ? Icons.check_circle
              : (isNow ? Icons.circle : Icons.schedule),
        );
    }
  }

  List<String> _defaultItemsForMeal(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return ['Idli Sambar', 'Poha', 'Tea/Coffee', 'Bread Jam', 'Banana'];
      case 'dinner':
        return ['Aloo Gobi', 'Dal Makhani', 'Jeera Rice', 'Roti', 'Gulab Jamun'];
      case 'lunch':
      default:
        return [
          'Paneer Butter Masala',
          'Dal Tadka',
          'Steamed Rice',
          'Fresh Chapatis',
          'Mixed Salad',
        ];
    }
  }
}
