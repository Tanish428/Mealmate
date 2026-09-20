import 'package:flutter/material.dart';

class FeedbackModel {
  final String id;
  final String? messId;
  final String? memberId;
  final String memberName;
  final String initials;
  final Color avatarBackgroundColor;
  final Color avatarTextColor;
  final String timestamp;
  final int rating;
  final String mealContext;
  final String comment;

  const FeedbackModel({
    required this.id,
    this.messId,
    this.memberId,
    required this.memberName,
    required this.initials,
    required this.avatarBackgroundColor,
    required this.avatarTextColor,
    required this.timestamp,
    required this.rating,
    required this.mealContext,
    required this.comment,
  });

  factory FeedbackModel.fromMap(
    Map<String, dynamic> data, {
    int index = 0,
    ColorScheme? colorScheme,
  }) {
    final profileData = data['profiles'] as Map<String, dynamic>?;
    final memberName = profileData?['full_name'] as String? ?? 'Unknown Member';
    final message = (data['message'] as String?) ?? '';
    final createdAt = data['created_at'] as String?;

    final rawRating = data['rating'];
    final num? parsedRating = rawRating is num
        ? rawRating
        : (rawRating != null ? num.tryParse(rawRating.toString()) : null);
    final int rating = (parsedRating != null && parsedRating > 0)
        ? parsedRating.toInt().clamp(1, 5)
        : 5;

    final primary = colorScheme?.primary ?? const Color(0xFFC0392B);
    final avatarColors = [
      (primary.withAlpha(25), primary),
      (Colors.green.withAlpha(25), Colors.green),
      (Colors.blue.withAlpha(25), Colors.blue),
      (Colors.orange.withAlpha(25), Colors.orange),
    ];
    final colorPair = avatarColors[index % avatarColors.length];

    return FeedbackModel(
      id: data['id']?.toString() ?? index.toString(),
      messId: data['mess_id'] as String?,
      memberId: data['member_id'] as String?,
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

  static String _extractInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static String _formatDate(String? isoString) {
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mess_id': messId,
      'member_id': memberId,
      'message': comment,
      'rating': rating,
    };
  }
}

/// Backward compatibility alias
typedef FeedbackItem = FeedbackModel;
