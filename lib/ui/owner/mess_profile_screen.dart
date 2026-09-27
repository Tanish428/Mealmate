import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../common/custom_button.dart';
import '../../data/services/supabase_auth_service.dart';
import '../../data/repos/mess_repo.dart';
import '../../data/repos/profile_repo.dart';
import '../../data/models/mess_model.dart';

class MessProfileScreen extends StatefulWidget {
  const MessProfileScreen({super.key});

  @override
  State<MessProfileScreen> createState() => _MessProfileScreenState();
}

class _MessProfileScreenState extends State<MessProfileScreen> {
  late TextEditingController _nameController;
  String _inviteCode = '------';
  bool _isLoading = true;
  File? _avatarFile;
  String? _avatarUrl;
  bool _isUploading = false;
  Map<String, dynamic>? _messData;
  

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: "Loading...");
    _loadMessData();
  }

  Future<void> _loadMessData() async {
    final repo = MessRepository();
    final profileRepo = ProfileRepository();
    
    final results = await Future.wait([
      repo.getOwnerMessDetails(),
      profileRepo.getMemberProfileDetails(),
    ]);
    
    final data = results[0];
    final profileData = results[1];

    if (mounted) {
      setState(() {
        if (data != null) {
          _messData = data;
          _nameController.text = data['mess_name'] ?? 'Your Mess';
          _inviteCode = data['invite_code'] ?? 'N/A';
        } else {
          _nameController.text = 'Your Mess';
          _inviteCode = 'Error';
        }
        if (profileData != null) {
          _avatarUrl = profileData['avatar_url'] as String?;
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

  Future<void> _pickAndUploadAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 70,
    );

    if (image == null) return;

    setState(() {
      _avatarFile = File(image.path);
      _isUploading = true;
    });

    try {
      final repo = ProfileRepository();
      final newUrl = await repo.uploadAvatar(_avatarFile!);
      if (mounted) {
        setState(() {
          _avatarUrl = newUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
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
              _buildSettingsTile(colorScheme, textTheme),
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

  Widget _buildSettingsTile(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        leading: Icon(Icons.access_time_rounded, color: colorScheme.primary, size: 28),
        title: Text(
          'Meal Timings & Cutoffs',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          'Manage serving windows and opt-out cutoffs',
          style: textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          if (_messData != null) {
            final messModel = MessModel.fromMap(_messData!);
            final updatedTimings = await context.push<Map<String, dynamic>>('/owner/meal-timings', extra: messModel);
            if (updatedTimings != null) {
              setState(() {
                _messData!['meal_timings'] = updatedTimings;
              });
            }
          }
        },
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
    ImageProvider? imageProvider;
    if (_avatarFile != null) {
      imageProvider = FileImage(_avatarFile!);
    } else if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_avatarUrl!);
    }

    final displayName = _nameController.text.isNotEmpty && _nameController.text != 'Loading...' && _nameController.text != 'Your Mess'
        ? _nameController.text
        : 'Umiyaji';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Center(
      child: GestureDetector(
        onTap: _pickAndUploadAvatar,
        child: Stack(
          children: [
            Container(
              width: 120.0,
              height: 120.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFECE8),
                image: imageProvider != null
                    ? DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageProvider == null
                  ? Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Color(0xFFBA2D1D),
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
            if (_isUploading)
              Container(
                width: 120.0,
                height: 120.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.restaurant, color: colorScheme.primary, size: 20.0),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    _nameController.text,
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
            "Mess Name cannot be changed here.",
            style: textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500,
            ),
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
