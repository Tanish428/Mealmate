import 'package:flutter/material.dart';
import 'role_selection_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderSection(colorScheme, textTheme),
              const SizedBox(height: 32.0),
              _buildFormContainer(colorScheme, textTheme),
              const SizedBox(height: 24.0),
              _buildSocialDivider(colorScheme, textTheme),
              const SizedBox(height: 24.0),
              _buildGoogleButton(colorScheme),
              const SizedBox(height: 32.0),
              _buildFooterSection(colorScheme, textTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withAlpha(38),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.restaurant, // Placeholder for Logo
              size: 40,
              color: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 24.0),
        Text(
          "Create Account",
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8.0),
        Text(
          "Join MealMate to start managing meals",
          style: textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormContainer(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInputLabelRow("Full Name", "Required", textTheme),
          const SizedBox(height: 8.0),
          CustomTextField(
            controller: _nameController,
            prefixIcon: const Icon(Icons.person_outline),
            hintText: "Enter your name",
          ),
          const SizedBox(height: 16.0),
          
          _buildInputLabelRow("Email Address", "Required", textTheme),
          const SizedBox(height: 8.0),
          CustomTextField(
            controller: _emailController,
            prefixIcon: const Icon(Icons.mail_outline),
            hintText: "Enter your email",
          ),
          const SizedBox(height: 16.0),

          _buildInputLabelRow("Password", "Min. 8 chars", textTheme),
          const SizedBox(height: 8.0),
          CustomTextField(
            controller: _passwordController,
            prefixIcon: const Icon(Icons.lock_outline),
            obscureText: !_isPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            hintText: "Create a password",
          ),
          const SizedBox(height: 16.0),

          Text(
            "Confirm Password",
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          CustomTextField(
            controller: _confirmPasswordController,
            prefixIcon: const Icon(Icons.lock_outline),
            obscureText: !_isConfirmPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),
            hintText: "Confirm your password",
          ),
          
          const SizedBox(height: 24.0),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "By creating an account, you agree to our ",
              style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              children: [
                TextSpan(
                  text: "Terms",
                  style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: " and "),
                TextSpan(
                  text: "Privacy Policy",
                  style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24.0),
          CustomButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
              );
            },
            text: "Create Account",
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabelRow(String label, String trailingText, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          trailingText,
          style: textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialDivider(ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              "OR",
              style: textTheme.labelSmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildGoogleButton(ColorScheme colorScheme) {
    return CustomButton(
      onPressed: () {},
      text: "Continue with Google",
      isOutlined: true,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Image.asset(
          'assets/images/Google_logo.png',
          width: 24,
          height: 24,
        ),
      ),
    );
  }

  Widget _buildFooterSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: RichText(
          text: TextSpan(
            text: "Already have an account? ",
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
            children: [
              TextSpan(
                text: "Log In",
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// STUB IMPLEMENTATIONS FOR REQUIRED WIDGETS
// =====================================================================

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final Widget prefixIcon;
  final Widget? suffixIcon;
  final String hintText;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.prefixIcon,
    this.suffixIcon,
    required this.hintText,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
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
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ?prefixIcon,
            Text(text),
          ],
        ),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(text),
    );
  }
}
