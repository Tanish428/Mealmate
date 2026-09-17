import 'package:flutter/material.dart';
import '../common/custom_textfield.dart';
import '../common/custom_button.dart';
import 'package:go_router/go_router.dart';

// Local constants for spacing as per the design constraints
class AppSpacing {
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
}

class CreateMessScreen extends StatefulWidget {
  const CreateMessScreen({super.key});

  @override
  State<CreateMessScreen> createState() => _CreateMessScreenState();
}

class _CreateMessScreenState extends State<CreateMessScreen> {
  bool _acceptDigitalPayments = true;
  bool _providesBreakfast = false;
  bool _providesLunch = true;
  bool _providesDinner = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Use primary color mapped from the theme
    final primaryColor = colorScheme.primary;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Background Decorations
          const Positioned(
            top: 0,
            right: 0,
            child: SizedBox.shrink(),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            child: SizedBox.shrink(),
          ),
          Positioned(
            bottom: AppSpacing.l,
            right: AppSpacing.l,
            child: Text(
              "Good Food Stronger Communities",
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildHeader(primaryColor, textTheme),
                  const SizedBox(height: AppSpacing.xl),

                  // Image Upload Container
                  _buildImageUpload(primaryColor, textTheme),
                  const SizedBox(height: AppSpacing.xl),

                  // Mess Details Card
                  _buildMessDetailsCard(textTheme),
                  const SizedBox(height: AppSpacing.xl),

                  // Payment Preferences Card
                  _buildPaymentCard(primaryColor, textTheme),
                  const SizedBox(height: AppSpacing.xl),

                  // Meals Provided Section
                  _buildMealsProvided(primaryColor, textTheme),
                  const SizedBox(height: AppSpacing.xl),

                  // Action Area
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Create Mess',
                      // trailingIcon logic isn't natively in CustomButton, but we can just use text
                      onPressed: () {
                        context.go('/owner/dashboard');
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color primaryColor, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () { if (Navigator.of(context).canPop()) Navigator.pop(context); },
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, color: primaryColor),
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        RichText(
          text: TextSpan(
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: textTheme.bodyLarge?.color ?? Colors.black87, 
            ),
            children: [
              const TextSpan(text: 'Set Up Your\n'),
              TextSpan(
                text: 'Mess',
                style: TextStyle(color: primaryColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          'Add your details to start welcoming members.',
          style: textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildImageUpload(Color primaryColor, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.3), // Simulated dashed border 
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.camera_alt, color: primaryColor, size: 28),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            'Upload Mess Photo',
            style: textTheme.titleMedium?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'PNG, JPG up to 5MB',
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessDetailsCard(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mess Details',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          
          Text(
            'Mess Name',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            controller: _nameController,
            hintText: 'e.g., Campus Central Mess',
            prefixIcon: Icons.storefront,
          ),
          const SizedBox(height: AppSpacing.m),

          Text(
            'Address',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            controller: _addressController,
            hintText: 'e.g., Near University Campus',
            prefixIcon: Icons.location_on,
          ),
          const SizedBox(height: AppSpacing.m),

          Text(
            'Maximum Capacity',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            controller: _capacityController,
            hintText: 'e.g., 50',
            prefixIcon: Icons.group,
          ),
          const SizedBox(height: AppSpacing.s),
          
          Text(
            'Maximum number of members your mess can accommodate.',
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Color primaryColor, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.credit_card, color: primaryColor, size: 28),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accept Digital Payments',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Allow members to pay their monthly fees via the app.',
                  style: textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Switch(
            value: _acceptDigitalPayments,
            activeThumbColor: primaryColor,
            activeTrackColor: primaryColor.withValues(alpha: 0.5),
            onChanged: (val) {
              setState(() {
                _acceptDigitalPayments = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMealsProvided(Color primaryColor, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meals Provided',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select the meals offered at your mess.',
          style: textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: [
            _MealChip(
              label: 'Breakfast',
              icon: Icons.wb_sunny_outlined,
              isSelected: _providesBreakfast,
              activeColor: primaryColor,
              onTap: () => setState(() => _providesBreakfast = !_providesBreakfast),
            ),
            _MealChip(
              label: 'Lunch',
              icon: Icons.restaurant,
              isSelected: _providesLunch,
              activeColor: primaryColor,
              onTap: () => setState(() => _providesLunch = !_providesLunch),
            ),
            _MealChip(
              label: 'Dinner',
              icon: Icons.nights_stay_outlined,
              isSelected: _providesDinner,
              activeColor: primaryColor,
              onTap: () => setState(() => _providesDinner = !_providesDinner),
            ),
          ],
        ),
      ],
    );
  }
}

class _MealChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _MealChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? activeColor : colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check : icon,
              size: 18,
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}




