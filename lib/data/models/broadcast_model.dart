import 'package:flutter/material.dart';

class BroadcastModel {
  final String id;
  final String? messId;
  final String? ownerId;
  final String title;
  final String body;
  final String timeText;
  final String readStats;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final bool isRead;

  const BroadcastModel({
    required this.id,
    this.messId,
    this.ownerId,
    required this.title,
    required this.body,
    required this.timeText,
    required this.readStats,
    this.icon = Icons.campaign,
    this.iconColor = const Color(0xFFC0392B),
    this.iconBgColor = const Color(0xFFFFEBEE),
    this.isRead = false,
  });

  factory BroadcastModel.fromMap(
    Map<String, dynamic> data, {
    int memberCount = 0,
    Color? primaryColor,
  }) {
    final title = (data['title'] as String?) ?? 'Announcement';
    final message = (data['message'] as String?) ?? '';
    final createdAt = data['created_at'] as String?;
    final primary = primaryColor ?? const Color(0xFFC0392B);

    return BroadcastModel(
      id: data['id']?.toString() ?? '',
      messId: data['mess_id'] as String?,
      ownerId: data['owner_id'] as String?,
      title: title,
      body: message,
      timeText: _formatTime(createdAt),
      readStats: memberCount > 0
          ? "Sent to $memberCount ${memberCount == 1 ? 'member' : 'members'}"
          : "Sent to members",
      icon: Icons.campaign,
      iconColor: primary,
      iconBgColor: primary.withAlpha(25),
      isRead: false,
    );
  }

  static String _formatTime(String? isoString) {
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
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${dt.day} ${months[dt.month - 1]}, $timeStr';
      }
    } catch (_) {
      return isoString;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mess_id': messId,
      'owner_id': ownerId,
      'title': title,
      'message': body,
    };
  }
}

/// Backward compatibility aliases
typedef AnnouncementData = BroadcastModel;
typedef NoticeItem = BroadcastModel;
