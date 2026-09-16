import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/analytics_model.dart';
import '../../logic/controllers/analytics_controller.dart';
import '../common/stat_card.dart';

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
  const WasteReportsScreen({super.key});

  @override
  State<WasteReportsScreen> createState() => _WasteReportsScreenState();
}

class _WasteReportsScreenState extends State<WasteReportsScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnalyticsController(),
      child: Consumer<AnalyticsController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFFDFBF7),
            body: SafeArea(
              child: controller.isLoading && controller.analytics == null
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 24),
                          _buildTimeframeSelector(context, controller),
                          const SizedBox(height: 24),
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
          );
        },
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, color: Colors.red.shade700),
          ),
        ),
        const SizedBox(width: 16),
        Column(
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
            const SizedBox(height: 4),
            Text(
              "See how MealMate reduces waste",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
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
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red.shade700 : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: Text(
                  timeframe,
                  style: TextStyle(
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

  Widget _buildHeroMetricsRow(BuildContext context, AnalyticsController controller) {
    final analyticsData = controller.analytics;
    final String prepAccuracy = analyticsData != null
        ? "${analyticsData.prepAccuracyPercentage.toStringAsFixed(1)}%"
        : "96.4%";
    final String ghostMeals = analyticsData != null
        ? "${analyticsData.ghostMealsPrevented}"
        : "362";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: StatCard(
            metric: prepAccuracy,
            title: "Prep Accuracy",
            subtitle: "You are cooking almost exactly what is needed.",
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                      Text("Standard Capacity",
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
                      Text("Actual Prepared",
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
        trailingText: analyticsData?.averageOptOuts ?? "8 members / meal",
      ),
      InsightData(
        icon: Icons.restaurant_menu,
        title: "Most Skipped Meal",
        trailingText: analyticsData?.mostSkippedMeal ?? "Dinner",
      ),
      InsightData(
        icon: Icons.calendar_today,
        title: "Busiest Day",
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                    text: analyticsData?.totalFoodSaved ?? "128 kg",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: " of food $timeframePeriod."),
                ],
              ),
            ),
          ),
        ],
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
