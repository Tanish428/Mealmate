import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/analytics_model.dart';
import '../../data/repos/analytics_repo.dart';
import '../../data/repos/mess_repo.dart';

/// State management controller for live operational precision, financial waste, and surplus analytics.
class AnalyticsController extends ChangeNotifier {
  final AnalyticsRepository _analyticsRepo;
  final MessRepository _messRepo;

  AnalyticsModel? _analytics;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedTimeframe = 'This Month';

  String _messId = '';
  String _messName = 'Your Mess';
  int _costPerMeal = 50;

  /// Available timeframe filters.
  static const List<String> availableTimeframes = [
    'This Week',
    'This Month',
    'All Time',
  ];

  AnalyticsController({
    AnalyticsRepository? analyticsRepo,
    MessRepository? messRepo,
    bool autoLoad = true,
  })  : _analyticsRepo = analyticsRepo ?? AnalyticsRepository(),
        _messRepo = messRepo ?? MessRepository() {
    if (autoLoad) {
      loadAnalytics();
    }
  }

  /// Currently selected timeframe.
  String get selectedTimeframe => _selectedTimeframe;

  /// Exposes current immutable [AnalyticsModel] state.
  AnalyticsModel? get analytics => _analytics;

  /// Loading state indicator during asynchronous data fetching.
  bool get isLoading => _isLoading;

  /// Error message if data retrieval fails.
  String? get errorMessage => _errorMessage;

  /// Active mess identifier.
  String get messId => _messId;

  /// Active mess display name.
  String get messName => _messName;

  /// Baseline cost per meal (INR) configured in mess settings.
  int get costPerMeal => _costPerMeal;

  /// Returns true if at least one meal prep session has been logged in this timeframe.
  bool get hasRecordedData => (_analytics?.totalMealSessions ?? 0) > 0;

  /// Sets the active timeframe and recomputes operational metrics dynamically.
  Future<void> setTimeframe(String timeframe) async {
    if (_selectedTimeframe == timeframe && _analytics != null) return;
    _selectedTimeframe = timeframe;
    await loadAnalytics();
  }

  /// Fetches live analytics data from Supabase across prep records, skips, and donations.
  Future<void> loadAnalytics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_messId.isEmpty) {
        final messDetails = await _messRepo.getOwnerMessDetails();
        if (messDetails != null) {
          _messId = messDetails['id']?.toString() ?? '';
          _messName = messDetails['mess_name']?.toString() ?? 'Your Mess';
          final cpm = messDetails['cost_per_meal'];
          if (cpm is num) {
            _costPerMeal = cpm.toInt();
          }
        }
      }

      if (_messId.isNotEmpty) {
        _analytics = await _analyticsRepo.getAnalytics(
          messId: _messId,
          timeframe: _selectedTimeframe,
          costPerMeal: _costPerMeal,
        );
      } else {
        _errorMessage = 'No mess facility found for current owner account.';
      }
    } catch (e) {
      _errorMessage = 'Failed to load live analytics: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Generates a comprehensive executive audit text summary for mess managers,
  /// hostel wardens, or campus administrators.
  String generateAuditSummary() {
    final a = _analytics;
    final now = DateFormat('EEE, MMM dd, yyyy • h:mm a').format(DateTime.now());
    final currency = NumberFormat('#,##,###');

    final savings = a?.totalCostSavedValue ?? 0;
    final loss = a?.totalCostLost ?? 0;
    final netRoi = savings - loss;

    return '''
=====================================================
MEALMATE™ EXECUTIVE FOOD WASTE & FINANCIAL ROI AUDIT
=====================================================
Facility: $_messName
Reporting Period: $_selectedTimeframe
Generated: $now

1. FINANCIAL ROI & COST SAVINGS
-----------------------------------------------------
• Cost Baseline per Plate: ₹$_costPerMeal
• Net Financial Savings: ₹${currency.format(savings)} (Prevented Ghost Meals)
• Financial Waste Incurred: ₹${currency.format(loss)} (Discarded Food)
• Net Operational Benefit: ₹${currency.format(netRoi)}

2. PORTION PRECISION & KITCHEN OPERATIONS
-----------------------------------------------------
• Total Logged Meal Sessions: ${a?.totalMealSessions ?? 0}
• Planned Headcount Targets: ${a?.totalTargetPortions ?? 0} portions
• Actual Kitchen Cooked: ${a?.totalPreparedPortions ?? 0} portions
• Actual Portions Served: ${a?.totalServedPortions ?? 0} portions
• Kitchen Preparation Accuracy: ${a?.prepAccuracyPercentage ?? 100}%
• Ghost Meals Prevented (Opt-outs): ${a?.ghostMealsPrevented ?? 0} meals

3. SURPLUS RECOVERY & ESG SUSTAINABILITY
-----------------------------------------------------
• Surplus Portions Donated to NGOs: ${a?.totalDonatedPortions ?? 0} portions
• Portions Discarded: ${a?.totalDiscardedPortions ?? 0} portions
• Surplus Food Recovery Rate: ${a?.surplusRecoveryRate ?? 100}%
• Total Food Diverted from Landfill: ${a?.totalFoodSaved ?? '0 kg'}
• Est. CO2 Emissions Avoided: ${((a?.totalDonatedPortions ?? 0) * 1.8).toStringAsFixed(1)} kg CO2e
• Est. Water Conserved: ${((a?.totalDonatedPortions ?? 0) * 250).toStringAsFixed(0)} Liters

4. OPERATIONAL PATTERNS & INSIGHTS
-----------------------------------------------------
• Most Skipped Meal Type: ${a?.mostSkippedMeal ?? 'None'}
• Peak Service Demand Session: ${a?.busiestDay ?? 'N/A'}
• Average Daily Opt-outs: ${a?.averageOptOuts ?? '0'}

Certified by MealMate Commercial Mess Management Suite
=====================================================
'''.trim();
  }

  /// Exports metrics in CSV spreadsheet format.
  String generateCsvReport() {
    final a = _analytics;
    final savings = a?.totalCostSavedValue ?? 0;
    final loss = a?.totalCostLost ?? 0;
    final netBenefit = savings - loss;

    return '''
Metric,Value,Unit
Facility,"$_messName",
Reporting Period,"$_selectedTimeframe",
Cost Baseline Per Meal,$_costPerMeal,INR
Net Financial Savings,$savings,INR
Financial Waste Loss,$loss,INR
Net Operational Benefit,$netBenefit,INR
Prep Accuracy Percentage,${a?.prepAccuracyPercentage ?? 100},%
Ghost Meals Prevented,${a?.ghostMealsPrevented ?? 0},meals
Surplus Recovery Rate,${a?.surplusRecoveryRate ?? 100},%
Total Portions Target,${a?.totalTargetPortions ?? 0},portions
Total Portions Prepared,${a?.totalPreparedPortions ?? 0},portions
Total Portions Served,${a?.totalServedPortions ?? 0},portions
Total Portions Donated,${a?.totalDonatedPortions ?? 0},portions
Total Portions Discarded,${a?.totalDiscardedPortions ?? 0},portions
Food Diverted From Landfill,"${a?.totalFoodSaved ?? '0 kg'}",
Most Skipped Meal,"${a?.mostSkippedMeal ?? 'Dinner'}",
Busiest Day,"${a?.busiestDay ?? 'Sunday'}",
Average Opt Outs,"${a?.averageOptOuts ?? '0'}",
'''.trim();
  }
}
