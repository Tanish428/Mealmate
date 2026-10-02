import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealmate/data/models/analytics_model.dart';
import 'package:mealmate/data/repos/analytics_repo.dart';
import 'package:mealmate/data/repos/mess_repo.dart';
import 'package:mealmate/logic/controllers/analytics_controller.dart';
import 'package:mealmate/ui/owner/waste_reports_screen.dart';

class MockAnalyticsRepoForWidget extends AnalyticsRepository {
  final AnalyticsModel model;
  MockAnalyticsRepoForWidget(this.model);

  @override
  Future<AnalyticsModel> getAnalytics({
    required String messId,
    required String timeframe,
    int costPerMeal = 50,
    int messStandardCapacity = 100,
  }) async {
    return model;
  }
}

class MockMessRepoForWidget extends MessRepository {
  @override
  Future<Map<String, dynamic>?> getOwnerMessDetails() async {
    return {
      'id': 'mess-widget-1',
      'mess_name': 'University Royal Mess',
      'cost_per_meal': 50,
    };
  }
}

void main() {
  testWidgets('WasteReportsScreen renders financial ROI, metrics, and audit export', (WidgetTester tester) async {
    const testAnalytics = AnalyticsModel(
      prepAccuracyPercentage: 96.4,
      ghostMealsPrevented: 362,
      mostSkippedMeal: 'Dinner',
      busiestDay: 'Sunday (Lunch)',
      timeframe: 'This Month',
      totalFoodSaved: '128 kg',
      totalCostSaved: '₹18,100',
      totalCostSavedValue: 18100,
      totalCostLost: 1250,
      surplusRecoveryRate: 92.5,
      totalTargetPortions: 2500,
      totalPreparedPortions: 2480,
      totalServedPortions: 2400,
      totalDiscardedPortions: 25,
      totalDonatedPortions: 310,
      totalMealSessions: 60,
      averageOptOuts: '8 members / meal',
    );

    final controller = AnalyticsController(
      analyticsRepo: MockAnalyticsRepoForWidget(testAnalytics),
      messRepo: MockMessRepoForWidget(),
      autoLoad: false,
    );
    await controller.loadAnalytics();

    await tester.pumpWidget(
      MaterialApp(
        home: WasteReportsScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header elements
    expect(
      find.byWidgetPredicate((widget) =>
          widget is RichText && widget.text.toPlainText().contains('Impact & Analytics')),
      findsOneWidget,
    );
    expect(find.text("Export Audit"), findsOneWidget);

    // Verify timeframe filters
    expect(find.text("This Week"), findsOneWidget);
    expect(find.text("This Month"), findsOneWidget);
    expect(find.text("All Time"), findsOneWidget);

    // Verify Financial ROI cards
    expect(find.text("Financial ROI & Savings"), findsOneWidget);
    expect(find.text("Net Money Saved"), findsOneWidget);
    expect(find.text("₹18,100"), findsOneWidget);
    expect(find.text("Food Waste Loss"), findsOneWidget);
    expect(find.text("Surplus Recovery Rate"), findsOneWidget);
    expect(find.text("92.5%"), findsOneWidget);

    // Verify Hero Metrics
    expect(find.text("Prep Accuracy"), findsOneWidget);
    expect(find.text("96.4%"), findsOneWidget);
    expect(find.text("Ghost Meals Prevented"), findsOneWidget);
    expect(find.text("362"), findsOneWidget);

    // Tap Export Audit button to verify modal opens
    await tester.tap(find.text("Export Audit"));
    await tester.pumpAndSettle();

    expect(find.text("Executive Audit Report"), findsOneWidget);
    expect(find.text("Copy CSV"), findsOneWidget);
    expect(find.text("Copy Summary"), findsOneWidget);
  });
}
