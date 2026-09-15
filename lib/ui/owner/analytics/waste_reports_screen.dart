import 'package:flutter/material.dart';
import '../../common/stat_card.dart';
import '../../../data/repos/mock/mock_ui_repos.dart';

class ChartData {
  final String label;
  final double standardCapacity;
  final double actualPrepared;

  const ChartData({
    required this.label,
    required this.standardCapacity,
    required this.actualPrepared,
  });
}

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
  String _selectedTimeframe = "This Month";
  
  final List<String> _timeframes = ["This Week", "This Month", "All Time"];
  final analytics = MockUIRepos.analytics;

  late final List<ChartData> _chartData = [
    ChartData(label: "Week 1", standardCapacity: analytics.weeklyStandardCapacity[0], actualPrepared: analytics.weeklyActualPrep[0]),
    ChartData(label: "Week 2", standardCapacity: analytics.weeklyStandardCapacity[1], actualPrepared: analytics.weeklyActualPrep[1]),
    ChartData(label: "Week 3", standardCapacity: analytics.weeklyStandardCapacity[2], actualPrepared: analytics.weeklyActualPrep[2]),
    ChartData(label: "Week 4", standardCapacity: analytics.weeklyStandardCapacity[3], actualPrepared: analytics.weeklyActualPrep[3]),
  ];

  late final List<InsightData> _insights = [
    InsightData(
      icon: Icons.group_off,
      title: "Average Daily Opt-outs",
      trailingText: analytics.averageOptOuts,
    ),
    InsightData(
      icon: Icons.restaurant_menu,
      title: "Most Skipped Meal",
      trailingText: analytics.mostSkippedMeal,
    ),
    InsightData(
      icon: Icons.calendar_today,
      title: "Busiest Day",
      trailingText: analytics.busiestDay,
    ),
  ];

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
              const SizedBox(height: 24),
              _buildTimeframeSelector(),
              const SizedBox(height: 24),
              _buildHeroMetricsRow(context),
              const SizedBox(height: 24),
              _buildTrendChartCard(context),
              const SizedBox(height: 24),
              _buildKeyInsightsSection(context),
              const SizedBox(height: 24),
              _buildEcoImpactBanner(context),
              const SizedBox(height: 24),
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

  Widget _buildTimeframeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: _timeframes.map((timeframe) {
          final isSelected = timeframe == _selectedTimeframe;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTimeframe = timeframe;
                });
              },
              child: Container(
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

  Widget _buildHeroMetricsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            metric: analytics.totalFoodSaved,
            title: "Food Saved",
            subtitle: "This month",
            icon: Icons.eco,
            iconColor: Colors.green.shade800,
            iconBackgroundColor: Colors.green.shade50,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            metric: analytics.totalCostSaved,
            title: "Cost Saved",
            subtitle: "This month",
            icon: Icons.account_balance_wallet,
            iconColor: Colors.red.shade700,
            iconBackgroundColor: Colors.red.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendChartCard(BuildContext context) {
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
                      "Standard capacity vs actual preparation",
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
          _CustomBarChart(data: _chartData),
        ],
      ),
    );
  }

  Widget _buildKeyInsightsSection(BuildContext context) {
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
          ..._insights.map((insight) => Padding(
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

  Widget _buildEcoImpactBanner(BuildContext context) {
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
                  TextSpan(text: analytics.totalFoodSaved, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: " of food this month. That's about "),
                  const TextSpan(text: "350 kg", style: TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: " CO2 emissions avoided."),
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
  final List<ChartData> data;
  const _CustomBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY = 60.0;
    
    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Y-axis labels
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildYLabel("60"),
              _buildYLabel("40"),
              _buildYLabel("20"),
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
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
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
    final heightRatio = value / maxY;
    // max height for bars is roughly 150 (200 total - 20 for labels - padding)
    final barHeight = 150 * heightRatio;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value.toInt().toString(),
          style: TextStyle(fontSize: 9, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          width: 16,
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
