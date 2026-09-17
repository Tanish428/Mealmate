import 'package:flutter/material.dart';
import '../../data/models/analytics_model.dart';

/// State management controller for operational precision analytics.
class AnalyticsController extends ChangeNotifier {
  AnalyticsModel? _analytics;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedTimeframe = 'This Month';

  /// Available timeframe filters.
  static const List<String> availableTimeframes = [
    'This Week',
    'This Month',
    'All Time',
  ];

  /// Currently selected timeframe.
  String get selectedTimeframe => _selectedTimeframe;

  /// Exposes current immutable [AnalyticsModel] state.
  AnalyticsModel? get analytics => _analytics;

  /// Loading state indicator during asynchronous data fetching.
  bool get isLoading => _isLoading;

  /// Error message if data retrieval fails.
  String? get errorMessage => _errorMessage;

  AnalyticsController({bool autoLoad = true}) {
    if (autoLoad) {
      loadAnalytics();
    }
  }

  /// Sets the active timeframe and recomputes operational metrics dynamically.
  Future<void> setTimeframe(String timeframe) async {
    if (_selectedTimeframe == timeframe && _analytics != null) return;
    _selectedTimeframe = timeframe;
    await loadAnalytics();
  }

  /// Simulates fetching analytics data and calculates operational precision metrics
  /// tailored to the selected timeframe.
  Future<void> loadAnalytics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      
      // Simulate light asynchronous network latency
      await Future.delayed(const Duration(milliseconds: 200));

      _analytics = _generateAnalyticsForTimeframe(_selectedTimeframe);
    } catch (e) {
      _errorMessage = 'Failed to load analytics: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Factory computing data models and trend points per timeframe.
  AnalyticsModel _generateAnalyticsForTimeframe(String timeframe) {
    switch (timeframe) {
      case 'This Week':
        // 7-day breakdown (Mon-Sun)
        const int totalPlanned = 700;
        const int unusedSurplus = 36;
        final double accuracy =
            ((totalPlanned - unusedSurplus) / totalPlanned) * 100.0;

        return AnalyticsModel(
          timeframe: 'This Week',
          prepAccuracyPercentage: double.parse(accuracy.toStringAsFixed(1)), // ~94.9%
          ghostMealsPrevented: 84,
          mostSkippedMeal: 'Dinner',
          busiestDay: 'Thursday (Dinner)',
          totalFoodSaved: '32 kg',
          totalCostSaved: '₹3,800',
          averageOptOuts: '12 members / day',
          weeklyTrend: const [
            WeeklyTrendPoint(label: 'Mon', standardCapacity: 100, actualPrepared: 88),
            WeeklyTrendPoint(label: 'Tue', standardCapacity: 100, actualPrepared: 92),
            WeeklyTrendPoint(label: 'Wed', standardCapacity: 100, actualPrepared: 85),
            WeeklyTrendPoint(label: 'Thu', standardCapacity: 100, actualPrepared: 96),
            WeeklyTrendPoint(label: 'Fri', standardCapacity: 100, actualPrepared: 82),
            WeeklyTrendPoint(label: 'Sat', standardCapacity: 100, actualPrepared: 78),
            WeeklyTrendPoint(label: 'Sun', standardCapacity: 100, actualPrepared: 84),
          ],
        );

      case 'All Time':
        // Multi-month aggregated breakdown
        const int totalPlanned = 15000;
        const int unusedSurplus = 630;
        final double accuracy =
            ((totalPlanned - unusedSurplus) / totalPlanned) * 100.0;

        return AnalyticsModel(
          timeframe: 'All Time',
          prepAccuracyPercentage: double.parse(accuracy.toStringAsFixed(1)), // 95.8%
          ghostMealsPrevented: 2140,
          mostSkippedMeal: 'Dinner',
          busiestDay: 'Sunday (Lunch)',
          totalFoodSaved: '840 kg',
          totalCostSaved: '₹92,500',
          averageOptOuts: '9 members / meal',
          weeklyTrend: const [
            WeeklyTrendPoint(label: 'Jan', standardCapacity: 100, actualPrepared: 82),
            WeeklyTrendPoint(label: 'Feb', standardCapacity: 100, actualPrepared: 80),
            WeeklyTrendPoint(label: 'Mar', standardCapacity: 100, actualPrepared: 86),
            WeeklyTrendPoint(label: 'Apr', standardCapacity: 100, actualPrepared: 84),
            WeeklyTrendPoint(label: 'May', standardCapacity: 100, actualPrepared: 88),
            WeeklyTrendPoint(label: 'Jun', standardCapacity: 100, actualPrepared: 85),
          ],
        );

      case 'This Month':
      default:
        // 4-week monthly breakdown
        const int totalPlanned = 2500;
        const int unusedSurplus = 90;
        final double accuracy =
            ((totalPlanned - unusedSurplus) / totalPlanned) * 100.0;

        return AnalyticsModel(
          timeframe: 'This Month',
          prepAccuracyPercentage: double.parse(accuracy.toStringAsFixed(1)), // 96.4%
          ghostMealsPrevented: 362,
          mostSkippedMeal: 'Dinner',
          busiestDay: 'Sunday (Lunch)',
          totalFoodSaved: '128 kg',
          totalCostSaved: '₹14,200',
          averageOptOuts: '8 members / meal',
          weeklyTrend: const [
            WeeklyTrendPoint(label: 'Week 1', standardCapacity: 100, actualPrepared: 85),
            WeeklyTrendPoint(label: 'Week 2', standardCapacity: 100, actualPrepared: 78),
            WeeklyTrendPoint(label: 'Week 3', standardCapacity: 100, actualPrepared: 82),
            WeeklyTrendPoint(label: 'Week 4', standardCapacity: 100, actualPrepared: 80),
          ],
        );
    }
  }
}
