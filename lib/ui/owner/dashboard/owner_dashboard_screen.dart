import 'package:flutter/material.dart';
import '../menu/menu_manager_screen.dart';
import '../demand/preparation_planner_screen.dart';
import '../settings/mess_profile_screen.dart';
import '../analytics/waste_reports_screen.dart';
import '../surplus/surplus_allocation_screen.dart';
import '../members/members_screen.dart';
import '../broadcast/broadcast_screen.dart';
import '../feedback/owner_feedback_screen.dart';
import '../../common/custom_button.dart';
import '../../common/stat_card.dart';

class OwnerDashboardScreen extends StatelessWidget {
  final VoidCallback? onNavigateToMenu;
  final VoidCallback? onNavigateToMembers;
  
  const OwnerDashboardScreen({super.key, this.onNavigateToMenu, this.onNavigateToMembers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _DashboardHeader(),
              const SizedBox(height: 24.0),
              const _NextMealCard(),
              const SizedBox(height: 32.0),
              _StatsSection(onNavigateToMembers: onNavigateToMembers),
              const SizedBox(height: 32.0),
              _QuickActionsSection(onNavigateToMenu: onNavigateToMenu),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Overview",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4.0),
            Text(
              "DDU Campus Mess",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MessProfileScreen(),
                  ),
                );
              },
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.settings, color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NextMealCard extends StatelessWidget {
  const _NextMealCard();

  @override
  Widget build(BuildContext context) {
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
        children: [
          // Top Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.restaurant, color: Colors.red.shade700),
              ),
              const SizedBox(width: 12.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Next Meal",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey.shade600)),
                  Text("Lunch",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700)),
                ],
              ),
              const SizedBox(width: 12.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.red.shade700),
                    const SizedBox(width: 4.0),
                    Text("12:30 PM",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700)),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    const Text("Serving Soon",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          // Middle Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text("42",
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700)),
                        const SizedBox(width: 8.0),
                        Text("/ 50",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: Colors.grey.shade500)),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Text("Members Attending",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey.shade700)),
                    const SizedBox(height: 12.0),
                    Row(
                      children: [
                        Icon(Icons.group_off, size: 16, color: Colors.grey.shade500),
                        const SizedBox(width: 6.0),
                        Text("8 members opted out",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey.shade600)),
                      ],
                    ),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: 0.84,
                      strokeWidth: 8.0,
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.red.shade700,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("84%",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text("Attending",
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          // Bottom button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: "View Dietary Details",
              icon: Icons.arrow_forward_ios,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PreparationPlannerScreen(),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  final VoidCallback? onNavigateToMembers;
  const _StatsSection({this.onNavigateToMembers});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Today at a Glance",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text("Mon, 15 Sep 2025",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (onNavigateToMembers != null) {
                    onNavigateToMembers!();
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MembersScreen()));
                  }
                },
                child: StatCard(
                  metric: "50",
                  title: "Active Members",
                  icon: Icons.group,
                  iconColor: Colors.red.shade700,
                  iconBackgroundColor: Colors.red.shade50,
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: StatCard(
                metric: "₹12,500",
                title: "Monthly\nRevenue",
                icon: Icons.account_balance_wallet,
                iconColor: Colors.green.shade700,
                iconBackgroundColor: Colors.green.shade50,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  final VoidCallback? onNavigateToMenu;
  
  const _QuickActionsSection({this.onNavigateToMenu});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Quick Actions",
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16.0),
        Wrap(
          spacing: 12.0,
          runSpacing: 16.0,
          alignment: WrapAlignment.spaceEvenly,
          children: [
            _QuickActionItem(
              icon: Icons.restaurant_menu,
              label: "Edit Menu",
              onTap: () {
                if (onNavigateToMenu != null) {
                  onNavigateToMenu!();
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MenuManagerScreen()));
                }
              },
            ),
            _QuickActionItem(
              icon: Icons.campaign,
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
            _QuickActionItem(
              icon: Icons.eco,
              label: "Waste",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WasteReportsScreen(),
                  ),
                );
              },
            ),
            _QuickActionItem(
              icon: Icons.volunteer_activism,
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
            _QuickActionItem(
              icon: Icons.chat_bubble_outline,
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
          ],
        ),
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.red.shade700, size: 28),
          ),
          const SizedBox(height: 8.0),
          Text(label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
        ],
      ),
    );
  }
}
