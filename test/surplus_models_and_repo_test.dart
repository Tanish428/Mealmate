import 'package:flutter_test/flutter_test.dart';
import 'package:mealmate/data/models/models.dart';
import 'package:mealmate/data/repos/surplus_repo.dart';

void main() {
  group('MealPrepRecordModel Tests', () {
    test('Calculates surplus as preparedPortions - servedPortions', () {
      final record = MealPrepRecordModel(
        id: 'rec-1',
        messId: 'mess-1',
        prepDate: DateTime(2026, 9, 27),
        mealType: 'lunch',
        targetPortions: 75, // Target from planner
        preparedPortions: 80, // Actual cooked
        servedPortions: 72, // Actual served
        discardedPortions: 2, // Spoiled / waste
      );

      // Verify target is kept separate from prepared
      expect(record.targetPortions, 75);
      expect(record.preparedPortions, 80);
      expect(record.servedPortions, 72);

      // Surplus is strictly prepared - served
      expect(record.surplusPortions, 8);
      expect(record.calculatedSurplus, 8);

      // Gross available for allocation = surplus - discarded = 8 - 2 = 6
      expect(record.grossAvailableForAllocation, 6);
    });

    test('Serializes to and from JSON correctly', () {
      final json = {
        'id': 'rec-123',
        'mess_id': 'mess-456',
        'prep_date': '2026-09-27',
        'meal_type': 'DINNER',
        'target_portions': 60,
        'prepared_portions': 65,
        'served_portions': 58,
        'discarded_portions': 1,
        'surplus_portions': 7,
        'created_at': '2026-09-27T12:00:00.000Z',
        'updated_at': '2026-09-27T12:00:00.000Z',
      };

      final model = MealPrepRecordModel.fromJson(json);
      expect(model.id, 'rec-123');
      expect(model.messId, 'mess-456');
      expect(model.mealType, 'dinner');
      expect(model.targetPortions, 60);
      expect(model.preparedPortions, 65);
      expect(model.servedPortions, 58);
      expect(model.discardedPortions, 1);
      expect(model.surplusPortions, 7);

      final serialized = model.toJson();
      expect(serialized['mess_id'], 'mess-456');
      expect(serialized['prep_date'], '2026-09-27');
      expect(serialized['meal_type'], 'dinner');
      expect(serialized['target_portions'], 60);
      expect(serialized['prepared_portions'], 65);
      expect(serialized['served_portions'], 58);
      expect(serialized['discarded_portions'], 1);
    });
  });

  group('DonationPartnerModel Tests', () {
    test('Serializes without fake mock distances or sample data', () {
      final partner = DonationPartnerModel(
        id: 'p-1',
        messId: 'mess-1',
        name: 'City Youth Center',
        contactPhone: '+91 98765 43210',
        contactPerson: 'Aditi Sharma',
        address: 'Sector 4, Community Block',
        isActive: true,
      );

      expect(partner.name, 'City Youth Center');
      expect(partner.contactPhone, '+91 98765 43210');
      expect(partner.isActive, isTrue);

      final json = partner.toJson();
      expect(json['name'], 'City Youth Center');
      expect(json['is_active'], isTrue);

      final reconstructed = DonationPartnerModel.fromJson(json);
      expect(reconstructed.name, partner.name);
      expect(reconstructed.address, partner.address);
    });
  });

  group('SurplusAllocationModel Tests', () {
    test('Only collected status counts as a completed donation', () {
      final pendingAlloc = SurplusAllocationModel(
        id: 'alloc-1',
        messId: 'mess-1',
        mealPrepRecordId: 'rec-1',
        quantity: 5,
        status: SurplusAllocationModel.statusPending,
      );

      final collectedAlloc = SurplusAllocationModel(
        id: 'alloc-2',
        messId: 'mess-1',
        mealPrepRecordId: 'rec-1',
        quantity: 5,
        status: SurplusAllocationModel.statusCollected,
      );

      final cancelledAlloc = SurplusAllocationModel(
        id: 'alloc-3',
        messId: 'mess-1',
        mealPrepRecordId: 'rec-1',
        quantity: 5,
        status: SurplusAllocationModel.statusCancelled,
      );

      // Pending allocation: active (consumes surplus) but NOT a completed donation
      expect(pendingAlloc.isActive, isTrue);
      expect(pendingAlloc.isPending, isTrue);
      expect(pendingAlloc.isCompletedDonation, isFalse);

      // Collected allocation: active AND is a completed donation
      expect(collectedAlloc.isActive, isTrue);
      expect(collectedAlloc.isCompletedDonation, isTrue);

      // Cancelled allocation: NOT active (releases surplus) and NOT a completed donation
      expect(cancelledAlloc.isActive, isFalse);
      expect(cancelledAlloc.isCancelled, isTrue);
      expect(cancelledAlloc.isCompletedDonation, isFalse);
    });
  });

  group('SurplusRepository Validation Guards', () {
    test('Rejects recording meal prep when prepared < served', () {
      final repo = SurplusRepository();

      expect(
        () => repo.recordMealPrep(
          messId: 'mess-1',
          date: DateTime.now(),
          mealType: 'lunch',
          preparedPortions: 40,
          servedPortions: 45, // Violates prepared >= served!
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Rejects negative portions in meal prep', () {
      final repo = SurplusRepository();

      expect(
        () => repo.recordMealPrep(
          messId: 'mess-1',
          date: DateTime.now(),
          mealType: 'lunch',
          preparedPortions: -10,
          servedPortions: 0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Rejects allocation quantity <= 0', () {
      final repo = SurplusRepository();

      expect(
        () => repo.createAllocation(
          messId: 'mess-1',
          mealPrepRecordId: 'rec-1',
          quantity: 0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Rejects empty partner name', () {
      final repo = SurplusRepository();

      expect(
        () => repo.createPartner(
          messId: 'mess-1',
          name: '   ',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Rejects invalid allocation status update', () {
      final repo = SurplusRepository();

      expect(
        () => repo.updateAllocationStatus(
          allocationId: 'alloc-1',
          messId: 'mess-1',
          status: 'unknown_status',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
