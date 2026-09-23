import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/repos/profile_repo.dart';

class EditProfileScreen extends StatefulWidget {
  final String? currentName;
  final String? currentEmail;
  final String? assignedMess;
  final String? currentRole;
  final String? avatarUrl;

  const EditProfileScreen({
    super.key, 
    this.currentName,
    this.currentEmail,
    this.assignedMess,
    this.currentRole,
    this.avatarUrl,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Theme Colors — matching all screens
  static const Color _bgColor = Color(0xFFFAF7F5);
  static const Color _primaryRed = Color(0xFFC74330);
  static const Color _textDark = Color(0xFF1E1E1E);
  static const Color _textGray = Color(0xFF757575);
  static const Color _lightRed = Color(0xFFFCEAE8);

  bool _isLoading = false;
  bool _isAvatarUploading = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _messController;
  late TextEditingController _roleController;
  String? _currentAvatarUrl;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName ?? '');
    _emailController = TextEditingController(text: widget.currentEmail ?? '');
    _messController = TextEditingController(text: widget.assignedMess ?? 'Not Assigned');
    _roleController = TextEditingController(text: widget.currentRole ?? 'Unknown');
    _currentAvatarUrl = widget.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source, imageQuality: 70, maxWidth: 800);
    if (image == null) return;
    
    setState(() {
      _isAvatarUploading = true;
    });
    
    try {
      final File file = File(image.path);
      final newUrl = await ProfileRepository().uploadAvatar(file);
      if (mounted) {
        setState(() {
          _currentAvatarUrl = newUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avatar updated successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading avatar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAvatarUploading = false;
        });
      }
    }
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ProfileRepository().updateFullName(newName: _nameController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
              _AvatarSectionWidget(
                avatarUrl: _currentAvatarUrl,
                isUploading: _isAvatarUploading,
                onTap: _showAvatarPicker,
              ),
              const SizedBox(height: 24.0),
              _FormContainerWidget(
                nameController: _nameController,
                emailController: _emailController,
                messController: _messController,
                roleController: _roleController,
              ),
              const SizedBox(height: 24.0),
              _ActionsWidget(
                isLoading: _isLoading,
                onSave: _saveProfile,
                onCancel: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
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
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(30.0),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18, color: _EditProfileScreenState._textDark),
          ),
        ),
        const SizedBox(width: 16.0),
        const Text(
          'Edit Profile',
          style: TextStyle(
            color: _EditProfileScreenState._textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// Avatar Section — photo + change button
// =====================================================================

class _AvatarSectionWidget extends StatelessWidget {
  final String? avatarUrl;
  final bool isUploading;
  final VoidCallback onTap;

  const _AvatarSectionWidget({
    this.avatarUrl,
    required this.isUploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: isUploading ? null : onTap,
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: isUploading
                        ? const Center(child: CircularProgressIndicator())
                        : (avatarUrl != null && avatarUrl!.isNotEmpty)
                            ? Image.network(
                                avatarUrl!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 50, color: Colors.grey),
                              )
                            : const Icon(Icons.person, size: 50, color: Colors.grey),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: const BoxDecoration(
                      color: _EditProfileScreenState._primaryRed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          GestureDetector(
            onTap: isUploading ? null : onTap,
            child: const Text(
              'Change Photo',
              style: TextStyle(
                color: _EditProfileScreenState._primaryRed,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 4.0),
          const Text(
            'JPG, PNG (Max 5 MB)',
            style: TextStyle(
              color: _EditProfileScreenState._textGray,
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
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController messController;
  final TextEditingController roleController;

  const _FormContainerWidget({
    required this.nameController,
    required this.emailController,
    required this.messController,
    required this.roleController,
  });

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
            controller: nameController,
          ),
          const Divider(height: 32),
          _buildInputField(
            icon: Icons.email_outlined,
            label: 'Email Address',
            hintText: 'Enter your email',
            controller: emailController,
            readOnly: true,
            helperText: 'Email cannot be changed.',
          ),
          const Divider(height: 32),
          _buildInputField(
            icon: Icons.restaurant,
            label: 'Assigned Mess',
            hintText: 'Campus Central Mess',
            controller: messController,
            readOnly: true,
            helperText: 'Mess cannot be changed.',
          ),
          const Divider(height: 32),
          _buildInputField(
            icon: Icons.badge_outlined,
            label: 'Role',
            hintText: 'Student',
            controller: roleController,
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
    TextEditingController? controller,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4.0),
          padding: const EdgeInsets.all(10.0),
          decoration: const BoxDecoration(
            color: _EditProfileScreenState._lightRed,
            shape: BoxShape.circle,
          ),
          child:
              Icon(icon, color: _EditProfileScreenState._primaryRed, size: 20),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _EditProfileScreenState._textGray,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: controller,
                readOnly: readOnly,
                style: const TextStyle(
                  color: _EditProfileScreenState._textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: _EditProfileScreenState._textGray.withValues(alpha: 0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: readOnly,
                  fillColor: readOnly ? const Color(0xFFF5F5F5) : null,
                  suffixIcon: readOnly
                      ? const Icon(Icons.lock_outline,
                          size: 18, color: _EditProfileScreenState._textGray)
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
                        color: _EditProfileScreenState._primaryRed, width: 1.5),
                  ),
                ),
              ),
              if (helperText != null) ...[
                const SizedBox(height: 4.0),
                Text(
                  helperText,
                  style: const TextStyle(
                    color: _EditProfileScreenState._textGray,
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
  final bool isLoading;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _ActionsWidget({required this.onSave, required this.onCancel, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: _EditProfileScreenState._primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Row(
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
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: isLoading ? null : onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: _EditProfileScreenState._primaryRed,
              side: const BorderSide(color: _EditProfileScreenState._primaryRed),
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
