import 'package:flutter/material.dart';
import 'member_home_screen.dart';
import 'attendance_toggle_screen.dart';
import 'profile_screen.dart';

class MenuViewScreen extends StatefulWidget {
  const MenuViewScreen({super.key});

  @override
  State<MenuViewScreen> createState() => _MenuViewScreenState();
}

class _MenuViewScreenState extends State<MenuViewScreen> {
  int _currentIndex = 1;
  String _selectedDate = 'Wed';
  String _selectedFilter = 'All';

  final Color bgColor = const Color(0xFFFAF7F5);
  final Color primaryRed = const Color(0xFFC74330);
  final Color textDark = const Color(0xFF1E1E1E);
  final Color textGray = const Color(0xFF757575);
  final Color green = const Color(0xFF4A9054);
  final Color lightGreen = const Color(0xFFE8F5E9);

  final List<Map<String, String>> _weekDates = [
    {'day': 'Mon', 'date': '14'},
    {'day': 'Tue', 'date': '15'},
    {'day': 'Wed', 'date': '16'},
    {'day': 'Thu', 'date': '17'},
    {'day': 'Fri', 'date': '18'},
    {'day': 'Sat', 'date': '19'},
    {'day': 'Sun', 'date': '20'},
  ];

  final Map<String, Map<String, List<Map<String, dynamic>>>> _weeklyMenu = {
    'Mon': {
      'Breakfast': [
        {'name': 'Aloo Paratha', 'isVeg': true},
        {'name': 'Curd', 'isVeg': true},
        {'name': 'Omelette', 'isVeg': false},
      ],
      'Lunch': [
        {'name': 'Rajma Chawal', 'isVeg': true},
        {'name': 'Fish Fry', 'isVeg': false},
        {'name': 'Roti', 'isVeg': true},
      ],
      'Dinner': [
        {'name': 'Mix Veg', 'isVeg': true},
        {'name': 'Chicken Biryani', 'isVeg': false},
        {'name': 'Roti', 'isVeg': true},
      ],
    },
    'Tue': {
      'Breakfast': [
        {'name': 'Upma', 'isVeg': true},
        {'name': 'Banana', 'isVeg': true},
      ],
      'Lunch': [
        {'name': 'Chole Bhature', 'isVeg': true},
        {'name': 'Egg Curry', 'isVeg': false},
        {'name': 'Rice', 'isVeg': true},
      ],
      'Dinner': [
        {'name': 'Palak Paneer', 'isVeg': true},
        {'name': 'Butter Chicken', 'isVeg': false},
        {'name': 'Naan', 'isVeg': true},
      ],
    },
    'Wed': {
      'Breakfast': [
        {'name': 'Idli Sambar', 'isVeg': true},
        {'name': 'Poha', 'isVeg': true},
        {'name': 'Boiled Egg', 'isVeg': false},
      ],
      'Lunch': [
        {'name': 'Paneer Butter Masala', 'isVeg': true},
        {'name': 'Chicken Curry', 'isVeg': false},
        {'name': 'Dal Tadka', 'isVeg': true},
        {'name': 'Steamed Rice', 'isVeg': true},
        {'name': 'Fresh Chapatis', 'isVeg': true},
      ],
      'Dinner': [
        {'name': 'Aloo Gobi', 'isVeg': true},
        {'name': 'Egg Curry', 'isVeg': false},
        {'name': 'Jeera Rice', 'isVeg': true},
        {'name': 'Roti', 'isVeg': true},
        {'name': 'Gulab Jamun', 'isVeg': true},
      ],
    },
    'Thu': {
      'Breakfast': [
        {'name': 'Masala Dosa', 'isVeg': true},
        {'name': 'Tea/Coffee', 'isVeg': true},
      ],
      'Lunch': [
        {'name': 'Kadhi Pakora', 'isVeg': true},
        {'name': 'Mutton Curry', 'isVeg': false},
        {'name': 'Rice', 'isVeg': true},
      ],
      'Dinner': [
        {'name': 'Bhindi Masala', 'isVeg': true},
        {'name': 'Chicken Tikka', 'isVeg': false},
        {'name': 'Roti', 'isVeg': true},
      ],
    },
    'Fri': {
      'Breakfast': [
        {'name': 'Puri Sabzi', 'isVeg': true},
        {'name': 'Omelette', 'isVeg': false},
      ],
      'Lunch': [
        {'name': 'Dal Makhani', 'isVeg': true},
        {'name': 'Fish Curry', 'isVeg': false},
        {'name': 'Rice', 'isVeg': true},
      ],
      'Dinner': [
        {'name': 'Matar Paneer', 'isVeg': true},
        {'name': 'Egg Bhurji', 'isVeg': false},
        {'name': 'Naan', 'isVeg': true},
      ],
    },
    'Sat': {
      'Breakfast': [
        {'name': 'Poha', 'isVeg': true},
        {'name': 'Jalebi', 'isVeg': true},
      ],
      'Lunch': [
        {'name': 'Veg Biryani', 'isVeg': true},
        {'name': 'Chicken Biryani', 'isVeg': false},
        {'name': 'Raita', 'isVeg': true},
      ],
      'Dinner': [
        {'name': 'Baingan Bharta', 'isVeg': true},
        {'name': 'Roti', 'isVeg': true},
        {'name': 'Ice Cream', 'isVeg': true},
      ],
    },
    'Sun': {
      'Breakfast': [
        {'name': 'Chole Kulche', 'isVeg': true},
        {'name': 'Lassi', 'isVeg': true},
      ],
      'Lunch': [
        {'name': 'Veg Pulao', 'isVeg': true},
        {'name': 'Mutton Rogan Josh', 'isVeg': false},
        {'name': 'Roti', 'isVeg': true},
      ],
      'Dinner': [
        {'name': 'Malai Kofta', 'isVeg': true},
        {'name': 'Chicken Korma', 'isVeg': false},
        {'name': 'Roti', 'isVeg': true},
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    final menu = _weeklyMenu[_selectedDate] ?? _weeklyMenu['Wed']!;

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
              if (menu.containsKey('Breakfast')) ...[
                _buildMealCard(
                  'Breakfast',
                  '7:00 AM – 9:00 AM',
                  Icons.wb_sunny_outlined,
                  Colors.orange,
                  menu['Breakfast']!,
                ),
                const SizedBox(height: 20.0),
              ],
              if (menu.containsKey('Lunch')) ...[
                _buildMealCard(
                  'Lunch',
                  '12:30 PM – 2:30 PM',
                  Icons.restaurant,
                  primaryRed,
                  menu['Lunch']!,
                ),
                const SizedBox(height: 20.0),
              ],
              if (menu.containsKey('Dinner')) ...[
                _buildMealCard(
                  'Dinner',
                  '7:30 PM – 9:30 PM',
                  Icons.nightlight_round,
                  Colors.grey.shade700,
                  menu['Dinner']!,
                ),
                const SizedBox(height: 24.0),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBranding() {
    return Row(
      children: [
        // App Logo Icon
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weekly Menu',
              style: TextStyle(
                color: textDark,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 6.0,
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
                  Text(
                    'Campus Central Mess',
                    style: TextStyle(
                      color: primaryRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: primaryRed),
                ],
              ),
            ),
          ],
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
          final isSelected = _selectedDate == dateObj['day'];
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = dateObj['day']!;
                });
              },
              child: _buildCalendarDay(
                dateObj['day']!,
                dateObj['date']!,
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
                                  _buildMenuItem(item['name'], item['isVeg']),
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

  Widget _buildMenuItem(String name, bool isVeg) {
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
                      pageBuilder: (context, animation1, animation2) =>
                          const MemberHomeScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: _buildNavItem(
                  Icons.home,
                  'Home',
                  _currentIndex == 0 ? primaryRed : textGray,
                  _currentIndex == 0,
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const MenuViewScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: _buildNavItem(
                  Icons.restaurant,
                  'Menu',
                  _currentIndex == 1 ? primaryRed : textGray,
                  _currentIndex == 1,
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const AttendanceToggleScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: _buildNavItem(
                  Icons.calendar_today,
                  'Attendance',
                  _currentIndex == 2 ? primaryRed : textGray,
                  _currentIndex == 2,
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const ProfileScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: _buildNavItem(
                  Icons.person_outline,
                  'Profile',
                  _currentIndex == 3 ? primaryRed : textGray,
                  _currentIndex == 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    Color color,
    bool isSelected,
  ) {
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
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
