import 'package:flutter/material.dart';
import '../../common/stat_card.dart';

class FeedbackItem {
  final String id;
  final String memberName;
  final String initials;
  final Color avatarBackgroundColor;
  final Color avatarTextColor;
  final String timestamp;
  final int rating;
  final String mealContext;
  final String comment;

  const FeedbackItem({
    required this.id,
    required this.memberName,
    required this.initials,
    required this.avatarBackgroundColor,
    required this.avatarTextColor,
    required this.timestamp,
    required this.rating,
    required this.mealContext,
    required this.comment,
  });
}

class OwnerFeedbackScreen extends StatelessWidget {
  const OwnerFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    final List<FeedbackItem> mockFeedback = [
      FeedbackItem(
        id: '1',
        memberName: 'Tanish Mistry',
        initials: 'TM',
        avatarBackgroundColor: colorScheme.primary.withAlpha(25),
        avatarTextColor: colorScheme.primary,
        timestamp: 'Today, 3:15 PM',
        rating: 4,
        mealContext: "Today's Lunch",
        comment: "The paneer butter masala was really good today. Keep up the good quality. But chapati could be slightly softer.",
      ),
      FeedbackItem(
        id: '2',
        memberName: 'Priya Sharma',
        initials: 'PS',
        avatarBackgroundColor: Colors.green.withAlpha(25),
        avatarTextColor: Colors.green,
        timestamp: 'Yesterday, 8:45 PM',
        rating: 5,
        mealContext: "Dinner",
        comment: "Excellent dinner, the sweet dish was amazing! Loved the authentic taste.",
      ),
      FeedbackItem(
        id: '3',
        memberName: 'Rahul Verma',
        initials: 'RV',
        avatarBackgroundColor: Colors.blue.withAlpha(25),
        avatarTextColor: Colors.blue,
        timestamp: 'Yesterday, 9:30 AM',
        rating: 3,
        mealContext: "Breakfast",
        comment: "Poha was a bit dry, but the tea made up for it.",
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // Warm cream/off-white background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(colorScheme, textTheme),
              const SizedBox(height: 32.0),
              _buildSummaryMetric(colorScheme, textTheme),
              const SizedBox(height: 32.0),
              Text(
                "Recent Feedback",
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(height: 16.0),
              _buildFeedbackList(mockFeedback, colorScheme, textTheme),
              const SizedBox(height: 32.0),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Member Feedback",
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                "See what your members think about the meals.",
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryMetric(ColorScheme colorScheme, TextTheme textTheme) {
    return StatCard(
      metric: "4.3",
      title: "Average Rating",
      subtitle: "Based on 124 reviews",
      icon: Icons.star,
      iconColor: Colors.amber,
      iconBackgroundColor: Colors.amber.withAlpha(50),
    );
  }

  Widget _buildFeedbackList(List<FeedbackItem> items, ColorScheme colorScheme, TextTheme textTheme) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16.0),
      itemBuilder: (context, index) {
        return _buildFeedbackCard(items[index], colorScheme, textTheme);
      },
    );
  }

  Widget _buildFeedbackCard(FeedbackItem item, ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20.0),
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
          // Top Row: Avatar, Name, Timestamp
          Row(
            children: [
              CircleAvatar(
                radius: 20.0,
                backgroundColor: item.avatarBackgroundColor,
                child: Text(
                  item.initials,
                  style: TextStyle(
                    color: item.avatarTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  item.memberName,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Text(
                item.timestamp,
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          
          // Middle Row: Stars and Context Pill
          Row(
            children: [
              // 5 Stars
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final isActive = index < item.rating;
                  return Padding(
                    padding: const EdgeInsets.only(right: 2.0),
                    child: Icon(
                      isActive ? Icons.star : Icons.star_border,
                      color: isActive ? colorScheme.primary : Colors.grey.shade300,
                      size: 20.0,
                    ),
                  );
                }),
              ),
              const SizedBox(width: 12.0),
              // Meal Context Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.restaurant,
                      size: 14.0,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      item.mealContext,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          
          // Body Row: Comment Text
          Text(
            item.comment,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
