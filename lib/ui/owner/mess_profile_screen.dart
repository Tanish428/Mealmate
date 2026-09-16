import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../common/custom_textfield.dart';
import '../common/custom_button.dart';

class MessProfileScreen extends StatefulWidget {
  const MessProfileScreen({super.key});

  @override
  State<MessProfileScreen> createState() => _MessProfileScreenState();
}

class _MessProfileScreenState extends State<MessProfileScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: "DDU Campus Mess");
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
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colorScheme.primary.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.primary),
            onPressed: () { if (Navigator.of(context).canPop()) { Navigator.pop(context); } else { context.go('/owner/dashboard'); } },
          ),
        ),
        const SizedBox(width: 16.0),
        Text(
          "Mess Profile",
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
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
          // QR Code Placeholder
          Container(
            width: 150.0,
            height: 150.0,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300, width: 2.0),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(
              Icons.qr_code_2,
              size: 100.0,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 24.0),
          // Invite Code Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Text(
              "84X29P",
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                letterSpacing: 2.0,
              ),
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
      onPressed: () { if (Navigator.of(context).canPop()) { Navigator.pop(context); } else { context.go('/owner/dashboard'); } },
    );
  }
}




