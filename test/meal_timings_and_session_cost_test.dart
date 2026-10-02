import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealmate/data/models/meal_prep_record_model.dart';
import 'package:mealmate/data/repos/mess_repo.dart';
import 'package:mealmate/ui/owner/meal_timings_screen.dart';

class MockMessRepository implements MessRepository {
  final Map<String, dynamic> data;
  Map<String, dynamic>? updatedTimings;

  MockMessRepository({Map<String, dynamic>? initialData})
      : data = initialData ?? {
          'id': 'mess-123',
          'mess_name': 'Umiyaji',
          'served_meals': ['breakfast', 'dinner'],
          'meal_timings': {
            'breakfast': {'start': '06:45', 'end': '09:00', 'cutoff': '05:00'},
            'dinner': {'start': '19:00', 'end': '20:30', 'cutoff': '16:00'},
          },
        };

  @override
  Future<Map<String, dynamic>?> getOwnerMessDetails() async => data;

  @override
  Future<void> updateMealTimings({required String messId, required Map<String, dynamic> timings}) async {
    updatedTimings = timings;
  }

  @override
  Future<String> createMess({required String messName, required List<String> servedMeals}) async => 'id';

  @override
  Future<void> joinMess({required String inviteCode}) async {}

  @override
  Future<String?> getOwnerMessName() async => 'Umiyaji';

  @override
  Future<void> updateMessName({required String newName}) async {}

  @override
  Future<void> updateCostPerMeal({required String messId, required int costPerMeal}) async {}

  @override
  Future<List<Map<String, dynamic>>> getMessMembers({String? messId}) async => [];
}

void main() {
  group('Option 2: Per-Session Daily Cost Model Tests', () {
    test('MealPrepRecordModel serializes and deserializes costPerMeal', () {
      final model = MealPrepRecordModel(
        id: 'rec-1',
        messId: 'mess-1',
        prepDate: DateTime(2026, 10, 2),
        mealType: 'dinner',
        preparedPortions: 120,
        servedPortions: 100,
        costPerMeal: 65,
      );

      final json = model.toJson();
      expect(json['cost_per_meal'], 65);

      final fromJson = MealPrepRecordModel.fromJson({
        'id': 'rec-1',
        'mess_id': 'mess-1',
        'prep_date': '2026-10-02',
        'meal_type': 'dinner',
        'prepared_portions': 120,
        'served_portions': 100,
        'cost_per_meal': 65,
      });

      expect(fromJson.costPerMeal, 65);
    });
  });

  group('MealTimingsScreen Widget Tests', () {
    testWidgets('Renders header and cards for active served meals (Breakfast & Dinner)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MealTimingsScreen(
            messRepo: MockMessRepository(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Screen Header
      expect(find.text("Meal Timings & Cutoffs"), findsOneWidget);

      // Verify Breakfast & Dinner cards
      expect(find.text("Breakfast"), findsOneWidget);
      expect(find.text("Dinner"), findsOneWidget);

      // Verify Row Labels
      expect(find.text("Serving Start Time"), findsNWidgets(2));
      expect(find.text("Serving End Time"), findsNWidgets(2));
      expect(find.text("Member Opt-Out Cutoff Time"), findsNWidgets(2));

      // Verify Time values matching Image 2
      expect(find.text("6:45 AM"), findsOneWidget);
      expect(find.text("9:00 AM"), findsOneWidget);
      expect(find.text("5:00 AM"), findsOneWidget);
      expect(find.text("7:00 PM"), findsOneWidget);
      expect(find.text("8:30 PM"), findsOneWidget);
      expect(find.text("4:00 PM"), findsOneWidget);

      // Verify Save Changes button
      expect(find.text("Save Changes"), findsOneWidget);
    });
  });
}
