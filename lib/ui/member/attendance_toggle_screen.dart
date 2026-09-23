import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../logic/controllers/member_dashboard_controller.dart';

class AttendanceToggleScreen extends StatefulWidget {
  const AttendanceToggleScreen({super.key});

  @override
  State<AttendanceToggleScreen> createState() => _AttendanceToggleScreenState();
}

class _AttendanceToggleScreenState extends State<AttendanceToggleScreen> {
  late final MemberDashboardController _controller;

  final Color bgColor = const Color(0xFFFAF7F5);
  final Color primaryRed = const Color(0xFFC84B31);
  final Color textDark = const Color(0xFF1E1E1E);
  final Color textGray = const Color(0xFF757575);
  final Color green = const Color(0xFF4A9054);
  final Color lightGreen = const Color(0xFFF1F8F1);
  final Color lightRed = const Color(0xFFFFF4F2);

  @override
  void initState() {
    super.initState();
    _controller = MemberDashboardController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _planLeave() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final result = await showDateRangePicker(
      context: context,
      firstDate: tomorrow,
      lastDate: tomorrow.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryRed,
              onPrimary: Colors.white,
              onSurface: textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      await _controller.planMultiDayLeave(result);
      if (_controller.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_controller.errorMessage!)),
        );
      }
    }
  }

  bool _isMealPeriodEnded(String mealType) {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final time = hour + minute / 60.0;
    
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return time >= 9.5; // 9:30 AM
      case 'lunch':
        return time >= 14.5; // 2:30 PM
      case 'dinner':
        return time >= 21.5; // 9:30 PM
      default:
        return true;
    }
  }

  String _getCutoffBadgeText(DateTime date, String mealType, bool isCutoffPassed) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate.isAfter(today)) {
      return 'Opens Tomorrow';
    }

    if (isCutoffPassed) {
      return 'Cutoff Passed';
    }

    double cutoffHour;
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        cutoffHour = 7.0;
        break;
      case 'lunch':
        cutoffHour = 10.0;
        break;
      case 'dinner':
        cutoffHour = 17.0;
        break;
      default:
        cutoffHour = 0.0;
    }

    final cutoffTime = DateTime(now.year, now.month, now.day, cutoffHour.toInt(), 0);
    final diff = cutoffTime.difference(now);
    
    if (diff.isNegative) return 'Cutoff Passed';

    final h = diff.inHours;
    final m = diff.inMinutes.remainder(60);
    return 'Locks in ${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            if (_controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final tomorrow = today.add(const Duration(days: 1));
            
            final servedMeals = _controller.servedMeals.map((e) => e.toLowerCase()).toList();
            if (servedMeals.isEmpty) {
              return const Center(child: Text("No meals configured"));
            }

            final showTodayBreakfast = servedMeals.contains('breakfast') && !_controller.isCutoffPassed(today, 'breakfast');
            final showTodayLunch = servedMeals.contains('lunch') && !_controller.isCutoffPassed(today, 'lunch');
            final showTodayDinner = servedMeals.contains('dinner') && !_controller.isCutoffPassed(today, 'dinner');
            final showTodaySection = showTodayBreakfast || showTodayLunch || showTodayDinner;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16.0),
                  _buildEcoBanner(),
                  const SizedBox(height: 24.0),
                  
                  if (showTodaySection) ...[
                    _buildSectionHeader('Today', DateFormat('EEE, d MMM yyyy').format(today)),
                    const SizedBox(height: 16.0),
                    if (showTodayBreakfast) ...[
                      _buildMealCard(today, 'Breakfast', '7:30 AM - 9:30 AM', Icons.wb_sunny_outlined, Colors.orange),
                      const SizedBox(height: 16.0),
                    ],
                    if (showTodayLunch) ...[
                      _buildMealCard(today, 'Lunch', '12:30 PM - 2:30 PM', Icons.restaurant, primaryRed),
                      const SizedBox(height: 16.0),
                    ],
                    if (showTodayDinner) ...[
                      _buildMealCard(today, 'Dinner', '7:30 PM - 9:30 PM', Icons.nightlight_round, Colors.indigo),
                      const SizedBox(height: 16.0),
                    ],
                    const SizedBox(height: 8.0),
                  ],

                  _buildSectionHeader('Tomorrow', DateFormat('EEE, d MMM yyyy').format(tomorrow)),
                  const SizedBox(height: 16.0),
                  if (servedMeals.contains('breakfast')) ...[
                    _buildMealCard(tomorrow, 'Breakfast', '7:30 AM - 9:30 AM', Icons.wb_sunny_outlined, Colors.orange),
                    const SizedBox(height: 16.0),
                  ],
                  if (servedMeals.contains('lunch')) ...[
                    _buildMealCard(tomorrow, 'Lunch', '12:30 PM - 2:30 PM', Icons.restaurant, primaryRed),
                    const SizedBox(height: 16.0),
                  ],
                  if (servedMeals.contains('dinner')) ...[
                    _buildMealCard(tomorrow, 'Dinner', '7:30 PM - 9:30 PM', Icons.nightlight_round, Colors.indigo),
                    const SizedBox(height: 24.0),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Manage ',
                    style: TextStyle(
                      color: textDark,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(
                    text: 'Attendance',
                    style: TextStyle(
                      color: primaryRed,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Plan your meals, avoid food waste.',
              style: TextStyle(
                color: textGray,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.date_range, color: primaryRed),
            onPressed: _planLeave,
            tooltip: 'Plan Multi-day Leave',
          ),
        ),
      ],
    );
  }

  Widget _buildEcoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        children: [
          Icon(Icons.energy_savings_leaf, color: green, size: 20),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              'Your updates help reduce food waste. Thank you!',
              style: TextStyle(
                color: green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.eco, color: green.withOpacity(0.5), size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String dateText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: TextStyle(
            color: textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          dateText,
          style: TextStyle(
            color: textGray,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(DateTime date, String mealType, String timeRange, IconData icon, Color iconColor) {
    final lowerMeal = mealType.toLowerCase();
    final bool isSkipped = _controller.isMealSkipped(date, lowerMeal);
    final bool isAttending = !isSkipped;
    final bool isCutoffPassed = _controller.isCutoffPassed(date, lowerMeal);
    final List<String> menuItems = _controller.getMenuForMeal(date, lowerMeal);
    
    final badgeText = _getCutoffBadgeText(date, lowerMeal, isCutoffPassed);
    final isTomorrow = badgeText == 'Opens Tomorrow';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: ColorFiltered(
        colorFilter: isAttending
            ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
            : const ColorFilter.matrix(<double>[
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0,      0,      0,      0.6, 0,
              ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mealType,
                        style: TextStyle(
                          color: textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeRange,
                        style: TextStyle(
                          color: textGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: isTomorrow ? Colors.grey.shade200 : (isCutoffPassed ? Colors.grey.shade200 : lightRed),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, size: 12, color: isTomorrow || isCutoffPassed ? textGray : primaryRed),
                      const SizedBox(width: 4.0),
                      Text(
                        badgeText,
                        style: TextStyle(
                          color: isTomorrow || isCutoffPassed ? textGray : primaryRed,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: menuItems.map((item) => _buildVegItem(item)).toList(),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade100,
                    ),
                    child: Center(
                      child: Icon(Icons.fastfood_outlined, color: Colors.grey.shade400, size: 40),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        if (!isCutoffPassed && !_controller.isActionLoading && !isAttending) {
                          await _controller.toggleMealSkip(date, lowerMeal);
                          if (_controller.errorMessage != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(_controller.errorMessage!)),
                            );
                          }
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isAttending ? primaryRed : Colors.transparent,
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        child: Center(
                          child: Text(
                            'Attending',
                            style: TextStyle(
                              color: isAttending ? Colors.white : textDark,
                              fontSize: 14,
                              fontWeight: isAttending ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        if (!isCutoffPassed && !_controller.isActionLoading && isAttending) {
                          await _controller.toggleMealSkip(date, lowerMeal);
                          if (_controller.errorMessage != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(_controller.errorMessage!)),
                            );
                          }
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: !isAttending ? textDark : Colors.transparent,
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        child: Center(
                          child: Text(
                            'Opt Out',
                            style: TextStyle(
                              color: !isAttending ? Colors.white : textDark,
                              fontSize: 14,
                              fontWeight: !isAttending ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVegItem(String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              border: Border.all(color: green),
              borderRadius: BorderRadius.circular(2.0),
            ),
            child: Center(
              child: Icon(Icons.circle, size: 6, color: green),
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              name,
              style: TextStyle(color: textDark, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
