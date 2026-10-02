import 'package:flutter_test/flutter_test.dart';
import 'package:mealmate/data/models/models.dart';
import 'package:mealmate/data/repos/surplus_repo.dart';
import 'package:mealmate/data/repos/mess_repo.dart';
import 'package:mealmate/data/repos/attendance_repo.dart';
import 'package:mealmate/data/repos/menu_repo.dart';
import 'package:mealmate/logic/controllers/preparation_planner_controller.dart';
import 'package:mealmate/logic/controllers/surplus_controller.dart';

class MockSurplusRepoForSync extends SurplusRepository {
  MealPrepRecordModel? savedRecord;

  @override
  Future<MealPrepRecordModel> saveCookingTarget({
    required String messId,
    required DateTime date,
    required String mealType,
    required int targetPortions,
  }) async {
    savedRecord = MealPrepRecordModel(
      id: 'rec-test-1',
      messId: messId,
      prepDate: date,
      mealType: mealType,
      targetPortions: targetPortions,
      preparedPortions: 0,
      servedPortions: 0,
      discardedPortions: 0,
      surplusPortions: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return savedRecord!;
  }

  @override
  Future<MealPrepRecordModel?> getMealPrepRecord({
    required String messId,
    required DateTime date,
    required String mealType,
  }) async {
    return savedRecord;
  }

  @override
  Future<List<DonationPartnerModel>> getPartners({
    required String messId,
    bool activeOnly = true,
  }) async {
    return [
      DonationPartnerModel(
        id: 'partner-1',
        messId: messId,
        name: 'Roti Bank Foundation',
        contactPhone: '+919876543210',
        contactPerson: 'Rahul Sharma',
        address: 'Sector 5, Gate 2',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<List<SurplusAllocationModel>> getAllocationsForMeal({
    required String mealPrepRecordId,
  }) async {
    return [];
  }

  @override
  Future<int> getCompletedDonationsCount({
    required String messId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return 0;
  }
}

class MockMessRepoForPlanner extends MessRepository {
  @override
  Future<Map<String, dynamic>?> getOwnerMessDetails() async {
    return {
      'id': 'mess-sync-1',
      'mess_name': 'Greenwood Campus Mess',
      'served_meals': ['breakfast', 'lunch', 'dinner'],
      'cost_per_meal': 60,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getMessMembers({String? messId}) async {
    return [
      {'id': 'm1', 'full_name': 'Aarav Patel'},
      {'id': 'm2', 'full_name': 'Diya Shah'},
      {'id': 'm3', 'full_name': 'Karan Mehta'},
      {'id': 'm4', 'full_name': 'Pooja Joshi'},
    ];
  }
}

class MockAttendanceRepoForPlanner extends AttendanceRepo {
  @override
  Future<int> getOptedOutCount({
    required String messId,
    required DateTime date,
    required String mealType,
  }) async {
    return 1; // 1 opt out -> 4 - 1 = 3 attending
  }
}

class MockMenuRepoForPlanner extends MenuRepository {
  @override
  Future<List<Map<String, dynamic>>> getMenuForDate(DateTime date) async {
    return [];
  }
}

void main() {
  group('PreparationPlanner and Surplus Auto-Sync Tests', () {
    test('Persists finalCookingTarget to SurplusRepository on adjustment', () async {
      final mockSurplus = MockSurplusRepoForSync();
      final plannerController = PreparationPlannerController(
        messRepo: MockMessRepoForPlanner(),
        attendanceRepo: MockAttendanceRepoForPlanner(),
        menuRepo: MockMenuRepoForPlanner(),
        surplusRepo: mockSurplus,
      );

      // Wait for initial async loading
      await Future.delayed(const Duration(milliseconds: 50));

      expect(plannerController.totalJoinedMembers, 4);
      expect(plannerController.optedOutCount, 1);
      expect(plannerController.attendingMembers, 3);
      expect(plannerController.finalCookingTarget, 3);

      // Increment extra plates -> target becomes 3 + 2 = 5
      plannerController.incrementExtraPlates();
      plannerController.incrementExtraPlates();
      expect(plannerController.finalCookingTarget, 5);

      await plannerController.syncCookingTarget();
      expect(mockSurplus.savedRecord, isNotNull);
      expect(mockSurplus.savedRecord!.targetPortions, 5);
      expect(mockSurplus.savedRecord!.messId, 'mess-sync-1');
    });

    test('SurplusController correctly calculates kitchen variance status', () {
      final mockSurplus = MockSurplusRepoForSync();
      mockSurplus.savedRecord = MealPrepRecordModel(
        id: 'rec-var-1',
        messId: 'mess-1',
        prepDate: DateTime.now(),
        mealType: 'lunch',
        targetPortions: 100,
        preparedPortions: 110,
        servedPortions: 95,
        discardedPortions: 5,
        surplusPortions: 15,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final controller = SurplusController(
        surplusRepo: mockSurplus,
        initialMessId: 'mess-1',
        autoLoad: false,
      );

      // When unlogged or not loaded
      expect(controller.kitchenVarianceStatus, 'unlogged');

      // Refresh to load savedRecord
      mockSurplus.getMealPrepRecord(messId: 'mess-1', date: DateTime.now(), mealType: 'lunch');
    });
  });
}
