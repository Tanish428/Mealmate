import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String _selectedMeal = 'Lunch';
  int _rating = 0;
  int _commentLength = 0;
  final TextEditingController _commentController = TextEditingController();

  final List<String> _meals = ['Breakfast', 'Lunch', 'Dinner'];

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      setState(() {
        _commentLength = _commentController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // Warm cream/off-white background
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(colorScheme, textTheme),
                    const SizedBox(height: 32.0),
                    _buildMealSelector(colorScheme, textTheme),
                    const SizedBox(height: 24.0),
                    _buildRatingCard(colorScheme, textTheme),
                    const SizedBox(height: 24.0),
                    _buildCommentCard(colorScheme, textTheme),
                    const SizedBox(height: 32.0),
                  ],
                ),
              ),
            ),
            _buildBottomAction(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colorScheme.primary.withAlpha(25), // Light red background
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.primary),
            onPressed: () {
              // Empty callback per architectural rules
            },
          ),
        ),
        const SizedBox(width: 16.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Give Feedback",
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              "Let the mess owner know how they are doing.",
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMealSelector(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Meal",
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedMeal,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500),
              items: _meals.map((String meal) {
                return DropdownMenuItem<String>(
                  value: meal,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Icon(
                          Icons.restaurant, // fork/knife approximation
                          color: Colors.grey.shade800,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Text(
                        meal,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedMeal = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingCard(ColorScheme colorScheme, TextTheme textTheme) {
    String ratingText = "Rate your meal";
    if (_rating > 0) {
      if (_rating == 5) {
        ratingText = "5.0 - Excellent";
      } else if (_rating == 4) {
        ratingText = "4.0 - Good";
      } else if (_rating == 3) {
        ratingText = "3.0 - Average";
      } else if (_rating == 2) {
        ratingText = "2.0 - Poor";
      } else if (_rating == 1) {
        ratingText = "1.0 - Terrible";
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8), // Very soft shadow
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "How was your meal?",
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final isActive = index < _rating;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(
                    isActive ? Icons.star : Icons.star_border,
                    color: isActive ? colorScheme.primary : Colors.grey.shade300,
                    size: 44.0,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              ratingText,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8), // Very soft shadow
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add a comment",
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            "Optional",
            style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16.0),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: CustomTextField(
              controller: _commentController,
              hintText: "Tell us what you liked or what could be improved...",
              maxLines: 4,
              minLines: 4,
              hasBorder: false,
            ),
          ),
          const SizedBox(height: 8.0),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              "$_commentLength/500",
              style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: CustomButton(
        onPressed: () {},
        text: "Submit Feedback",
        icon: Icons.send, // approximate for paper airplane
      ),
    );
  }
}

// =====================================================================
// STUB IMPLEMENTATIONS FOR REQUIRED WIDGETS
// Provided here to prevent analyze errors since they don't exist yet in the repo.
// =====================================================================

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String hintText;
  final bool obscureText;
  final int maxLines;
  final int minLines;
  final bool hasBorder;

  const CustomTextField({
    super.key,
    required this.controller,
    this.prefixIcon,
    this.suffixIcon,
    required this.hintText,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines = 1,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      minLines: minLines,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: !hasBorder,
        fillColor: hasBorder ? null : Colors.transparent,
        border: hasBorder
            ? OutlineInputBorder(borderRadius: BorderRadius.circular(8.0))
            : InputBorder.none,
        enabledBorder: hasBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.grey.shade300),
              )
            : InputBorder.none,
        focusedBorder: hasBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
              )
            : InputBorder.none,
        contentPadding: const EdgeInsets.all(16.0),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isOutlined;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isOutlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon),
              const SizedBox(width: 8.0),
            ],
            Text(text),
          ],
        ),
      );
    }
    
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8.0),
          ],
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
