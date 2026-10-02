import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealmate/data/models/models.dart';
import 'package:mealmate/data/repos/mess_repo.dart';
import 'package:mealmate/data/repos/surplus_repo.dart';
import 'package:mealmate/logic/controllers/surplus_controller.dart';
import 'package:mealmate/ui/owner/surplus_allocation_screen.dart';

/// In-memory fake repository for SurplusRepository to test controllers & UI
/// without requiring a live or migrated Supabase instance.
class FakeSurplusRepository implements SurplusRepository {
  final Map<String, MealPrepRecordModel> prepRecords = {};
  final List<DonationPartnerModel> partnersList = [];
  final List<SurplusAllocationModel> allocationsList = [];

  String _recordKey(String messId, DateTime date, String mealType) {
    final dStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '${messId}_${dStr}_${mealType.toLowerCase()}';
  }

  @override
  Future<MealPrepRecordModel?> getMealPrepRecord({
    required String messId,
    required DateTime date,
    required String mealType,
  }) async {
    return prepRecords[_recordKey(messId, date, mealType)];
  }

  @override
  Future<MealPrepRecordModel> saveCookingTarget({
    required String messId,
    required DateTime date,
    required String mealType,
    required int targetPortions,
  }) async {
    final key = _recordKey(messId, date, mealType);
    final existing = prepRecords[key];
    final record = MealPrepRecordModel(
      id: existing?.id ?? 'rec-${prepRecords.length + 1}',
      messId: messId,
      prepDate: date,
      mealType: mealType.toLowerCase(),
      targetPortions: targetPortions,
      preparedPortions: existing?.preparedPortions ?? 0,
      servedPortions: existing?.servedPortions ?? 0,
      discardedPortions: existing?.discardedPortions ?? 0,
      surplusPortions: (existing?.preparedPortions ?? 0) - (existing?.servedPortions ?? 0),
    );
    prepRecords[key] = record;
    return record;
  }

  @override
  Future<MealPrepRecordModel> recordMealPrep({
    required String messId,
    required DateTime date,
    required String mealType,
    required int preparedPortions,
    required int servedPortions,
    int? targetPortions,
    int? discardedPortions,
  }) async {
    if (preparedPortions < servedPortions) {
      throw ArgumentError('Prepared portions cannot be less than served portions.');
    }
    if (preparedPortions < 0 || servedPortions < 0) {
      throw ArgumentError('Portions cannot be negative.');
    }

    final key = _recordKey(messId, date, mealType);
    final existing = prepRecords[key];
    final record = MealPrepRecordModel(
      id: existing?.id ?? 'rec-${prepRecords.length + 1}',
      messId: messId,
      prepDate: date,
      mealType: mealType.toLowerCase(),
      targetPortions: targetPortions ?? existing?.targetPortions ?? 0,
      preparedPortions: preparedPortions,
      servedPortions: servedPortions,
      discardedPortions: discardedPortions ?? existing?.discardedPortions ?? 0,
      surplusPortions: preparedPortions - servedPortions,
    );
    prepRecords[key] = record;
    return record;
  }

  @override
  Future<MealPrepRecordModel> updateDiscardedPortions({
    required String mealPrepRecordId,
    required int discardedPortions,
  }) async {
    if (discardedPortions < 0) {
      throw ArgumentError('Discarded portions cannot be negative.');
    }
    final key = prepRecords.keys.firstWhere(
      (k) => prepRecords[k]?.id == mealPrepRecordId,
      orElse: () => throw Exception('Record not found'),
    );
    final existing = prepRecords[key]!;
    final updated = existing.copyWith(discardedPortions: discardedPortions);
    prepRecords[key] = updated;
    return updated;
  }

  @override
  Future<List<DonationPartnerModel>> getPartners({
    required String messId,
    bool activeOnly = true,
  }) async {
    return partnersList
        .where((p) => p.messId == messId && (!activeOnly || p.isActive))
        .toList();
  }

  @override
  Future<DonationPartnerModel> createPartner({
    required String messId,
    required String name,
    String? contactPhone,
    String? contactPerson,
    String? address,
    String? notes,
  }) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Partner name cannot be empty.');
    }
    final partner = DonationPartnerModel(
      id: 'partner-${partnersList.length + 1}',
      messId: messId,
      name: name.trim(),
      contactPhone: contactPhone,
      contactPerson: contactPerson,
      address: address,
      notes: notes,
      isActive: true,
    );
    partnersList.add(partner);
    return partner;
  }

  @override
  Future<DonationPartnerModel> updatePartner({
    required String partnerId,
    required String messId,
    String? name,
    String? contactPhone,
    String? contactPerson,
    String? address,
    String? notes,
    bool? isActive,
  }) async {
    final idx = partnersList.indexWhere((p) => p.id == partnerId && p.messId == messId);
    if (idx == -1) throw Exception('Partner not found');
    final existing = partnersList[idx];
    final updated = existing.copyWith(
      name: name,
      contactPhone: contactPhone,
      contactPerson: contactPerson,
      address: address,
      notes: notes,
      isActive: isActive,
    );
    partnersList[idx] = updated;
    return updated;
  }

  @override
  Future<List<SurplusAllocationModel>> getAllocationsForMeal({
    required String mealPrepRecordId,
  }) async {
    return allocationsList
        .where((a) => a.mealPrepRecordId == mealPrepRecordId)
        .toList();
  }

  @override
  Future<SurplusAllocationModel> createAllocation({
    required String messId,
    required String mealPrepRecordId,
    required int quantity,
    String? partnerId,
    String? notes,
  }) async {
    if (quantity <= 0) {
      throw ArgumentError('Allocation quantity must be greater than zero.');
    }
    String? partnerName;
    if (partnerId != null) {
      final p = partnersList.firstWhere((e) => e.id == partnerId, orElse: () => DonationPartnerModel(id: '', messId: '', name: ''));
      partnerName = p.name.isNotEmpty ? p.name : null;
    }

    final alloc = SurplusAllocationModel(
      id: 'alloc-${allocationsList.length + 1}',
      messId: messId,
      mealPrepRecordId: mealPrepRecordId,
      partnerId: partnerId,
      partnerName: partnerName,
      quantity: quantity,
      status: SurplusAllocationModel.statusPending,
      notes: notes,
    );
    allocationsList.insert(0, alloc);
    return alloc;
  }

  @override
  Future<SurplusAllocationModel> updateAllocationStatus({
    required String allocationId,
    required String messId,
    required String status,
  }) async {
    final idx = allocationsList.indexWhere((a) => a.id == allocationId && a.messId == messId);
    if (idx == -1) {
      throw Exception('Allocation not found');
    }
    final existing = allocationsList[idx];
    final updated = existing.copyWith(status: status.toLowerCase());
    allocationsList[idx] = updated;
    return updated;
  }

  @override
  Future<int> getCompletedDonationsCount({
    required String messId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return allocationsList
        .where((a) => a.messId == messId && a.isCompletedDonation)
        .fold<int>(0, (sum, a) => sum + a.quantity);
  }

  @override
  Future<int> getDiscardedPortionsCount({
    required String messId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return prepRecords.values
        .where((r) => r.messId == messId)
        .fold<int>(0, (sum, r) => sum + r.discardedPortions);
  }
}

class FakeMessRepository implements MessRepository {
  final Map<String, dynamic> messData;

  FakeMessRepository({Map<String, dynamic>? data})
      : messData = data ?? {
          'id': 'mess-test-123',
          'mess_name': 'Green Leaf Mess',
          'served_meals': ['breakfast', 'lunch', 'dinner'],
        };

  @override
  Future<Map<String, dynamic>?> getOwnerMessDetails() async => messData;

  @override
  Future<String> createMess({required String messName, required List<String> servedMeals}) async => 'mess-id';

  @override
  Future<void> joinMess({required String inviteCode}) async {}

  @override
  Future<String?> getOwnerMessName() async => messData['mess_name'] as String?;

  @override
  Future<void> updateMessName({required String newName}) async {}

  @override
  Future<void> updateCostPerMeal({required String messId, required int costPerMeal}) async {
    messData['cost_per_meal'] = costPerMeal;
  }

  @override
  Future<List<Map<String, dynamic>>> getMessMembers() async => [];
}

void main() {
  group('SurplusController Phase 2 Logic Tests', () {
    late FakeSurplusRepository fakeSurplusRepo;
    late FakeMessRepository fakeMessRepo;
    late SurplusController controller;

    setUp(() {
      fakeSurplusRepo = FakeSurplusRepository();
      fakeMessRepo = FakeMessRepository();
      controller = SurplusController(
        surplusRepo: fakeSurplusRepo,
        messRepo: fakeMessRepo,
        autoLoad: false,
      );
    });

    test('Initializes with owner mess details and loads data', () async {
      await controller.init();

      expect(controller.messId, 'mess-test-123');
      expect(controller.messName, 'Green Leaf Mess');
      expect(controller.servedMeals, ['breakfast', 'lunch', 'dinner']);
      expect(controller.availablePortions, 0);
      expect(controller.monthlyDonatedMealsCount, 0);
      expect(controller.partners, isEmpty);
      expect(controller.allocations, isEmpty);
    });

    test('Separate cooking target from actual prepared portions and does not prefill', () async {
      final today = DateTime.now();
      // Pre-seed a record that has target portions = 80 from planner
      await fakeSurplusRepo.recordMealPrep(
        messId: 'mess-test-123',
        date: today,
        mealType: 'lunch',
        preparedPortions: 0,
        servedPortions: 0,
        targetPortions: 80,
      );

      await controller.init();
      await controller.setDate(today);
      await controller.setMeal('lunch');

      // Target is visible
      expect(controller.targetPortions, 80);
      // Actual prepared and served are NOT prefilled with target
      expect(controller.preparedPortions, 0);
      expect(controller.servedPortions, 0);
      expect(controller.calculatedSurplus, 0);
      expect(controller.availablePortions, 0);
    });

    test('Enforces prepared >= served and calculates surplus', () async {
      await controller.init();

      // Attempt invalid: prepared < served
      final failResult = await controller.recordMealPrep(
        preparedPortions: 30,
        servedPortions: 35,
      );
      expect(failResult, isFalse);
      expect(controller.errorMessage, contains('cannot be less than served'));

      // Valid: prepared 50, served 42 -> Surplus = 8
      final successResult = await controller.recordMealPrep(
        preparedPortions: 50,
        servedPortions: 42,
      );
      expect(successResult, isTrue);
      expect(controller.calculatedSurplus, 8);
      expect(controller.availablePortions, 8);
      expect(controller.discardedPortions, 0);
    });

    test('Records discarded food and respects surplus capacity', () async {
      await controller.init();
      await controller.recordMealPrep(preparedPortions: 50, servedPortions: 40); // Surplus = 10

      // Record 3 discarded portions
      final discardOk = await controller.recordDiscardedPortions(3);
      expect(discardOk, isTrue);
      expect(controller.discardedPortions, 3);
      // Available = 10 - 3 = 7
      expect(controller.availablePortions, 7);

      // Attempt to discard more than available surplus (e.g. 15 > 10)
      final discardFail = await controller.recordDiscardedPortions(15);
      expect(discardFail, isFalse);
      expect(controller.errorMessage, contains('cannot exceed calculated surplus'));
    });

    test('Creates partner, creates allocation, and maintains collected donation invariant', () async {
      await controller.init();
      await controller.recordMealPrep(preparedPortions: 60, servedPortions: 50); // Surplus = 10

      // Add real partner
      final partner = await controller.addPartner(
        name: 'City Care Shelter',
        contactPhone: '+91 99999 88888',
        contactPerson: 'Rahul Kumar',
        address: 'MG Road, Block 2',
      );
      expect(partner, isNotNull);
      expect(controller.partners.length, 1);
      expect(controller.partners.first.name, 'City Care Shelter');

      // Create allocation of 6 portions
      final allocSuccess = await controller.createAllocation(
        quantity: 6,
        partnerId: partner!.id,
        notes: 'Vegetarian rice and dal',
      );
      expect(allocSuccess, isTrue);
      expect(controller.allocations.length, 1);
      expect(controller.activeAllocatedPortions, 6);
      // Available = 10 - 6 = 4
      expect(controller.availablePortions, 4);

      // CRITICAL INVARIANT: Pending allocation does NOT count as completed donation!
      expect(controller.allocations.first.isPending, isTrue);
      expect(controller.monthlyDonatedMealsCount, 0);
      expect(controller.mealCollectedDonations, 0);

      // Cannot allocate more than available portions (try 5 when only 4 available)
      final overAllocSuccess = await controller.createAllocation(quantity: 5);
      expect(overAllocSuccess, isFalse);
      expect(controller.errorMessage, contains('Cannot allocate 5 portions'));

      // Mark allocation collected -> now it counts as completed donation!
      final allocId = controller.allocations.first.id;
      final collectedSuccess = await controller.updateAllocationStatus(
        allocationId: allocId,
        status: SurplusAllocationModel.statusCollected,
      );
      expect(collectedSuccess, isTrue);
      expect(controller.allocations.first.isCompletedDonation, isTrue);
      expect(controller.monthlyDonatedMealsCount, 6);
      expect(controller.mealCollectedDonations, 6);
      // Capacity is still consumed by collected allocation
      expect(controller.availablePortions, 4);
    });

    test('Cancelling an allocation releases portions back to available surplus', () async {
      await controller.init();
      await controller.recordMealPrep(preparedPortions: 40, servedPortions: 30); // Surplus = 10

      await controller.createAllocation(quantity: 4);
      expect(controller.availablePortions, 6);
      expect(controller.activeAllocatedPortions, 4);

      final allocId = controller.allocations.first.id;
      // Cancel allocation
      await controller.updateAllocationStatus(
        allocationId: allocId,
        status: SurplusAllocationModel.statusCancelled,
      );

      expect(controller.allocations.first.isCancelled, isTrue);
      // Released!
      expect(controller.activeAllocatedPortions, 0);
      expect(controller.availablePortions, 10);
      expect(controller.monthlyDonatedMealsCount, 0);
    });
  });

  group('SurplusAllocationScreen Widget Tests', () {
    late FakeSurplusRepository fakeSurplusRepo;
    late FakeMessRepository fakeMessRepo;
    late SurplusController controller;

    setUp(() {
      fakeSurplusRepo = FakeSurplusRepository();
      fakeMessRepo = FakeMessRepository();
      controller = SurplusController(
        surplusRepo: fakeSurplusRepo,
        messRepo: fakeMessRepo,
        initialMessId: 'mess-test-123',
        autoLoad: false,
      );
    });

    testWidgets('Renders header, planner target, logger card, partners, history, and impact banner',
        (tester) async {
      await controller.init();

      await tester.pumpWidget(
        MaterialApp(
          home: SurplusAllocationScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      // Header verification
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('Surplus Management'),
        ),
        findsOneWidget,
      );
      expect(find.text('Good Food\nTomorrow'), findsOneWidget);

      // Planner target visibly separate
      expect(find.text('Preparation Planner Target'), findsOneWidget);

      // Portions breakdown
      expect(find.text('Save Kitchen Portions'), findsOneWidget);

      // Donation partners section and empty state
      expect(find.text('Food Donation Partners'), findsOneWidget);
      expect(find.text('No donation partners registered yet'), findsOneWidget);

      // Allocation history section and empty state
      expect(find.text('Allocation History'), findsOneWidget);
      expect(find.text('No allocations created for this meal yet.'), findsOneWidget);

      // Impact banner with 0 count
      expect(find.text('0 meals collected this month'), findsOneWidget);
    });

    testWidgets('Interactively logs kitchen portions and displays calculated surplus',
        (tester) async {
      await controller.init();

      await tester.pumpWidget(
        MaterialApp(
          home: SurplusAllocationScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      // Enter prepared = 50, served = 40
      final preparedFields = find.widgetWithText(TextField, 'Cooked');
      final servedFields = find.widgetWithText(TextField, 'Served');

      expect(preparedFields, findsOneWidget);
      expect(servedFields, findsOneWidget);

      await tester.enterText(preparedFields, '50');
      await tester.enterText(servedFields, '40');
      await tester.pumpAndSettle();

      // Live surplus calculation should show 10 portions
      expect(find.text('10 portions'), findsOneWidget);

      // Tap Save Kitchen Portions
      final saveBtn = find.widgetWithText(ElevatedButton, 'Save Kitchen Portions');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Portions breakdown should now be visible
      expect(find.text('Portions Breakdown'), findsOneWidget);
      expect(find.text('Log Discarded Food'), findsOneWidget);
      expect(find.text('Create Surplus Allocation'), findsOneWidget);
    });

    testWidgets('Adds partner, creates allocation, and marks collected via UI',
        (tester) async {
      await controller.init();
      await controller.recordMealPrep(preparedPortions: 60, servedPortions: 45); // Surplus = 15

      // Add a partner directly to repo to test partner card UI
      await fakeSurplusRepo.createPartner(
        messId: 'mess-test-123',
        name: 'Community Food Kitchen',
        contactPhone: '+91 98765 00000',
        contactPerson: 'Anita Rao',
      );
      await controller.refresh();

      await tester.pumpWidget(
        MaterialApp(
          home: SurplusAllocationScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      // Partner card rendered with real data and NO fake distance
      expect(find.text('Community Food Kitchen'), findsOneWidget);
      expect(find.text('Contact: Anita Rao'), findsOneWidget);
      expect(find.text('+91 98765 00000'), findsOneWidget);
      expect(find.textContaining('km away'), findsNothing);

      // Create an allocation of 5 portions
      await controller.createAllocation(
        quantity: 5,
        partnerId: controller.partners.first.id,
        notes: 'Packed dinner trays',
      );
      await tester.pumpAndSettle();

      // Allocation history item should be visible in Pending Pickup state
      final pendingFinder = find.text('Pending Pickup');
      await tester.ensureVisible(pendingFinder);
      expect(find.text('5 Portions'), findsOneWidget);
      expect(pendingFinder, findsOneWidget);
      expect(find.text('Mark Collected'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Before marking collected: 0 completed donations
      final impactBannerFinder = find.text('0 meals collected this month');
      await tester.ensureVisible(impactBannerFinder);
      expect(impactBannerFinder, findsOneWidget);

      // Tap Mark Collected
      final markCollectedFinder = find.text('Mark Collected');
      await tester.ensureVisible(markCollectedFinder);
      await tester.tap(markCollectedFinder);
      await tester.pumpAndSettle();

      // Status changes to Collected and Impact Banner reflects 5 meals donated!
      final collectedBadgeFinder = find.text('Collected');
      await tester.ensureVisible(collectedBadgeFinder);
      expect(collectedBadgeFinder, findsOneWidget);

      final updatedImpactFinder = find.text('5 meals donated this month');
      await tester.ensureVisible(updatedImpactFinder);
      expect(updatedImpactFinder, findsOneWidget);
    });
  });
}
