import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../common/custom_textfield.dart';
import '../common/custom_button.dart';
import '../common/qr_scanner_overlay.dart';
import '../../logic/controllers/qr_scanner_controller.dart';

// Local constants for spacing as per the design constraints
class AppSpacing {
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
}

class JoinMessScreen extends StatefulWidget {
  const JoinMessScreen({super.key});

  @override
  State<JoinMessScreen> createState() => _JoinMessScreenState();
}

class _JoinMessScreenState extends State<JoinMessScreen> {
  final TextEditingController _inviteCodeController = TextEditingController();
  final QrScannerController _qrController = QrScannerController();

  @override
  void initState() {
    super.initState();
    _qrController.addListener(_onStateChange);
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    _qrController.removeListener(_onStateChange);
    _qrController.dispose();
    super.dispose();
  }

  Future<void> _submitJoinRequest([String? code]) async {
    final inviteCode = code ?? _inviteCodeController.text.trim();
    if (inviteCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an invite code')),
      );
      return;
    }

    final success = await _qrController.joinMessWithCode(inviteCode);
    if (!mounted) return;

    if (success) {
      context.go('/member/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_qrController.errorMessage ?? 'Failed to join mess.'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    // Primary color mapped from the theme (rust/red)
    final primaryColor = colorScheme.primary;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Bottom Background Decoration (Wavy Graphic)
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox.shrink(),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Section
                  _buildHeader(context, primaryColor, textTheme),
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Invitation Code Card
                  _buildInviteCodeCard(context, primaryColor, textTheme),
                  const SizedBox(height: AppSpacing.l),
                  
                  // Divider ("OR")
                  _buildDivider(textTheme),
                  const SizedBox(height: AppSpacing.l),
                  
                  // QR Code Card
                  _buildQRCodeCard(context, primaryColor, textTheme),
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Bottom Illustration Area & Footer
                  _buildBottomIllustration(context, textTheme),
                  const SizedBox(height: AppSpacing.l), // Extra padding at bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primaryColor, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
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
            // Right graphic: bowl + text
            Column(
              children: [
                Icon(Icons.ramen_dining, color: Colors.orange.shade300, size: 40),
                const SizedBox(height: 4),
                Text(
                  'Good Food Better Days',
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.l),
        RichText(
          text: TextSpan(
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: textTheme.bodyLarge?.color ?? Colors.black87,
            ),
            children: [
              const TextSpan(text: 'Find Your\n'),
              TextSpan(
                text: 'Mess',
                style: TextStyle(color: primaryColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          'Join your mess using an invitation code or by scanning a QR code.',
          style: textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildInviteCodeCard(BuildContext context, Color primaryColor, TextTheme textTheme) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.key, color: primaryColor, size: 24),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Join with Invitation Code',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ask your mess owner for the code.',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          CustomTextField(
            controller: _inviteCodeController,
            hintText: 'Enter 6-digit invite code',
            prefixIcon: Icons.search,
          ),
          const SizedBox(height: AppSpacing.l),
          SizedBox(
            width: double.infinity,
            height: 56.0,
            child: _qrController.isProcessing 
                ? Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                    ),
                  )
                : CustomButton(
                    text: 'Join Mess',
                    onPressed: () => _submitJoinRequest(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(TextTheme textTheme) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Text(
            'OR',
            style: textTheme.labelLarge?.copyWith(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      ],
    );
  }

  Widget _buildQRCodeCard(BuildContext context, Color primaryColor, TextTheme textTheme) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.qr_code_scanner, color: primaryColor, size: 24),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan QR Code',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Scan the code provided by your mess.',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Scan QR Code',
              isPrimary: false,
              icon: Icons.qr_code,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => QRScannerOverlay(
                      onDetect: (barcode) {
                        Navigator.of(context).pop(); // Close scanner
                        
                        // Populate the text field
                        setState(() {
                          _inviteCodeController.text = barcode;
                        });
                        
                        // Automatically trigger the join action
                        _submitJoinRequest(barcode);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomIllustration(BuildContext context, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.restaurant_menu, color: Colors.orange.shade300, size: 100),
        const SizedBox(height: AppSpacing.m),
        Text(
          'Good Food Brings Great People',
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            color: Colors.brown.shade600,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Text(
            'Enter an invite code or scan a QR code to become a part of your mess community.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
