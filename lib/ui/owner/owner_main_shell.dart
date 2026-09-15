import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OwnerMainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const OwnerMainShell({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: "Dashboard",
                  index: 0,
                  currentIndex: navigationShell.currentIndex,
                  primaryColor: primaryColor,
                ),
                _buildNavItem(
                  icon: Icons.restaurant_menu_outlined,
                  activeIcon: Icons.restaurant_menu,
                  label: "Menu",
                  index: 1,
                  currentIndex: navigationShell.currentIndex,
                  primaryColor: primaryColor,
                ),
                _buildNavItem(
                  icon: Icons.group_outlined,
                  activeIcon: Icons.group,
                  label: "Members",
                  index: 2,
                  currentIndex: navigationShell.currentIndex,
                  primaryColor: primaryColor,
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: "Profile",
                  index: 3,
                  currentIndex: navigationShell.currentIndex,
                  primaryColor: primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required int currentIndex,
    required Color primaryColor,
  }) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isActive ? primaryColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? primaryColor : Colors.grey.shade500,
              size: 24.0,
            ),
            if (isActive) ...[
              const SizedBox(width: 6.0),
              Text(
                label,
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
