import 'package:flutter/material.dart';

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

class NoticeBoardScreen extends StatelessWidget {
  const NoticeBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final List<NoticeItem> mockNotices = [
      const NoticeItem(
        id: '1',
        title: 'Mess Timing Update',
        body: 'Dinner timings have been extended by 30 minutes for today due to the festival.',
        timestamp: 'Today, 4:30 PM',
        iconData: Icons.campaign,
        isRead: false,
      ),
      const NoticeItem(
        id: '2',
        title: 'Monthly Fees Reminder',
        body: 'Please clear your pending dues for this month by the 5th to avoid late fees.',
        timestamp: 'Yesterday, 9:00 AM',
        iconData: Icons.account_balance_wallet,
        isRead: true,
      ),
      const NoticeItem(
        id: '3',
        title: 'Holiday Closure',
        body: 'The mess will remain closed for lunch and dinner tomorrow for maintenance works.',
        timestamp: 'Oct 12, 10:15 AM',
        iconData: Icons.event_busy,
        isRead: true,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // Warm cream/off-white background
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 32.0),
              child: _buildHeader(context, colorScheme, textTheme),
            ),
            Padding(
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
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
                itemCount: mockNotices.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16.0),
                itemBuilder: (context, index) {
                  return _buildNoticeCard(mockNotices[index], colorScheme, textTheme);
                },
              ),
            ),
          ],
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



