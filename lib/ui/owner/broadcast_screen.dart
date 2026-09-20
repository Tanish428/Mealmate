import 'package:flutter/material.dart';
import '../../data/repos/broadcast_repo.dart';
import '../../data/repos/mess_repo.dart';
import '../common/custom_textfield.dart';
import '../common/custom_button.dart';

class AnnouncementData {
  final String id;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String timeText;
  final String body;
  final String readStats;

  const AnnouncementData({
    required this.id,
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
  final BroadcastRepository _broadcastRepo = BroadcastRepository();
  final MessRepository _messRepo = MessRepository();

  late Future<List<Map<String, dynamic>>> _broadcastsFuture;
  int _memberCount = 0;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _broadcastsFuture = _broadcastRepo.getMessBroadcasts();
    });
    _fetchMemberCount();
  }

  Future<void> _fetchMemberCount() async {
    try {
      final members = await _messRepo.getMessMembers();
      if (mounted) {
        setState(() {
          _memberCount = members.length;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _announcementController.dispose();
    super.dispose();
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

  AnnouncementData _mapToAnnouncement(Map<String, dynamic> data) {
    final title = (data['title'] as String?) ?? 'Announcement';
    final message = (data['message'] as String?) ?? '';
    final createdAt = data['created_at'] as String?;

    return AnnouncementData(
      id: data['id']?.toString() ?? '',
      icon: Icons.campaign,
      iconColor: Colors.red.shade700,
      iconBgColor: Colors.red.shade50,
      title: title,
      timeText: _formatTime(createdAt),
      body: message,
      readStats: "Sent to $_memberCount ${_memberCount == 1 ? 'member' : 'members'}",
    );
  }

  Future<void> _handleSendBroadcast() async {
    final text = _announcementController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an announcement message.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await _broadcastRepo.sendBroadcast(message: text);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Announcement broadcasted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      _announcementController.clear();
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadData(),
          color: Colors.red.shade700,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
    final buttonLabel = _memberCount > 0
        ? "Send to $_memberCount ${_memberCount == 1 ? 'Member' : 'Members'}"
        : "Send Announcement";

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
              text: buttonLabel,
              icon: Icons.send,
              isLoading: _isSending,
              onPressed: _handleSendBroadcast,
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
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _broadcastsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade400, size: 36),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load announcements',
                        style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      TextButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = snapshot.data ?? [];

            if (data.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Column(
                    children: [
                      Icon(Icons.campaign_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        "No broadcasts sent yet.",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final announcements = data.map((e) => _mapToAnnouncement(e)).toList();

            return Column(
              children: announcements.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _AnnouncementCard(data: item),
                );
              }).toList(),
            );
          },
        ),
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
                  height: 1.4,
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
