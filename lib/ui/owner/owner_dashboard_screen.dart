import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'preparation_planner_screen.dart';
import 'waste_reports_screen.dart';
import 'surplus_allocation_screen.dart';
import 'broadcast_screen.dart';
import 'owner_feedback_screen.dart';
import '../../logic/controllers/owner_dashboard_controller.dart';

class OwnerDashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToMenu;
  final VoidCallback? onNavigateToMembers;

  const OwnerDashboardScreen({
    super.key,
    this.onNavigateToMenu,
    this.onNavigateToMembers,
  });

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  late final OwnerDashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OwnerDashboardController();
    _controller.addListener(_onStateChange);
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DashboardHeader(
                messName: _controller.messName,
                avatarUrl: _controller.stats?.avatarUrl,
                isLoading: _controller.isLoading,
              ),
              const SizedBox(height: 20.0),
              _NextMealCard(
                mealTitle: _controller.stats?.nextMealTitle,
                mealTime: _controller.stats?.nextMealTime,
                attendingCount: _controller.stats?.attendingCount ?? 0,
                totalJoinedMembers: _controller.stats?.activeMembersCount ?? 0,
                optedOutCount: _controller.stats?.optedOutCount ?? 0,
                attendanceRate: _controller.stats?.attendanceRate ?? 0.0,
              ),
              const SizedBox(height: 28.0),
              const _QuickActionsSection(),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final String? messName;
  final String? avatarUrl;
  final bool isLoading;

  const _DashboardHeader({this.messName, this.avatarUrl, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final displayName = (messName == null || messName == 'Your Mess' || messName!.isEmpty)
        ? 'Umiyaji'
        : messName!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome Back,",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2.0),
            if (isLoading)
              const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
              ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => context.go('/owner/profile'),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFD4C7),
                    width: 2.0,
                  ),
                ),
                child: ClipOval(
                  child: avatarUrl != null && avatarUrl!.isNotEmpty
                      ? Image.network(
                          avatarUrl!,
                          width: 38,
                          height: 38,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(displayName),
                        )
                      : _buildFallbackAvatar(displayName),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFallbackAvatar(String name) {
    return CircleAvatar(
      radius: 19,
      backgroundColor: const Color(0xFFFFECE8),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'O',
        style: const TextStyle(
          color: Color(0xFFBA2D1D),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _NextMealCard extends StatelessWidget {
  final String? mealTitle;
  final String? mealTime;
  final int attendingCount;
  final int totalJoinedMembers;
  final int optedOutCount;
  final double attendanceRate;

  const _NextMealCard({
    this.mealTitle, 
    this.mealTime,
    this.attendingCount = 0,
    this.totalJoinedMembers = 0,
    this.optedOutCount = 0,
    this.attendanceRate = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
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
          // Top Row: Cutlery icon + Title
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDECE5),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.restaurant,
                    color: Color(0xFFC0392B),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Next Meal",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFA55A46),
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      mealTitle ?? "Breakfast (Tomorrow)",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),

          // Badges: Time + Serving Soon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECE8),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time_filled,
                      size: 14,
                      color: Color(0xFFBA2D1D),
                    ),
                    const SizedBox(width: 5.0),
                    Text(
                      mealTime ?? "7:30 AM - 9:30 AM",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFBA2D1D),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F8ED),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    const Text(
                      "Serving Soon",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),

          // Attendance Section Title
          const Text(
            "Attendance",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12.0),

          // Attendance Details + Donut Chart
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "$attendingCount",
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFBA2D1D),
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          "/ $totalJoinedMembers",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    const Text(
                      "Members Attending",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.block,
                            size: 14,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            "$optedOutCount members opted out",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _AttendanceDonutChart(
                percentage: attendanceRate / 100.0,
                percentageText: "${attendanceRate.round()}%",
                labelText: "Attending",
              ),
            ],
          ),
          const SizedBox(height: 24.0),

          // View Dietary Details Button
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFBA2D1D),
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14.0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PreparationPlannerScreen(),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "View Dietary Details",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceDonutChart extends StatelessWidget {
  final double percentage;
  final String percentageText;
  final String labelText;

  const _AttendanceDonutChart({
    required this.percentage,
    required this.percentageText,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 92,
      child: CustomPaint(
        painter: _DonutPainter(percentage: percentage),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                percentageText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                labelText,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double percentage;

  _DonutPainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;
    const strokeWidth = 9.0;

    final backgroundPaint = Paint()
      ..color = const Color(0xFFF1F3F5)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..color = const Color(0xFFBA2D1D)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw background track
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc starting from top (-pi / 2)
    const startAngle = -3.141592653589793 / 2;
    final sweepAngle = 2 * 3.141592653589793 * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.percentage != percentage;
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                backgroundColor: const Color(0xFFFDECE8),
                icon: Icons.campaign_outlined,
                iconColor: const Color(0xFFBA2D1D),
                textColor: const Color(0xFF8B2519),
                label: "Broadcast",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BroadcastScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: _QuickActionCard(
                backgroundColor: const Color(0xFFDCF0E7),
                icon: Icons.eco_outlined,
                iconColor: const Color(0xFF267D56),
                textColor: const Color(0xFF1A5A3D),
                label: "Waste Log",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WasteReportsScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: _QuickActionCard(
                backgroundColor: const Color(0xFFFEF0D6),
                icon: Icons.volunteer_activism_outlined,
                iconColor: const Color(0xFFC07D1C),
                textColor: const Color(0xFF8D530B),
                label: "Surplus",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SurplusAllocationScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: _QuickActionCard(
                backgroundColor: const Color(0xFFF5E6ED),
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: const Color(0xFF9B4C6E),
                textColor: const Color(0xFF7A3654),
                label: "Feedback",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OwnerFeedbackScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final Color textColor;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
    required this.textColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
            const SizedBox(height: 8.0),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
