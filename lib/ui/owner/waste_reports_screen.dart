import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/analytics_model.dart';
import '../../logic/controllers/analytics_controller.dart';
import '../common/stat_card.dart';
import 'surplus_allocation_screen.dart';

class InsightData {
  final IconData icon;
  final String title;
  final String trailingText;

  const InsightData({
    required this.icon,
    required this.title,
    required this.trailingText,
  });
}

class WasteReportsScreen extends StatefulWidget {
  final AnalyticsController? controller;

  const WasteReportsScreen({super.key, this.controller});

  @override
  State<WasteReportsScreen> createState() => _WasteReportsScreenState();
}

class _WasteReportsScreenState extends State<WasteReportsScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.controller != null) {
      return ChangeNotifierProvider<AnalyticsController>.value(
        value: widget.controller!,
        child: const _WasteReportsView(),
      );
    }

    return ChangeNotifierProvider<AnalyticsController>(
      create: (_) => AnalyticsController(),
      child: const _WasteReportsView(),
    );
  }
}

class _WasteReportsView extends StatelessWidget {
  const _WasteReportsView();

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsController>(
      builder: (context, controller, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFDFBF7),
          body: SafeArea(
            child: controller.isLoading && controller.analytics == null
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC0392B)),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: controller.loadAnalytics,
                    color: const Color(0xFFC0392B),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context, controller),
                          const SizedBox(height: 20),
                          _buildTimeframeSelector(context, controller),
                          const SizedBox(height: 20),

                          if (!controller.hasRecordedData && !controller.isLoading) ...[
                            _buildEmptyStateCard(context),
                            const SizedBox(height: 20),
                          ],

                          _buildFinancialRoiCard(context, controller),
                          const SizedBox(height: 20),
                          _buildHeroMetricsRow(context, controller),
                          const SizedBox(height: 24),
                          _buildTrendChartCard(context, controller),
                          const SizedBox(height: 24),
                          _buildKeyInsightsSection(context, controller),
                          const SizedBox(height: 24),
                          _buildEcoImpactBanner(context, controller),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AnalyticsController controller) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.maybePop(context),
          customBorder: const CircleBorder(),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, color: Colors.red.shade700),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  children: [
                    const TextSpan(text: "Impact & ", style: TextStyle(color: Colors.black)),
                    TextSpan(text: "Analytics", style: TextStyle(color: Colors.red.shade700)),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Financial ROI & Food Waste Audit",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () => _showAuditReportDialog(context, controller),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.description_outlined, size: 16, color: Colors.red.shade700),
                const SizedBox(width: 4),
                Text(
                  "Export Audit",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeframeSelector(BuildContext context, AnalyticsController controller) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: AnalyticsController.availableTimeframes.map((timeframe) {
          final isSelected = timeframe == controller.selectedTimeframe;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                controller.setTimeframe(timeframe);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red.shade700 : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: Text(
                  timeframe,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyStateCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFD0DCE5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF2C5E8A), size: 28),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "No Meal Prep Recorded Yet",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E3A5F)),
                ),
                const SizedBox(height: 2.0),
                Text(
                  "Log actual kitchen portions in Surplus Management to track real ROI and waste variance.",
                  style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SurplusAllocationScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C5E8A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            child: const Text("Log Meal"),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRoiCard(BuildContext context, AnalyticsController controller) {
    final a = controller.analytics;
    final currency = NumberFormat('#,##,###');
    final savings = a != null ? a.totalCostSaved : '₹0';
    final loss = a != null ? '₹${currency.format(a.totalCostLost)}' : '₹0';
    final recovery = a != null ? '${a.surplusRecoveryRate.toStringAsFixed(1)}%' : '100%';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Financial ROI & Savings",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "@ ₹${controller.costPerMeal}/meal",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Savings Container
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.savings_outlined, size: 16, color: Colors.green.shade800),
                          const SizedBox(width: 4),
                          Text(
                            "Net Money Saved",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        savings,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.green.shade900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Prevented ghost meals",
                        style: TextStyle(fontSize: 10, color: Colors.green.shade800),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Loss Container
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.trending_down, size: 16, color: Colors.orange.shade900),
                          const SizedBox(width: 4),
                          Text(
                            "Food Waste Loss",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loss,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Discarded unserved food",
                        style: TextStyle(fontSize: 10, color: Colors.orange.shade800),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Surplus Recovery Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.volunteer_activism_outlined, size: 16, color: Colors.green.shade700),
                    const SizedBox(width: 6),
                    const Text(
                      "Surplus Recovery Rate",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Text(
                  recovery,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMetricsRow(BuildContext context, AnalyticsController controller) {
    final analyticsData = controller.analytics;
    final String prepAccuracy = analyticsData != null
        ? "${analyticsData.prepAccuracyPercentage.toStringAsFixed(1)}%"
        : "100%";
    final String ghostMeals = analyticsData != null
        ? "${analyticsData.ghostMealsPrevented}"
        : "0";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: StatCard(
            metric: prepAccuracy,
            title: "Prep Accuracy",
            subtitle: "Actual cooked vs planned portions.",
            icon: Icons.track_changes,
            iconColor: Colors.red.shade700,
            iconBackgroundColor: Colors.red.shade50,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            metric: ghostMeals,
            title: "Ghost Meals Prevented",
            subtitle: "Members opted out before cutoff.",
            icon: Icons.no_meals,
            iconColor: Colors.orange.shade800,
            iconBackgroundColor: Colors.orange.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendChartCard(BuildContext context, AnalyticsController controller) {
    final trendData = controller.analytics?.weeklyTrend ?? [];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Food Preparation Trend",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Standard capacity vs actual preparation (${controller.selectedTimeframe.toLowerCase()})",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text("Target Capacity",
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text("Actual Cooked",
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          _CustomBarChart(data: trendData),
        ],
      ),
    );
  }

  Widget _buildKeyInsightsSection(BuildContext context, AnalyticsController controller) {
    final analyticsData = controller.analytics;
    final insights = [
      InsightData(
        icon: Icons.group_off,
        title: "Average Daily Opt-outs",
        trailingText: analyticsData?.averageOptOuts ?? "0 members / day",
      ),
      InsightData(
        icon: Icons.restaurant_menu,
        title: "Most Skipped Meal",
        trailingText: analyticsData?.mostSkippedMeal ?? "Dinner",
      ),
      InsightData(
        icon: Icons.calendar_today,
        title: "Peak Service Demand",
        trailingText: analyticsData?.busiestDay ?? "Sunday (Lunch)",
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            "Key Insights",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(insight.icon, color: Colors.red.shade700, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        insight.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    Text(
                      insight.trailingText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildEcoImpactBanner(BuildContext context, AnalyticsController controller) {
    final analyticsData = controller.analytics;
    final timeframePeriod = controller.selectedTimeframe == "This Week"
        ? "this week"
        : controller.selectedTimeframe == "All Time"
            ? "overall"
            : "this month";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.eco, color: Colors.green.shade800),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.green.shade900,
                    ),
                children: [
                  const TextSpan(text: "Great job! ", style: TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: "You saved approximately "),
                  TextSpan(
                    text: analyticsData?.totalFoodSaved ?? "0 kg",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: " of food $timeframePeriod from landfill."),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAuditReportDialog(BuildContext context, AnalyticsController controller) {
    final auditText = controller.generateAuditSummary();
    final csvText = controller.generateCsvReport();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 650),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assessment_outlined, color: Colors.red.shade700),
                      const SizedBox(width: 8.0),
                      const Text(
                        "Executive Audit Report",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      auditText,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11, height: 1.4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: csvText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('CSV report copied to clipboard!')),
                        );
                      },
                      icon: const Icon(Icons.table_chart_outlined, size: 16),
                      label: const Text("Copy CSV", style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: auditText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Executive Audit Summary copied to clipboard!')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text("Copy Summary", style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomBarChart extends StatelessWidget {
  final List<WeeklyTrendPoint> data;
  const _CustomBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("No trend data available")),
      );
    }

    double maxVal = 0;
    for (final item in data) {
      if (item.standardCapacity > maxVal) maxVal = item.standardCapacity;
      if (item.actualPrepared > maxVal) maxVal = item.actualPrepared;
    }
    if (maxVal == 0) maxVal = 100;
    final double maxY = ((maxVal / 20).ceil() * 20).toDouble();
    final double step = maxY / 3;

    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Y-axis labels
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildYLabel(maxY.toInt().toString()),
              _buildYLabel((step * 2).toInt().toString()),
              _buildYLabel((step).toInt().toString()),
              _buildYLabel("0"),
              const SizedBox(height: 20), // Spacer for X-axis labels
            ],
          ),
          const SizedBox(width: 8),
          // Chart area
          Expanded(
            child: Stack(
              children: [
                // Horizontal grid lines
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildGridLine(),
                    _buildGridLine(),
                    _buildGridLine(),
                    _buildGridLine(),
                    const SizedBox(height: 20),
                  ],
                ),
                // Bars
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: data.map((d) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildBar(d.standardCapacity, maxY, Colors.grey.shade300),
                            const SizedBox(width: 4),
                            _buildBar(d.actualPrepared, maxY, Colors.red.shade700),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          d.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
    );
  }

  Widget _buildGridLine() {
    return Expanded(
      flex: 0,
      child: Container(
        height: 1,
        color: Colors.grey.shade200,
      ),
    );
  }

  Widget _buildBar(double value, double maxY, Color color) {
    final heightRatio = (value / maxY).clamp(0.0, 1.0);
    final barHeight = 135 * heightRatio;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value.toInt().toString(),
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 14,
          height: barHeight,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
      ],
    );
  }
}
