import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/supabase_auth_service.dart';
import 'edit_profile_screen.dart';

import '../../data/repos/profile_repo.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  bool _isLoading = true;
  String _fullName = 'Loading...';
  String _email = 'Loading...';
  String _role = 'Loading...';
  String _messName = 'Loading...';
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final repo = ProfileRepository();
    final data = await repo.getMemberProfileDetails();
    if (mounted) {
      setState(() {
        if (data != null) {
          _fullName = (data['full_name']?.toString().trim().isNotEmpty == true) 
              ? data['full_name'] : 'User';
          _email = data['email'] ?? 'No Email';
          _role = data['role'] == 'owner' ? 'Mess Owner' : 'Mess Member';
          _messName = data['mess_name'] ?? 'Not Assigned';
          _avatarUrl = data['avatar_url'];
        } else {
          _fullName = 'User';
          _email = 'Unknown';
          _role = 'Unknown';
          _messName = 'Unknown';
          _avatarUrl = null;
        }
        _isLoading = false;
      });
    }
  }

  // Theme Colors based on previous screens
  final Color bgColor = const Color(0xFFFAF7F5);
  final Color primaryRed = const Color(0xFFC74330);
  final Color textDark = const Color(0xFF1E1E1E);
  final Color textGray = const Color(0xFF757575);
  final Color green = const Color(0xFF4A9054);
  final Color lightGreen = const Color(0xFFE8F5E9);
  final Color orange = const Color(0xFFF57C00);
  final Color lightOrange = const Color(0xFFFFF3E0);
  final Color lightRed = const Color(0xFFFCEAE8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC74330))) 
          : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Row
              _buildHeader(),
              const SizedBox(height: 24.0),

              // 2. Profile Hero Card
              _buildProfileHeroCard(),
              const SizedBox(height: 24.0),

              // 3. Account Information Card
              _buildAccountInfoCard(),
              const SizedBox(height: 24.0),

              // 4. MealMate Summary Section
              _buildSummarySection(),
              const SizedBox(height: 24.0),

              // 5. Eco Banner
              _buildEcoBanner(),
              const SizedBox(height: 24.0),

              // 6. Actions (Buttons)
              _buildActions(),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
            children: [
              const TextSpan(text: 'Pro'),
              TextSpan(
                text: 'file',
                style: TextStyle(color: primaryRed),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          'Your MealMate account',
          style: TextStyle(
            color: textGray,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeroCard() {
    return Container(
      decoration: BoxDecoration(
        color: lightRed,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Stack(
        children: [
          // Decorative leaf/graphics placeholder (if asset is missing, it's just a stack layer)
          Positioned(
            right: -20,
            top: -20,
            child: Icon(Icons.eco, size: 100, color: primaryRed.withValues(alpha: 0.1)),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
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
                      child: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                          ? Image.network(
                              _avatarUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: primaryRed.withValues(alpha: 0.2),
                                  child: Icon(Icons.person, size: 40, color: primaryRed),
                                );
                              },
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              color: primaryRed.withValues(alpha: 0.2),
                              child: Center(
                                child: Text(
                                  _fullName.isNotEmpty ? _fullName[0].toUpperCase() : 'U',
                                  style: TextStyle(
                                    color: primaryRed,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  _isLoading ? 'Loading...' : _fullName,
                  style: TextStyle(
                    color: textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: lightGreen,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        _role,
                        style: TextStyle(
                          color: green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: primaryRed.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _messName,
                        style: TextStyle(
                          color: primaryRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard() {
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
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildInfoRow(Icons.person_outline, 'Full Name', _fullName),
          const Divider(height: 24),
          _buildInfoRow(Icons.email_outlined, 'Email Address', _email),
          const Divider(height: 24),
          _buildInfoRow(Icons.badge_outlined, 'Role', _role),
          const Divider(height: 24),
          _buildInfoRow(Icons.restaurant, 'Assigned Mess', _messName),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: lightRed,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: primaryRed, size: 20),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: textGray,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                value,
                style: TextStyle(
                  color: textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  

  Widget _buildSummarySection() {
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MealMate Summary',
              style: TextStyle(
                color: textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Icon(Icons.eco, color: green, size: 16),
                const SizedBox(width: 4.0),
                Text(
                  'Eco-Warrior',
                  style: TextStyle(
                    color: green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(child: _buildStatCard('Meals Attended', '42', Icons.restaurant_menu, primaryRed, lightRed)),
            const SizedBox(width: 12.0),
            Expanded(child: _buildStatCard('Day Streak', '14', Icons.local_fire_department, orange, lightOrange)),
            const SizedBox(width: 12.0),
            Expanded(child: _buildStatCard('Food Saved', '2.5kg', Icons.eco, green, lightGreen)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12.0),
          Text(
            value,
            style: TextStyle(
              color: textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: TextStyle(
              color: textGray,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.eco, color: green, size: 16),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              'Your food choices saved 2.5kg of food this month! Keep it up!',
              style: TextStyle(
                color: green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        CustomButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfileScreen(
                  currentName: _fullName,
                  currentEmail: _email,
                  assignedMess: _messName,
                  currentRole: _role,
                  avatarUrl: _avatarUrl,
                ),
              ),
            ).then((_) => _loadProfileData());
          },
          text: 'Edit Profile',
          prefixIcon: const Icon(Icons.edit, size: 18, color: Colors.white),
        ),
        const SizedBox(height: 12.0),
        CustomButton(
          onPressed: () async {
            await SupabaseAuthService().signOut();
            if (context.mounted) {
              context.go('/login');
            }
          },
          text: 'Log Out',
          isOutlined: true,
          prefixIcon: Icon(Icons.logout, size: 18, color: primaryRed),
        ),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isOutlined;
  final Widget? prefixIcon;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isOutlined = false,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFC74330);

    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (prefixIcon != null) ...[
              prefixIcon!,
              const SizedBox(width: 8.0),
            ],
            Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
    
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (prefixIcon != null) ...[
            prefixIcon!,
            const SizedBox(width: 8.0),
          ],
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

