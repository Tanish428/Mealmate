import 'package:flutter/material.dart';
import '../../data/repos/feedback_repo.dart';
import '../common/stat_card.dart';

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

class OwnerFeedbackScreen extends StatefulWidget {
  const OwnerFeedbackScreen({super.key});

  @override
  State<OwnerFeedbackScreen> createState() => _OwnerFeedbackScreenState();
}

class _OwnerFeedbackScreenState extends State<OwnerFeedbackScreen> {
  final FeedbackRepository _feedbackRepo = FeedbackRepository();
  late Future<List<Map<String, dynamic>>> _feedbackFuture;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  void _loadFeedback() {
    setState(() {
      _feedbackFuture = _feedbackRepo.getMessFeedback();
    });
  }

  String _extractInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dt);

      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      final timeStr = '$hour:$minute $period';

      if (difference.inDays == 0 && dt.day == now.day) {
        return 'Today, $timeStr';
      } else if (difference.inDays <= 1 && dt.day == now.subtract(const Duration(days: 1)).day) {
        return 'Yesterday, $timeStr';
      } else {
        return '${dt.day}/${dt.month}/${dt.year}, $timeStr';
      }
    } catch (_) {
      return isoString;
    }
  }

  FeedbackItem _mapToFeedbackItem(Map<String, dynamic> data, int index, ColorScheme colorScheme) {
    final profileData = data['profiles'] as Map<String, dynamic>?;
    final memberName = profileData?['full_name'] as String? ?? 'Unknown Member';
    final message = data['message'] as String? ?? '';
    final createdAt = data['created_at'] as String?;
    
    final rawRating = data['rating'];
    final num? parsedRating = rawRating is num
        ? rawRating
        : (rawRating != null ? num.tryParse(rawRating.toString()) : null);
    final int rating = (parsedRating != null && parsedRating > 0)
        ? parsedRating.toInt().clamp(1, 5)
        : 5;

    // Cycle through subtle accent colors for member avatars
    final avatarColors = [
      (colorScheme.primary.withAlpha(25), colorScheme.primary),
      (Colors.green.withAlpha(25), Colors.green),
      (Colors.blue.withAlpha(25), Colors.blue),
      (Colors.orange.withAlpha(25), Colors.orange),
    ];
    final colorPair = avatarColors[index % avatarColors.length];

    return FeedbackItem(
      id: index.toString(),
      memberName: memberName,
      initials: _extractInitials(memberName),
      avatarBackgroundColor: colorPair.$1,
      avatarTextColor: colorPair.$2,
      timestamp: _formatDate(createdAt),
      rating: rating,
      mealContext: "Feedback",
      comment: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // Warm cream/off-white background
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadFeedback(),
          color: colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, colorScheme, textTheme),
                const SizedBox(height: 32.0),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _feedbackFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryMetric(
                            metric: "--",
                            subtitle: "Calculating rating...",
                          ),
                          const SizedBox(height: 32.0),
                          _buildSectionTitle(textTheme),
                          const SizedBox(height: 16.0),
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 48.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ],
                      );
                    }

                    if (snapshot.hasError) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryMetric(
                            metric: "--",
                            subtitle: "Error loading ratings",
                          ),
                          const SizedBox(height: 32.0),
                          _buildSectionTitle(textTheme),
                          const SizedBox(height: 16.0),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32.0),
                              child: Column(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red.shade400, size: 36),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Failed to load feedback: ${snapshot.error}',
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodyMedium?.copyWith(color: Colors.red.shade700),
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton.icon(
                                    onPressed: _loadFeedback,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    final data = snapshot.data ?? [];

                    // Calculate accurate dynamic average rating from database records
                    double totalRating = 0.0;
                    int ratedCount = 0;

                    for (final entry in data) {
                      final rawRating = entry['rating'];
                      final num? r = rawRating is num
                          ? rawRating
                          : (rawRating != null ? num.tryParse(rawRating.toString()) : null);

                      if (r != null && r > 0) {
                        totalRating += r.toDouble();
                        ratedCount++;
                      }
                    }

                    final String avgRatingStr;
                    final String subtitleStr;

                    if (data.isEmpty) {
                      avgRatingStr = "0.0";
                      subtitleStr = "No reviews yet";
                    } else if (ratedCount > 0) {
                      avgRatingStr = (totalRating / ratedCount).toStringAsFixed(1);
                      subtitleStr = ratedCount == 1
                          ? "Based on 1 review"
                          : "Based on $ratedCount reviews";
                    } else {
                      // Handled if older records exist without rating populated yet
                      avgRatingStr = "5.0";
                      subtitleStr = "Based on ${data.length} ${data.length == 1 ? 'review' : 'reviews'}";
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryMetric(
                          metric: avgRatingStr,
                          subtitle: subtitleStr,
                        ),
                        const SizedBox(height: 32.0),
                        _buildSectionTitle(textTheme),
                        const SizedBox(height: 16.0),
                        if (data.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 48.0),
                              child: Column(
                                children: [
                                  Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 12.0),
                                  Text(
                                    "No feedback received yet.",
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          _buildFeedbackList(
                            List.generate(
                              data.length,
                              (i) => _mapToFeedbackItem(data[i], i, colorScheme),
                            ),
                            colorScheme,
                            textTheme,
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(TextTheme textTheme) {
    return Text(
      "Recent Feedback",
      style: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontSize: 18.0,
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colorScheme.primary.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.primary),
            onPressed: () { if (Navigator.of(context).canPop()) Navigator.pop(context); },
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

  Widget _buildSummaryMetric({
    required String metric,
    required String subtitle,
  }) {
    return StatCard(
      metric: metric,
      title: "Average Rating",
      subtitle: subtitle,
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
              // Stars
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
