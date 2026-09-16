import 'package:flutter/material.dart';
import 'member_home_screen.dart';
import 'menu_view_screen.dart';
import 'profile_screen.dart';

class AttendanceToggleScreen extends StatefulWidget {
  const AttendanceToggleScreen({super.key});

  @override
  State<AttendanceToggleScreen> createState() => _AttendanceToggleScreenState();
}

class _AttendanceToggleScreenState extends State<AttendanceToggleScreen> {
  final int _currentIndex = 2;

  final Color bgColor = const Color(0xFFFAF7F5);
  final Color primaryRed = const Color(0xFFC74330);
  final Color textDark = const Color(0xFF1E1E1E);
  final Color textGray = const Color(0xFF757575);
  final Color green = const Color(0xFF4A9054);
  final Color lightGreen = const Color(0xFFF1F8F1);
  final Color lightRed = const Color(0xFFFFF4F2);

  // States for the toggles (simulated backend data)
  bool _dinnerAttending = true;
  bool _breakfastAttending = false;
  bool _lunchAttending = true;

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
              _buildHeader(),
              const SizedBox(height: 16.0),
              _buildGreenBanner(),
              const SizedBox(height: 24.0),
              _buildDateSection('Today', 'Wed, 16 Apr 2025'),
              const SizedBox(height: 16.0),
              _buildMealCard(
                title: 'Dinner',
                time: '7:30 PM – 9:30 PM',
                icon: Icons.nightlight_round,
                iconColor: primaryRed, // Assuming moon color matches the dark/reddish tone
                iconBgColor: lightRed,
                pillText: 'Locks in 2h 15m',
                pillIcon: Icons.schedule,
                pillColor: primaryRed,
                pillBgColor: lightRed,
                menuItems: ['Aloo Gobi', 'Jeera Rice', 'Roti', 'Gulab Jamun'],
                imageAsset: 'assets/images/meal.png',
                isAttending: _dinnerAttending,
                onToggle: (bool attending) {
                  setState(() => _dinnerAttending = attending);
                },
              ),
              const SizedBox(height: 24.0),
              _buildDateSection('Tomorrow', 'Thu, 17 Apr 2025'),
              const SizedBox(height: 16.0),
              _buildMealCard(
                title: 'Breakfast',
                time: '7:30 AM – 9:30 AM',
                icon: Icons.wb_sunny_outlined,
                iconColor: Colors.orange,
                iconBgColor: Colors.orange.withValues(alpha: 0.1),
                pillText: 'Opens Tomorrow',
                pillIcon: Icons.schedule,
                pillColor: textGray,
                pillBgColor: Colors.grey.shade200,
                menuItems: ['Poha', 'Boiled Eggs', 'Fruits', 'Tea / Coffee'],
                imageAsset: 'assets/images/meal.png', // Fallback to meal.png
                isAttending: _breakfastAttending,
                onToggle: (bool attending) {
                  setState(() => _breakfastAttending = attending);
                },
              ),
              const SizedBox(height: 16.0),
              _buildMealCard(
                title: 'Lunch',
                time: '12:30 PM – 2:30 PM',
                icon: Icons.restaurant,
                iconColor: primaryRed,
                iconBgColor: lightRed,
                pillText: null, // No pill
                pillIcon: null,
                pillColor: Colors.transparent,
                pillBgColor: Colors.transparent,
                menuItems: ['Paneer Butter Masala', 'Dal Tadka', 'Steamed Rice', 'Fresh Chapatis', 'Mixed Salad'],
                imageAsset: 'assets/images/meal.png',
                isAttending: _lunchAttending,
                onToggle: (bool attending) {
                  setState(() => _lunchAttending = attending);
                },
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          padding: const EdgeInsets.all(10.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.calendar_month_outlined, color: primaryRed, size: 24),
        ),
      ],
    );
  }

  Widget _buildGreenBanner() {
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
          // Decorative leaf placeholder (can use icon for now)
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.eco, color: green.withValues(alpha: 0.5), size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(String day, String date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          day,
          style: TextStyle(
            color: textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          date,
          style: TextStyle(
            color: textGray,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard({
    required String title,
    required String time,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String? pillText,
    required IconData? pillIcon,
    required Color pillColor,
    required Color pillBgColor,
    required List<String> menuItems,
    required String imageAsset,
    required bool isAttending,
    required Function(bool) onToggle,
  }) {
    // If skipping, we apply a grayscale filter and lower opacity to the content
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
          // Content wrapped in ColorFiltered if skipping
          ColorFiltered(
            colorFilter: isAttending
                ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                : const ColorFilter.matrix(<double>[
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0,      0,      0,      0.6, 0, // 0.6 opacity
                  ]),
            child: Column(
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: iconBgColor,
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
                            title,
                            style: TextStyle(
                              color: textDark,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            time,
                            style: TextStyle(
                              color: textGray,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (pillText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: pillBgColor,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Row(
                          children: [
                            Icon(pillIcon, size: 12, color: pillColor),
                            const SizedBox(width: 4.0),
                            Text(
                              pillText,
                              style: TextStyle(
                                color: pillColor,
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
                // Content Row
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
                      child: Image.asset(
                        imageAsset,
                        height: 110,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          // Toggle Row (Segmented Control)
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
                    onTap: () => onToggle(true),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isAttending ? primaryRed : Colors.transparent,
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAttending ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: isAttending ? Colors.white : textGray,
                              size: 18,
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              'Attending',
                              style: TextStyle(
                                color: isAttending ? Colors.white : textDark,
                                fontSize: 14,
                                fontWeight: isAttending ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onToggle(false),
                    child: Container(
                      decoration: BoxDecoration(
                        color: !isAttending ? textGray : Colors.transparent,
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              !isAttending ? Icons.cancel : Icons.cancel_outlined,
                              color: !isAttending ? Colors.white : textDark,
                              size: 18,
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              isAttending ? 'Opt Out' : 'Skipping',
                              style: TextStyle(
                                color: !isAttending ? Colors.white : textDark,
                                fontSize: 14,
                                fontWeight: !isAttending ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildVegItem(String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
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
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => const MemberHomeScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: _buildNavItem(Icons.home, 'Home', _currentIndex == 0 ? primaryRed : textGray, _currentIndex == 0),
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => const MenuViewScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: _buildNavItem(Icons.restaurant, 'Menu', _currentIndex == 1 ? primaryRed : textGray, _currentIndex == 1),
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: _buildNavItem(Icons.calendar_today, 'Attendance', _currentIndex == 2 ? primaryRed : textGray, _currentIndex == 2),
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => const ProfileScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: _buildNavItem(Icons.person_outline, 'Profile', _currentIndex == 3 ? primaryRed : textGray, _currentIndex == 3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, Color color, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          if (isSelected) const SizedBox(height: 4.0),
          if (isSelected)
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (!isSelected) const SizedBox(height: 4.0),
          if (!isSelected)
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (isSelected) const SizedBox(height: 4.0),
          if (isSelected)
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

