import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'feedback_screen.dart';
import 'notice_board_screen.dart';
import '../../data/repos/menu_repo.dart';
import '../../logic/controllers/member_dashboard_controller.dart';

class MemberHomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToMenu;
  final VoidCallback? onNavigateToAttendance;
  final VoidCallback? onNavigateToProfile;

  const MemberHomeScreen({
    super.key,
    this.onNavigateToMenu,
    this.onNavigateToAttendance,
    this.onNavigateToProfile,
  });

  @override
  State<MemberHomeScreen> createState() => _MemberHomeScreenState();
}

class _MemberHomeScreenState extends State<MemberHomeScreen> {
  String _selectedMeal = 'Lunch';
  late final MemberDashboardController _dashboardController;
  Future<List<Map<String, dynamic>>>? _todayMenuFuture;

  @override
  void initState() {
    super.initState();
    _dashboardController = MemberDashboardController();
    _dashboardController.addListener(_onStateChange);
    _todayMenuFuture = MenuRepository().getTodayMenu();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _dashboardController.removeListener(_onStateChange);
    _dashboardController.dispose();
    super.dispose();
  }

  final Map<String, dynamic> _mealData = {
    'Breakfast': {
      'time': '7:00 AM – 9:00 AM',
      'items': ['Idli Sambar', 'Poha', 'Tea/Coffee', 'Bread Jam', 'Banana'],
      'statusText': 'Attended',
      'statusColor': const Color(0xFF4A9054),
      'statusIcon': Icons.check_circle,
    },
    'Lunch': {
      'time': '12:30 PM – 2:30 PM',
      'items': [
        'Paneer Butter Masala',
        'Dal Tadka',
        'Steamed Rice',
        'Fresh Chapatis',
        'Mixed Salad',
      ],
      'statusText': 'Serving Now',
      'statusColor': const Color(0xFFC74330),
      'statusIcon': Icons.circle,
    },
    'Dinner': {
      'time': '7:00 PM – 9:00 PM',
      'items': [
        'Aloo Gobi',
        'Dal Makhani',
        'Jeera Rice',
        'Roti',
        'Gulab Jamun',
      ],
      'statusText': 'Upcoming',
      'statusColor': Colors.grey,
      'statusIcon': Icons.schedule,
    },
  };

  @override
  Widget build(BuildContext context) {
    // Custom colors from the mockup
    final Color bgColor = const Color(0xFFFAF7F5);
    final Color primaryRed = const Color(0xFFC74330);
    final Color textDark = const Color(0xFF1E1E1E);
    final Color textGray = const Color(0xFF757575);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(primaryRed, textDark, textGray),
              const SizedBox(height: 24.0),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _todayMenuFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading menu'));
                  }
                  return _buildHeroCard(primaryRed, textDark, textGray, snapshot.data ?? []);
                },
              ),
              const SizedBox(height: 24.0),
              _buildTodayMealsSection(primaryRed, textDark, textGray),
              const SizedBox(height: 24.0),
              _buildQuickAccessSection(primaryRed, textDark),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToMenu() {
    if (widget.onNavigateToMenu != null) {
      widget.onNavigateToMenu!();
    } else {
      context.go('/member/menu');
    }
  }

  void _navigateToAttendance() {
    if (widget.onNavigateToAttendance != null) {
      widget.onNavigateToAttendance!();
    } else {
      context.go('/member/attendance');
    }
  }

  void _navigateToProfile() {
    if (widget.onNavigateToProfile != null) {
      widget.onNavigateToProfile!();
    } else {
      context.go('/member/profile');
    }
  }

  Widget _buildHeader(Color primaryRed, Color textDark, Color textGray) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _navigateToProfile,
          child: const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey,
            backgroundImage: AssetImage('assets/images/person.png'),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good afternoon,',
                style: TextStyle(
                  color: textGray,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  if (_dashboardController.isLoading && _dashboardController.memberName == null)
                    const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Text(
                      _dashboardController.memberName ?? 'User',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (!(_dashboardController.isLoading && _dashboardController.memberName == null))
                    const SizedBox(width: 4.0),
                  if (!(_dashboardController.isLoading && _dashboardController.memberName == null))
                    const Text('👋', style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 4.0),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NoticeBoardScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: primaryRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.storefront, size: 14, color: primaryRed),
                      const SizedBox(width: 4.0),
                      Flexible(
                        child: Text(
                          'Campus Central Mess',
                          style: TextStyle(
                            color: primaryRed,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      Icon(Icons.chevron_right, size: 14, color: primaryRed),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NoticeBoardScreen()),
            );
          },
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none,
                  color: Colors.black87,
                ),
              ),
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: primaryRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(Color primaryRed, Color textDark, Color textGray, List<Map<String, dynamic>> menuDataList) {
    final Color green = const Color(0xFF4A9054);
    final data = _mealData[_selectedMeal]!;
    final bool isServing = data['statusText'] == 'Serving Now';
    final Color statusColor = isServing ? green : data['statusColor'];

    final selectedMenu = menuDataList.where((m) => m['meal_type'] == _selectedMeal.toLowerCase()).toList();
    List<Map<String, dynamic>> items = [];
    if (selectedMenu.isNotEmpty) {
      final rawItems = selectedMenu.first['items'] as List<dynamic>? ?? [];
      for (var val in rawItems) {
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
        items.add({'name': name, 'isVeg': isVeg, 'hasDessert': hasDessert});
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      _selectedMeal,
                      style: TextStyle(
                        color: textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Icon(Icons.circle, size: 4, color: Colors.grey.shade400),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        data['time'],
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
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 6.0,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Row(
                  children: [
                    Icon(data['statusIcon'], size: 8, color: statusColor),
                    const SizedBox(width: 6.0),
                    Text(
                      data['statusText'],
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Text(
            'Today\'s Menu',
            style: TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12.0),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                "No menu published for today yet.",
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: textGray,
                ),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: items
                        .map<Widget>((item) => _buildMenuItem(item['name'], item['isVeg'], item['hasDessert'], textDark))
                        .toList(),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Image.asset(
                    'assets/images/meal.png',
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16.0),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _navigateToAttendance,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      color: green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 12.0),
                  Text(
                    'You are marked as ',
                    style: TextStyle(
                      color: textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Attending',
                    style: TextStyle(
                      color: green,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, size: 18, color: green),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String name, bool isVeg, bool hasDessert, Color textDark) {
    Color typeColor = isVeg ? Colors.green : const Color(0xFFC74330);
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
            child: Center(
              child: Icon(Icons.circle, size: 6, color: typeColor),
            ),
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

  Widget _buildTodayMealsSection(
    Color primaryRed,
    Color textDark,
    Color textGray,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Meals',
              style: TextStyle(
                color: textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: _navigateToMenu,
              child: Row(
                children: [
                  Text(
                    'View Menu',
                    style: TextStyle(
                      color: primaryRed,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2.0),
                  Icon(Icons.chevron_right, size: 16, color: primaryRed),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            _buildTimelineCard(
              title: 'Breakfast',
              time: '7:00 AM – 9:00 AM',
              icon: Icons.wb_sunny_outlined,
              iconColor: Colors.orange,
              statusText: 'Attended',
              statusColor: const Color(0xFF4A9054),
              bgColor: _selectedMeal == 'Breakfast'
                  ? const Color(0xFFF1F8F1)
                  : Colors.white,
              borderColor: _selectedMeal == 'Breakfast'
                  ? const Color(0xFFD4E7D5)
                  : Colors.grey.shade300,
              statusIcon: Icons.check_circle,
              onTap: () => setState(() => _selectedMeal = 'Breakfast'),
            ),
            const SizedBox(width: 12.0),
            _buildTimelineCard(
              title: 'Lunch',
              time: '12:30 PM – 2:30 PM',
              icon: Icons.restaurant,
              iconColor: primaryRed,
              statusText: 'Serving Now',
              statusColor: primaryRed,
              bgColor: _selectedMeal == 'Lunch'
                  ? const Color(0xFFFFF4F2)
                  : Colors.white,
              borderColor: _selectedMeal == 'Lunch'
                  ? primaryRed
                  : Colors.grey.shade300,
              statusIcon: Icons.circle,
              statusIconSize: 8,
              onTap: () => setState(() => _selectedMeal = 'Lunch'),
            ),
            const SizedBox(width: 12.0),
            _buildTimelineCard(
              title: 'Dinner',
              time: '7:00 PM – 9:00 PM',
              icon: Icons.nightlight_round,
              iconColor: Colors.grey.shade500,
              statusText: 'Upcoming',
              statusColor: Colors.grey.shade600,
              bgColor: _selectedMeal == 'Dinner'
                  ? const Color(0xFFF5F5F5)
                  : Colors.white,
              borderColor: _selectedMeal == 'Dinner'
                  ? Colors.grey.shade400
                  : Colors.grey.shade300,
              statusIcon: Icons.schedule,
              onTap: () => setState(() => _selectedMeal = 'Dinner'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineCard({
    required String title,
    required String time,
    required IconData icon,
    required Color iconColor,
    required String statusText,
    required Color statusColor,
    required Color bgColor,
    required Color borderColor,
    required IconData statusIcon,
    double statusIconSize = 14,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(height: 8.0),
              Text(
                title,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                time,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12.0),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: statusIconSize),
                    const SizedBox(width: 4.0),
                    Flexible(
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection(Color primaryRed, Color textDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: TextStyle(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildQuickAccessIcon(
                Icons.menu_book_outlined,
                'View Menu',
                primaryRed,
                onTap: _navigateToMenu,
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: _buildQuickAccessIcon(
                Icons.event_available_outlined,
                'My Attendance',
                primaryRed,
                onTap: _navigateToAttendance,
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: _buildQuickAccessIcon(
                Icons.bar_chart_outlined,
                'Mess Updates',
                primaryRed,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NoticeBoardScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: _buildQuickAccessIcon(
                Icons.chat_bubble_outline,
                'Give Feedback',
                primaryRed,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FeedbackScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessIcon(
    IconData icon,
    String label,
    Color primaryRed, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryRed, size: 28),
            const SizedBox(height: 8.0),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
