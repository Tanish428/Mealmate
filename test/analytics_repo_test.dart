import 'package:flutter_test/flutter_test.dart';
import 'package:mealmate/data/models/analytics_model.dart';
import 'package:mealmate/logic/controllers/analytics_controller.dart';
import 'package:mealmate/data/repos/analytics_repo.dart';
import 'package:mealmate/data/repos/mess_repo.dart';

class MockAnalyticsRepo extends AnalyticsRepository {
  AnalyticsModel modelToReturn;

  MockAnalyticsRepo(this.modelToReturn);

  @override
  Future<AnalyticsModel> getAnalytics({
    required String messId,
    required String timeframe,
    int costPerMeal = 50,
    int messStandardCapacity = 100,
  }) async {
    return modelToReturn;
  }
}

class MockMessRepo extends MessRepository {
  final Map<String, dynamic> messDetails;

  MockMessRepo(this.messDetails);

  @override
  Future<Map<String, dynamic>?> getOwnerMessDetails() async {
    return messDetails;
  }
}

void main() {
  group('AnalyticsModel Unit Tests', () {
    test('Correctly computes financial ROI and default metrics', () {
      const model = AnalyticsModel(
        prepAccuracyPercentage: 95.5,
        ghostMealsPrevented: 120,
        mostSkippedMeal: 'Dinner',
        busiestDay: 'Sunday (Lunch)',
        timeframe: 'This Month',
        totalFoodSaved: '42 kg',
        totalCostSaved: '₹6,000',
        totalCostSavedValue: 6000,
        totalCostLost: 1500,
        surplusRecoveryRate: 85.0,
        totalTargetPortions: 1000,
        totalPreparedPortions: 980,
        totalServedPortions: 950,
        totalDiscardedPortions: 30,
        totalDonatedPortions: 200,
        totalMealSessions: 30,
        averageOptOuts: '4 members / day',
      );

      expect(model.prepAccuracyPercentage, 95.5);
      expect(model.ghostMealsPrevented, 120);
      expect(model.totalCostSavedValue, 6000);
      expect(model.totalCostLost, 1500);
      expect(model.surplusRecoveryRate, 85.0);
      expect(model.totalMealSessions, 30);
    });

    test('CopyWith updates financial fields correctly', () {
      const initial = AnalyticsModel(
        prepAccuracyPercentage: 90.0,
        ghostMealsPrevented: 50,
        mostSkippedMeal: 'Lunch',
        busiestDay: 'Friday',
      );

      final updated = initial.copyWith(
        totalCostSavedValue: 5000,
        totalCostLost: 500,
        surplusRecoveryRate: 90.0,
      );

      expect(updated.totalCostSavedValue, 5000);
      expect(updated.totalCostLost, 500);
      expect(updated.surplusRecoveryRate, 90.0);
      expect(updated.ghostMealsPrevented, 50);
    });
  });

  group('AnalyticsController Audit & Report Generation Tests', () {
    test('Generates executive audit report with accurate financial ROI and ESG numbers', () async {
      const model = AnalyticsModel(
        prepAccuracyPercentage: 97.2,
        ghostMealsPrevented: 240,
        mostSkippedMeal: 'Dinner',
        busiestDay: 'Sunday (Lunch)',
        timeframe: 'This Month',
        totalFoodSaved: '84 kg',
        totalCostSaved: '₹12,000',
        totalCostSavedValue: 12000,
        totalCostLost: 1250,
        surplusRecoveryRate: 88.5,
        totalTargetPortions: 2500,
        totalPreparedPortions: 2480,
        totalServedPortions: 2400,
        totalDiscardedPortions: 25,
        totalDonatedPortions: 190,
        totalMealSessions: 60,
        averageOptOuts: '8 members / day',
      );

      final controller = AnalyticsController(
        analyticsRepo: MockAnalyticsRepo(model),
        messRepo: MockMessRepo({
          'id': 'mess-123',
          'mess_name': 'Royal Hostel Mess',
          'cost_per_meal': 50,
        }),
        autoLoad: false,
      );

      await controller.loadAnalytics();

      expect(controller.hasRecordedData, isTrue);
      expect(controller.messName, 'Royal Hostel Mess');
      expect(controller.costPerMeal, 50);

      final auditSummary = controller.generateAuditSummary();
      expect(auditSummary, contains('MEALMATE™ EXECUTIVE FOOD WASTE & FINANCIAL ROI AUDIT'));
      expect(auditSummary, contains('Facility: Royal Hostel Mess'));
      expect(auditSummary, contains('Cost Baseline per Plate: ₹50'));
      expect(auditSummary, contains('Net Financial Savings: ₹12,000'));
      expect(auditSummary, contains('Financial Waste Incurred: ₹1,250'));
      expect(auditSummary, contains('Net Operational Benefit: ₹10,750'));
      expect(auditSummary, contains('Surplus Food Recovery Rate: 88.5%'));

      final csvReport = controller.generateCsvReport();
      expect(csvReport, contains('Cost Baseline Per Meal,50,INR'));
      expect(csvReport, contains('Net Financial Savings,12000,INR'));
      expect(csvReport, contains('Financial Waste Loss,1250,INR'));
      expect(csvReport, contains('Net Operational Benefit,10750,INR'));
    });
  });
}
