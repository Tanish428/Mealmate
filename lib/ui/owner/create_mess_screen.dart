import 'package:flutter/material.dart';

// Since AppSpacing, CustomButton, and CustomTextField were not found,
// they are implemented locally to satisfy the design requirements.
class AppSpacing {
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
}

class CustomTextField extends StatelessWidget {
  final String label;
  final String placeholder;
  final IconData prefixIcon;

  const CustomTextField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.s),
        TextField(
          decoration: InputDecoration(
            hintText: placeholder,
            prefixIcon: Icon(prefixIcon, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(
                vertical: 12, horizontal: AppSpacing.m),
          ),
        ),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? trailingIcon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange, // mapping rust/red
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: AppSpacing.s),
              Icon(trailingIcon, size: 20, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Hardcoded primary fallback mapping since AppColors wasn't found
    final primaryRed = Colors.deepOrange; 

    return Scaffold(
      backgroundColor: Colors.orange.shade50, // Warm cream/off-white
      body: Stack(
        children: [
          // Background layer for decorative graphics
          Positioned(
            top: 0,
            right: 0,
            child: const SizedBox.shrink(), // Placeholder for top_right_decoration.png
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: const SizedBox.shrink(), // Placeholder for bottom_decoration.png
          ),
          Positioned(
            bottom: AppSpacing.m,
            right: AppSpacing.m,
            child: Text(
              "Good Food Stronger Communities",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          // Foreground layer
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: Header
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: primaryRed.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: primaryRed),
                          onPressed: () {}, // Empty callback as per spec
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.l),
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      children: [
                        const TextSpan(text: 'Set Up Your\n'),
                        TextSpan(
                          text: 'Mess',
                          style: TextStyle(color: primaryRed),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Add your details to start welcoming members.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Section 2: Image Upload Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.l),
                    decoration: BoxDecoration(
                      color: primaryRed.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryRed.withValues(alpha: 0.3),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryRed.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.camera_alt, color: primaryRed),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Text(
                          'Upload Mess Photo',
                          style: TextStyle(
                            color: primaryRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'PNG, JPG up to 5MB',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Section 3: Mess Details
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mess Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.l),
                        const CustomTextField(
                          label: 'Mess Name',
                          placeholder: 'e.g., Campus Central Mess',
                          prefixIcon: Icons.storefront,
                        ),
                        const SizedBox(height: AppSpacing.m),
                        const CustomTextField(
                          label: 'Address',
                          placeholder: 'e.g., Near University Campus',
                          prefixIcon: Icons.location_on,
                        ),
                        const SizedBox(height: AppSpacing.m),
                        const CustomTextField(
                          label: 'Maximum Capacity',
                          placeholder: 'e.g., 50',
                          prefixIcon: Icons.group,
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          'Maximum number of members your mess can accommodate.',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Section 4: Payment Preferences
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.credit_card, color: primaryRed, size: 28),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Accept Digital Payments',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Allow members to pay their monthly fees via the app.',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Switch(
                          value: _acceptDigitalPayments,
                          activeTrackColor: primaryRed.withValues(alpha: 0.5),
                          activeThumbColor: primaryRed,
                          onChanged: (val) {
                            setState(() {
                              _acceptDigitalPayments = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Section 5: Meals Provided
                  const Text(
                    'Meals Provided',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select the meals offered at your mess.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _providesBreakfast = !_providesBreakfast),
                        child: _buildMealChip('Breakfast', _providesBreakfast ? Icons.check : Icons.wb_sunny_outlined, _providesBreakfast, primaryRed),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      GestureDetector(
                        onTap: () => setState(() => _providesLunch = !_providesLunch),
                        child: _buildMealChip('Lunch', _providesLunch ? Icons.check : Icons.restaurant, _providesLunch, primaryRed),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      GestureDetector(
                        onTap: () => setState(() => _providesDinner = !_providesDinner),
                        child: _buildMealChip('Dinner', _providesDinner ? Icons.check : Icons.nights_stay_outlined, _providesDinner, primaryRed),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Section 6: Action Area
                  CustomButton(
                    text: 'Create Mess',
                    trailingIcon: Icons.arrow_forward,
                    onPressed: () {}, // Empty callback
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealChip(String label, IconData icon, bool isSelected, Color activeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? activeColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? activeColor : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Colors.black87,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
