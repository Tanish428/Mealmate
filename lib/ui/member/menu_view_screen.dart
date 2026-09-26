import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/repos/menu_repo.dart';
import '../../data/repos/profile_repo.dart';

class MenuViewScreen extends StatefulWidget {
  const MenuViewScreen({super.key});

  @override
  State<MenuViewScreen> createState() => _MenuViewScreenState();
}

class _MenuViewScreenState extends State<MenuViewScreen> {
  late DateTime _selectedDate;
  String _selectedFilter = 'All';
  String? _messName;
  bool _isLoading = false;
  List<Map<String, dynamic>> _currentMenuData = [];
  final List<DateTime> _weekDates = [];
  List<String> _servedMeals = [];

  final Color bgColor = const Color(0xFFFAF7F5);
  final Color primaryRed = const Color(0xFFC74330);
  final Color textDark = const Color(0xFF1E1E1E);
  final Color textGray = const Color(0xFF757575);
  final Color green = const Color(0xFF4A9054);
  final Color lightGreen = const Color(0xFFE8F5E9);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      _weekDates.add(now.add(Duration(days: i)));
    }
    _selectedDate = _weekDates.first;
    _fetchMenuForDate(_selectedDate);
    _fetchServedMeals();
  }

  Map<String, dynamic> _mealTimings = {};

  Future<void> _fetchServedMeals() async {
    try {
      final profile = await ProfileRepository().getMemberProfileDetails();
      if (profile != null) {
        if (mounted) {
          setState(() {
            if (profile['served_meals'] != null) {
              _servedMeals = List<String>.from(profile['served_meals']);
            }
            _messName = profile['mess_name'] as String?;
            _mealTimings = profile['meal_timings'] as Map<String, dynamic>? ?? {};
          });
        }
      }
    } catch (_) {}
  }

  String _getFormattedMealTime(String mealType) {
    final lowerMeal = mealType.toLowerCase();
    final data = _mealTimings[lowerMeal];
    if (data != null && data['start'] != null && data['end'] != null) {
      return '${_formatTime12Hour(data['start'])} - ${_formatTime12Hour(data['end'])}';
    }
    return 'Not Configured';
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

  Future<void> _fetchMenuForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await MenuRepository().getMenuForDate(date);
      if (mounted) {
        setState(() {
          _currentMenuData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading menu: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getMealItems(String mealType) {
    final meal = _currentMenuData.firstWhere(
      (m) => m['meal_type'].toString().toLowerCase() == mealType.toLowerCase(),
      orElse: () => {'items': []},
    );
    final rawItems = meal['items'] as List<dynamic>? ?? [];
    return rawItems.map((val) {
      String name = val.toString();
      bool isVeg = true;
      bool hasDessert = false;
      if (val is String && val.startsWith('{')) {
        try {
          final map = jsonDecode(val);
          name = map['name'] ?? name;
          isVeg = map['isVegetarian'] ?? true;
          hasDessert = map['hasDessert'] ?? false;
        } catch (_) {}
      } else if (val is Map) {
        name = val['name']?.toString() ?? name;
        isVeg = val['isVegetarian'] ?? true;
        hasDessert = val['hasDessert'] ?? false;
      }
      return {'name': name, 'isVeg': isVeg, 'hasDessert': hasDessert};
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBranding(),
              const SizedBox(height: 24.0),
              _buildHeader(),
              const SizedBox(height: 24.0),
              _buildCalendarStrip(),
              const SizedBox(height: 20.0),
              _buildFiltersRow(),
              const SizedBox(height: 24.0),
              if (_isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ))
              else ...[
                if (_servedMeals.map((e) => e.toLowerCase()).contains('breakfast')) ...[
                  _buildMealCard(
                    'Breakfast',
                    _getFormattedMealTime('breakfast'),
                    Icons.wb_sunny_outlined,
                    Colors.orange,
                    _getMealItems('breakfast'),
                  ),
                  const SizedBox(height: 20.0),
                ],
                if (_servedMeals.map((e) => e.toLowerCase()).contains('lunch')) ...[
                  _buildMealCard(
                    'Lunch',
                    _getFormattedMealTime('lunch'),
                    Icons.restaurant,
                    primaryRed,
                    _getMealItems('lunch'),
                  ),
                  const SizedBox(height: 20.0),
                ],
                if (_servedMeals.map((e) => e.toLowerCase()).contains('dinner')) ...[
                  _buildMealCard(
                    'Dinner',
                    _getFormattedMealTime('dinner'),
                    Icons.nightlight_round,
                    Colors.grey.shade700,
                    _getMealItems('dinner'),
                  ),
                  const SizedBox(height: 24.0),
                ],
                if (_servedMeals.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'No meals currently configured.',
                        style: TextStyle(color: textGray, fontSize: 16),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBranding() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: primaryRed,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: const Icon(Icons.restaurant, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MealMate',
              style: TextStyle(
                color: textDark,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Good Food, Better Days',
              style: TextStyle(
                color: textGray,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Menu',
          style: TextStyle(
            color: textDark,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          'Check what\'s cooking at your mess',
          style: TextStyle(
            color: textGray,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarStrip() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: _weekDates.map((dateObj) {
          final isSelected = _selectedDate.year == dateObj.year &&
              _selectedDate.month == dateObj.month &&
              _selectedDate.day == dateObj.day;
          
          final dayStr = DateFormat('E').format(dateObj); // Mon, Tue
          final dateStr = DateFormat('d').format(dateObj); // 14, 15

          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = dateObj;
                });
                _fetchMenuForDate(dateObj);
              },
              child: _buildCalendarDay(
                dayStr,
                dateStr,
                isSelected,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarDay(String day, String date, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isSelected ? primaryRed : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: isSelected
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.8)
                  : textGray,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            date,
            style: TextStyle(
              color: isSelected ? Colors.white : textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _selectedFilter = 'All'),
            child: _buildFilterChip(
              'All',
              Icons.grid_view,
              _selectedFilter == 'All',
            ),
          ),
          const SizedBox(width: 12.0),
          GestureDetector(
            onTap: () => setState(() => _selectedFilter = 'Pure Veg'),
            child: _buildFilterChip(
              'Pure Veg',
              Icons.eco,
              _selectedFilter == 'Pure Veg',
            ),
          ),
          const SizedBox(width: 12.0),
          GestureDetector(
            onTap: () => setState(() => _selectedFilter = 'Non-Veg'),
            child: _buildFilterChip(
              'Non-Veg',
              Icons.kebab_dining,
              _selectedFilter == 'Non-Veg',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: isSelected ? primaryRed : Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: isSelected ? null : Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : textDark),
          const SizedBox(width: 8.0),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : textDark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(
    String title,
    String time,
    IconData icon,
    Color iconColor,
    List<Map<String, dynamic>> items,
  ) {
    List<Map<String, dynamic>> filteredItems = items.where((item) {
      if (_selectedFilter == 'Pure Veg') return item['isVeg'] == true;
      if (_selectedFilter == 'Non-Veg') return item['isVeg'] == false;
      return true;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12.0),
              Text(
                title,
                style: TextStyle(
                  color: textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  time,
                  style: TextStyle(
                    color: textGray,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: filteredItems.isEmpty
                    ? Text(
                        'No items for this filter',
                        style: TextStyle(color: textGray, fontSize: 13),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: filteredItems
                            .map(
                              (item) =>
                                  _buildMenuItem(item['name'], item['isVeg'], item['hasDessert']),
                            )
                            .toList(),
                      ),
              ),
              Expanded(
                flex: 2,
                child: Image.asset(
                  'assets/images/meal.png',
                  height: 110,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String name, bool isVeg, bool hasDessert) {
    Color typeColor = isVeg ? green : primaryRed;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              border: Border.all(color: typeColor),
              borderRadius: BorderRadius.circular(2.0),
            ),
            child: Center(child: Icon(Icons.circle, size: 6, color: typeColor)),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: textDark,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasDessert) ...[
            const SizedBox(width: 4.0),
            Icon(Icons.icecream, size: 14, color: Colors.pink.shade300),
          ],
        ],
      ),
    );
  }
}
