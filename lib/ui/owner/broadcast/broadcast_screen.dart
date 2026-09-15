import 'package:flutter/material.dart';
import '../../common/custom_textfield.dart';
import '../../common/custom_button.dart';

class AnnouncementData {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String timeText;
  final String body;
  final String readStats;

  const AnnouncementData({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.timeText,
    required this.body,
    required this.readStats,
  });
}

class BroadcastScreen extends StatefulWidget {
  const BroadcastScreen({super.key});

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  final TextEditingController _announcementController = TextEditingController();

  final List<AnnouncementData> _recentAnnouncements = [
    AnnouncementData(
      icon: Icons.campaign,
      iconColor: Colors.red.shade700,
      iconBgColor: Colors.red.shade50,
      title: "Mess Timing Update",
      timeText: "Today, 9:00 AM",
      body: "Please note that lunch will be served 30 minutes late today due to maintenance.",
      readStats: "Read by 42/50",
    ),
    AnnouncementData(
      icon: Icons.calendar_today,
      iconColor: Colors.grey.shade700,
      iconBgColor: Colors.grey.shade200,
      title: "Holiday Closure",
      timeText: "10 Sep, 4:00 PM",
      body: "The mess will remain closed tomorrow evening for the festival. Please plan accordingly.",
      readStats: "Read by 50/50",
    ),
  ];

  @override
  void dispose() {
    _announcementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32.0),
              _buildNewAnnouncementCard(context),
              const SizedBox(height: 32.0),
              _buildRecentAnnouncementsSection(context),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          customBorder: const CircleBorder(),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, color: Colors.red.shade700),
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Broadcast",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
              const SizedBox(height: 4.0),
              Text(
                "Send an announcement to your members",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewAnnouncementCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "New Announcement",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            controller: _announcementController,
            maxLines: 5,
            maxLength: 500,
            hintText: "Type your announcement here...",
          ),
          const SizedBox(height: 24.0),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: "Send to 50 Members",
              icon: Icons.send,
              onPressed: () {
                // Future implementation
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAnnouncementsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent Announcements",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
        ),
        const SizedBox(height: 16.0),
        ..._recentAnnouncements.map((data) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _AnnouncementCard(data: data),
            )),
      ],
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final AnnouncementData data;

  const _AnnouncementCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: data.iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(data.icon, color: data.iconColor, size: 20),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      data.timeText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Text(
            data.body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 16.0),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Icon(Icons.remove_red_eye_outlined, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 6.0),
              Text(
                data.readStats,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
