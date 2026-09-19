import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../common/custom_textfield.dart';
import '../common/custom_button.dart';
import '../../data/services/supabase_auth_service.dart';
import '../../data/repos/mess_repo.dart';

class MessProfileScreen extends StatefulWidget {
  const MessProfileScreen({super.key});

  @override
  State<MessProfileScreen> createState() => _MessProfileScreenState();
}

class _MessProfileScreenState extends State<MessProfileScreen> {
  late TextEditingController _nameController;
  String _inviteCode = '------';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: "Loading...");
    _loadMessData();
  }

  Future<void> _loadMessData() async {
    final repo = MessRepository();
    final data = await repo.getOwnerMessDetails();
    if (mounted) {
      setState(() {
        if (data != null) {
          _nameController.text = data['mess_name'] ?? 'Your Mess';
          _inviteCode = data['invite_code'] ?? 'N/A';
        } else {
          _nameController.text = 'Your Mess';
          _inviteCode = 'Error';
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // Warm cream background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(colorScheme, textTheme),
              const SizedBox(height: 32.0),
              _buildProfileImage(colorScheme),
              const SizedBox(height: 32.0),
              _buildMessDetailsCard(colorScheme, textTheme),
              const SizedBox(height: 24.0),
              _buildInviteSection(colorScheme, textTheme),
              const SizedBox(height: 32.0),
              _buildLogOutButton(colorScheme),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Text(
      "Mess Profile",
      style: textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildProfileImage(ColorScheme colorScheme) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120.0,
            height: 120.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade300,
              image: const DecorationImage(
                image: AssetImage('assets/images/meal.png'), // Placeholder for dining hall
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt,
                color: colorScheme.primary,
                size: 20.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessDetailsCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Mess Details",
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24.0),
          
          // Mess Name
          Text(
            "Mess Name",
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8.0),
          CustomTextField(
            controller: _nameController,
            maxLength: 50,
            hintText: "Enter mess name",
          ),
          const SizedBox(height: 20.0),
          
          // Location
          Text(
            "Location",
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: colorScheme.primary, size: 20.0),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    "DDU Campus, Nadiad, Gujarat",
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            "Location cannot be changed here.",
            style: textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 32.0),
          
          // Save Button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: "Save",
              onPressed: () { if (Navigator.of(context).canPop()) { Navigator.pop(context); } else { context.go('/owner/dashboard'); } },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Invite Members",
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24.0),
          // QR Code
          if (_isLoading)
            const SizedBox(
              height: 200.0,
              child: Center(child: CircularProgressIndicator()),
            )
          else
            QrImageView(
              data: _inviteCode,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
            ),
          const SizedBox(height: 24.0),
          // Invite Code Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _inviteCode,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: const Icon(Icons.copy),
                  color: colorScheme.primary,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _inviteCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invite code copied!')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            "Scan QR or use the 6-digit code to join.",
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLogOutButton(ColorScheme colorScheme) {
    return CustomButton(
      text: "Log Out",
      isPrimary: false,
      icon: Icons.logout,
      onPressed: () async { 
        await SupabaseAuthService().signOut();
        if (context.mounted) {
          context.go('/login'); 
        }
      },
    );
  }
}
