import 'package:flutter/material.dart';
import '../../data/repos/broadcast_repo.dart';

class NoticeItem {
  final String id;
  final String title;
  final String body;
  final String timestamp;
  final IconData iconData;
  final bool isRead;

  const NoticeItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.iconData,
    required this.isRead,
  });
}

class NoticeBoardScreen extends StatefulWidget {
  const NoticeBoardScreen({super.key});

  @override
  State<NoticeBoardScreen> createState() => _NoticeBoardScreenState();
}

class _NoticeBoardScreenState extends State<NoticeBoardScreen> {
  final BroadcastRepository _broadcastRepo = BroadcastRepository();
  late Future<List<Map<String, dynamic>>> _noticesFuture;

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  void _loadNotices() {
    setState(() {
      _noticesFuture = _broadcastRepo.getMessBroadcasts();
    });
  }

  String _formatTime(String? isoString) {
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

  NoticeItem _mapToNoticeItem(Map<String, dynamic> data) {
    final title = (data['title'] as String?) ?? 'Announcement';
    final message = (data['message'] as String?) ?? '';
    final createdAt = data['created_at'] as String?;

    return NoticeItem(
      id: data['id']?.toString() ?? '',
      title: title,
      body: message,
      timestamp: _formatTime(createdAt),
      iconData: Icons.campaign,
      isRead: false,
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
          onRefresh: () async => _loadNotices(),
          color: colorScheme.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 32.0),
                  child: _buildHeader(context, colorScheme, textTheme),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    "Recent Announcements",
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _noticesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                              const SizedBox(height: 12),
                              Text(
                                "Failed to load notices",
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                snapshot.error.toString(),
                                textAlign: TextAlign.center,
                                style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: _loadNotices,
                                icon: const Icon(Icons.refresh),
                                label: const Text("Retry"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  final data = snapshot.data ?? [];

                  if (data.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withAlpha(25),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.campaign_outlined,
                                  size: 48,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No Announcements Yet",
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Important updates and notices from your mess owner will appear here.",
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  final notices = data.map((e) => _mapToNoticeItem(e)).toList();

                  return SliverPadding(
                    padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildNoticeCard(notices[index], colorScheme, textTheme),
                          );
                        },
                        childCount: notices.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colorScheme.primary.withAlpha(25), // Light red background
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
                "Notice Board",
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                "Important updates from your mess owner",
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

  Widget _buildNoticeCard(NoticeItem item, ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: item.isRead ? Colors.white : colorScheme.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(16.0),
        border: item.isRead 
            ? null 
            : Border(left: BorderSide(color: colorScheme.primary, width: 4.0)),
        boxShadow: item.isRead
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!item.isRead) ...[
            Container(
              margin: const EdgeInsets.only(top: 18.0, right: 8.0),
              width: 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: item.isRead 
                  ? Colors.grey.shade100 
                  : colorScheme.primary.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.iconData,
              color: item.isRead ? Colors.grey.shade600 : colorScheme.primary,
              size: 24.0,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      item.timestamp,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  item.body,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
