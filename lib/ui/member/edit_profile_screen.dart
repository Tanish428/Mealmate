import 'package:flutter/material.dart';
import 'member_home_screen.dart';
import 'menu_view_screen.dart';
import 'attendance_toggle_screen.dart';
import 'profile_screen.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  // Theme Colors — matching all screens
  static const Color _bgColor = Color(0xFFFAF7F5);
  static const Color _primaryRed = Color(0xFFC74330);
  static const Color _textDark = Color(0xFF1E1E1E);
  static const Color _textGray = Color(0xFF757575);
  static const Color _lightRed = Color(0xFFFCEAE8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderWidget(onBack: () => Navigator.pop(context)),
              const SizedBox(height: 24.0),
              const _AvatarSectionWidget(),
              const SizedBox(height: 24.0),
              const _FormContainerWidget(),
              const SizedBox(height: 24.0),
              _ActionsWidget(
                onSave: () => Navigator.pop(context),
                onCancel: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
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
                child: _buildNavItem(Icons.home, 'Home', _textGray, false),
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
                child:
                    _buildNavItem(Icons.restaurant, 'Menu', _textGray, false),
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
                    Icons.calendar_today, 'Attendance', _textGray, false),
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
                    Icons.person_outline, 'Profile', _primaryRed, true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildNavItem(
      IconData icon, String label, Color color, bool isSelected) {
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

// =====================================================================
// Header — back arrow + "Edit Profile" title
// =====================================================================

class _HeaderWidget extends StatelessWidget {
  final VoidCallback onBack;

  const _HeaderWidget({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: EditProfileScreen._lightRed,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: EditProfileScreen._primaryRed),
            onPressed: onBack,
          ),
        ),
        const SizedBox(width: 16.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: EditProfileScreen._textDark,
                ),
                children: [
                  TextSpan(text: 'Edit '),
                  TextSpan(
                    text: 'Profile',
                    style: TextStyle(color: EditProfileScreen._primaryRed),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4.0),
            const Text(
              'Keep your information up to date',
              style: TextStyle(
                color: EditProfileScreen._textGray,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =====================================================================
// Avatar — profile image with camera badge
// =====================================================================

class _AvatarSectionWidget extends StatelessWidget {
  const _AvatarSectionWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/person.png',
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: EditProfileScreen._lightRed,
                        child: const Icon(Icons.person,
                            size: 48,
                            color: EditProfileScreen._primaryRed),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: EditProfileScreen._primaryRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt,
                      size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          const Text(
            'Change Photo',
            style: TextStyle(
              color: EditProfileScreen._primaryRed,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4.0),
          const Text(
            'JPG, PNG (Max 5 MB)',
            style: TextStyle(
              color: EditProfileScreen._textGray,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// Form card — white card with input fields
// =====================================================================

class _FormContainerWidget extends StatelessWidget {
  const _FormContainerWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
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
      child: Column(
        children: [
          _buildInputField(
            icon: Icons.person_outline,
            label: 'Full Name',
            hintText: 'Enter your full name',
          ),
          const Divider(height: 32),
          _buildInputField(
            icon: Icons.email_outlined,
            label: 'Email Address',
            hintText: 'Enter your email',
          ),
          const Divider(height: 32),
          _buildInputField(
            icon: Icons.restaurant,
            label: 'Assigned Mess',
            hintText: 'Campus Central Mess',
            readOnly: true,
            helperText: 'Mess cannot be changed.',
          ),
          const Divider(height: 32),
          _buildInputField(
            icon: Icons.badge_outlined,
            label: 'Role',
            hintText: 'Student',
            readOnly: true,
            helperText: 'Role cannot be changed.',
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String label,
    required String hintText,
    bool readOnly = false,
    String? helperText,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4.0),
          padding: const EdgeInsets.all(10.0),
          decoration: const BoxDecoration(
            color: EditProfileScreen._lightRed,
            shape: BoxShape.circle,
          ),
          child:
              Icon(icon, color: EditProfileScreen._primaryRed, size: 20),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: EditProfileScreen._textGray,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8.0),
              TextField(
                readOnly: readOnly,
                style: const TextStyle(
                  color: EditProfileScreen._textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: EditProfileScreen._textGray.withValues(alpha: 0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: readOnly,
                  fillColor: readOnly ? const Color(0xFFF5F5F5) : null,
                  suffixIcon: readOnly
                      ? const Icon(Icons.lock_outline,
                          size: 18, color: EditProfileScreen._textGray)
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 14.0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                        color: EditProfileScreen._primaryRed, width: 1.5),
                  ),
                ),
              ),
              if (helperText != null) ...[
                const SizedBox(height: 4.0),
                Text(
                  helperText,
                  style: const TextStyle(
                    color: EditProfileScreen._textGray,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// Actions — Save / Cancel buttons (matching profile_screen style)
// =====================================================================

class _ActionsWidget extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _ActionsWidget({required this.onSave, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Save Changes — filled red button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: EditProfileScreen._primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 18),
                SizedBox(width: 8.0),
                Text(
                  'Save Changes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12.0),
        // Cancel — outlined red button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: EditProfileScreen._primaryRed,
              side: const BorderSide(color: EditProfileScreen._primaryRed),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.close, size: 18),
                SizedBox(width: 8.0),
                Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

