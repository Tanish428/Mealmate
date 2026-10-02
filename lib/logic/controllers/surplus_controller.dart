import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../../data/models/models.dart';
import '../../data/repos/surplus_repo.dart';
import '../../data/repos/mess_repo.dart';

/// Controller managing meal preparation actuals, surplus calculation,
/// donation partner management, and surplus allocation lifecycle.
class SurplusController extends ChangeNotifier {
  final SurplusRepository _surplusRepo;
  final MessRepository _messRepo;

  String _messId;
  String _messName = '';
  List<String> _servedMeals = [];
  DateTime _selectedDate;
  String _selectedMeal;

  MealPrepRecordModel? _currentRecord;
  List<DonationPartnerModel> _partners = [];
  List<SurplusAllocationModel> _allocations = [];
  int _monthlyDonatedMealsCount = 0;

  bool _isLoading = false;
  bool _isSavingPrep = false;
  bool _isCreatingAllocation = false;
  bool _isUpdatingStatus = false;
  bool _isRecordingDiscarded = false;

  String? _errorMessage;
  String? _successMessage;

  SurplusController({
    SurplusRepository? surplusRepo,
    MessRepository? messRepo,
    String? initialMessId,
    DateTime? initialDate,
    String? initialMeal,
    bool autoLoad = true,
  })  : _surplusRepo = surplusRepo ?? SurplusRepository(),
        _messRepo = messRepo ?? MessRepository(),
        _messId = initialMessId ?? '',
        _selectedDate = initialDate != null
            ? DateTime(initialDate.year, initialDate.month, initialDate.day)
            : DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
        _selectedMeal = initialMeal?.toLowerCase() ?? 'lunch' {
    if (autoLoad) {
      init();
    }
  }

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  String get messId => _messId;
  String get messName => _messName;
  List<String> get servedMeals =>
      _servedMeals.isNotEmpty ? _servedMeals : const ['breakfast', 'lunch', 'dinner'];
  DateTime get selectedDate => _selectedDate;
  String get selectedMeal => _selectedMeal;

  MealPrepRecordModel? get currentRecord => _currentRecord;
  List<DonationPartnerModel> get partners => List.unmodifiable(_partners);
  List<SurplusAllocationModel> get allocations => List.unmodifiable(_allocations);

  int get monthlyDonatedMealsCount => _monthlyDonatedMealsCount;

  bool get isLoading => _isLoading;
  bool get isSavingPrep => _isSavingPrep;
  bool get isCreatingAllocation => _isCreatingAllocation;
  bool get isUpdatingStatus => _isUpdatingStatus;
  bool get isRecordingDiscarded => _isRecordingDiscarded;

  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Planned cooking target from preparation planner (strictly separate from actual cooked).
  int get targetPortions => _currentRecord?.targetPortions ?? 0;

  /// Actual portions cooked in the kitchen.
  int get preparedPortions => _currentRecord?.preparedPortions ?? 0;

  /// Variance between actual portions cooked and target cooking portions.
  int get kitchenVariance => preparedPortions - targetPortions;

  /// Human-readable kitchen variance status: 'over', 'under', 'exact', 'unlogged'.
  String get kitchenVarianceStatus {
    if (_currentRecord == null || preparedPortions == 0) return 'unlogged';
    if (kitchenVariance > 0) return 'over';
    if (kitchenVariance < 0) return 'under';
    return 'exact';
  }

  /// Actual portions consumed by attending members and guests.
  int get servedPortions => _currentRecord?.servedPortions ?? 0;

  /// Portions discarded due to spoilage or non-donation.
  int get discardedPortions => _currentRecord?.discardedPortions ?? 0;

  /// Surplus is strictly calculated as actual prepared minus actual served.
  int get calculatedSurplus =>
      _currentRecord != null ? math.max(0, _currentRecord!.calculatedSurplus) : 0;

  /// Active allocations (both pending and collected) reserve surplus portions.
  int get activeAllocatedPortions => _allocations
      .where((a) => a.isActive)
      .fold<int>(0, (sum, a) => sum + a.quantity);

  /// Completed donations (collected allocations only) for current meal.
  int get mealCollectedDonations => _allocations
      .where((a) => a.isCompletedDonation)
      .fold<int>(0, (sum, a) => sum + a.quantity);

  /// Pending allocations for current meal.
  int get mealPendingAllocations => _allocations
      .where((a) => a.isPending)
      .fold<int>(0, (sum, a) => sum + a.quantity);

  /// Available portions for new allocations:
  /// Available = max(0, Surplus - Discarded - Active Allocations)
  int get availablePortions =>
      math.max(0, calculatedSurplus - discardedPortions - activeAllocatedPortions);

  /// Portions remaining alias for backward compatibility.
  int get portionsRemaining => availablePortions;
  int get leftoverPortions => availablePortions;

  /// Environmental metrics based strictly on completed donations.
  int get peopleFed => _monthlyDonatedMealsCount;
  double get co2SavedKg => _monthlyDonatedMealsCount * 1.8;
  double get waterSavedLiters => _monthlyDonatedMealsCount * 250.0;

  // ---------------------------------------------------------------------------
  // Data Loading Lifecycle
  // ---------------------------------------------------------------------------

  /// Initializes mess information and loads all necessary surplus state.
  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_messId.isEmpty) {
        final messDetails = await _messRepo.getOwnerMessDetails();
        if (messDetails != null) {
          _messId = messDetails['id']?.toString() ?? '';
          _messName = messDetails['mess_name']?.toString() ?? '';
          final rawMeals = messDetails['served_meals'];
          if (rawMeals is List) {
            _servedMeals = rawMeals.map((e) => e.toString().toLowerCase()).toList();
          }
        }
      }

      if (_servedMeals.isNotEmpty && !_servedMeals.contains(_selectedMeal)) {
        _selectedMeal = _servedMeals.first;
      }

      await _loadAllData();
    } catch (e) {
      _errorMessage = 'Failed to load surplus data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sets the selected date and refreshes the meal preparation record and allocations.
  Future<void> setDate(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    if (_selectedDate == normalized) return;
    _selectedDate = normalized;
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _loadMealData();
    } catch (e) {
      _errorMessage = 'Failed to load meal data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sets the selected meal type (breakfast, lunch, dinner) and refreshes data.
  Future<void> setMeal(String meal) async {
    final normalized = meal.toLowerCase();
    if (_selectedMeal == normalized) return;
    _selectedMeal = normalized;
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _loadMealData();
    } catch (e) {
      _errorMessage = 'Failed to load meal data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refreshes all data: meal record, allocations, partners, and monthly impact totals.
  Future<void> refresh() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loadAllData();
    } catch (e) {
      _errorMessage = 'Failed to refresh surplus data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAllData() async {
    if (_messId.isEmpty) return;
    await Future.wait([
      _loadMealData(),
      _loadPartners(),
      _loadMonthlyDonations(),
    ]);
  }

  Future<void> _loadMealData() async {
    if (_messId.isEmpty) return;
    _currentRecord = await _surplusRepo.getMealPrepRecord(
      messId: _messId,
      date: _selectedDate,
      mealType: _selectedMeal,
    );

    if (_currentRecord != null) {
      _allocations = await _surplusRepo.getAllocationsForMeal(
        mealPrepRecordId: _currentRecord!.id,
      );
    } else {
      _allocations = [];
    }
  }

  Future<void> _loadPartners() async {
    if (_messId.isEmpty) return;
    _partners = await _surplusRepo.getPartners(messId: _messId, activeOnly: true);
  }

  Future<void> _loadMonthlyDonations() async {
    if (_messId.isEmpty) return;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    _monthlyDonatedMealsCount = await _surplusRepo.getCompletedDonationsCount(
      messId: _messId,
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
  }

  // ---------------------------------------------------------------------------
  // Write Actions
  // ---------------------------------------------------------------------------

  /// Records actual prepared and served portions for the current meal and date.
  /// Enforces prepared >= served >= 0.
  /// Cooking target is preserved and kept strictly separate.
  Future<bool> recordMealPrep({
    required int preparedPortions,
    required int servedPortions,
  }) async {
    if (_messId.isEmpty) {
      _errorMessage = 'Mess ID is missing. Please ensure your mess profile is active.';
      notifyListeners();
      return false;
    }
    if (preparedPortions < 0 || servedPortions < 0) {
      _errorMessage = 'Portions cannot be negative.';
      notifyListeners();
      return false;
    }
    if (preparedPortions < servedPortions) {
      _errorMessage =
          'Prepared portions ($preparedPortions) cannot be less than served portions ($servedPortions).';
      notifyListeners();
      return false;
    }

    _isSavingPrep = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      _currentRecord = await _surplusRepo.recordMealPrep(
        messId: _messId,
        date: _selectedDate,
        mealType: _selectedMeal,
        preparedPortions: preparedPortions,
        servedPortions: servedPortions,
        targetPortions: _currentRecord?.targetPortions,
        discardedPortions: _currentRecord?.discardedPortions,
      );

      if (_currentRecord != null) {
        _allocations = await _surplusRepo.getAllocationsForMeal(
          mealPrepRecordId: _currentRecord!.id,
        );
      }
      _successMessage = 'Meal preparation logged successfully.';
      return true;
    } catch (e) {
      _errorMessage = 'Failed to log meal prep: $e';
      return false;
    } finally {
      _isSavingPrep = false;
      notifyListeners();
    }
  }

  /// Updates discarded portions for the current meal record.
  /// Enforces discarded >= 0 and capacity constraints.
  Future<bool> recordDiscardedPortions(int discarded) async {
    if (_currentRecord == null) {
      _errorMessage = 'Please log actual meal prep portions before recording discarded food.';
      notifyListeners();
      return false;
    }
    if (discarded < 0) {
      _errorMessage = 'Discarded portions cannot be negative.';
      notifyListeners();
      return false;
    }
    if (activeAllocatedPortions + discarded > calculatedSurplus) {
      _errorMessage =
          'Discarded portions ($discarded) + active allocations ($activeAllocatedPortions) cannot exceed calculated surplus ($calculatedSurplus).';
      notifyListeners();
      return false;
    }

    _isRecordingDiscarded = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      _currentRecord = await _surplusRepo.updateDiscardedPortions(
        mealPrepRecordId: _currentRecord!.id,
        discardedPortions: discarded,
      );
      _successMessage = 'Discarded portions updated successfully.';
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update discarded portions: $e';
      return false;
    } finally {
      _isRecordingDiscarded = false;
      notifyListeners();
    }
  }

  /// Creates a surplus allocation for the current meal.
  /// Capacity invariant: quantity <= availablePortions.
  Future<bool> createAllocation({
    required int quantity,
    String? partnerId,
    String? notes,
  }) async {
    if (_currentRecord == null) {
      _errorMessage = 'Please log actual meal prep portions before creating an allocation.';
      notifyListeners();
      return false;
    }
    if (quantity <= 0) {
      _errorMessage = 'Allocation quantity must be greater than zero.';
      notifyListeners();
      return false;
    }
    if (quantity > availablePortions) {
      _errorMessage =
          'Cannot allocate $quantity portions. Only $availablePortions portions are currently available.';
      notifyListeners();
      return false;
    }

    _isCreatingAllocation = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _surplusRepo.createAllocation(
        messId: _messId,
        mealPrepRecordId: _currentRecord!.id,
        quantity: quantity,
        partnerId: partnerId,
        notes: notes,
      );

      _allocations = await _surplusRepo.getAllocationsForMeal(
        mealPrepRecordId: _currentRecord!.id,
      );
      await _loadMonthlyDonations();

      _successMessage = 'Successfully allocated $quantity portions!';
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create surplus allocation: $e';
      return false;
    } finally {
      _isCreatingAllocation = false;
      notifyListeners();
    }
  }

  /// Updates lifecycle status of an allocation: 'collected' or 'cancelled'.
  /// Crucial rule: Only allocations with status = 'collected' count as completed donations.
  /// If cancelled, surplus capacity is released back to available portions.
  Future<bool> updateAllocationStatus({
    required String allocationId,
    required String status,
  }) async {
    final normalizedStatus = status.toLowerCase();
    if (normalizedStatus != SurplusAllocationModel.statusCollected &&
        normalizedStatus != SurplusAllocationModel.statusCancelled) {
      _errorMessage = 'Invalid status update: $status';
      notifyListeners();
      return false;
    }

    _isUpdatingStatus = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _surplusRepo.updateAllocationStatus(
        allocationId: allocationId,
        messId: _messId,
        status: normalizedStatus,
      );

      if (_currentRecord != null) {
        _allocations = await _surplusRepo.getAllocationsForMeal(
          mealPrepRecordId: _currentRecord!.id,
        );
      }
      await _loadMonthlyDonations();

      final label = normalizedStatus == SurplusAllocationModel.statusCollected
          ? 'collected (counted as completed donation)'
          : 'cancelled (portions returned to surplus)';
      _successMessage = 'Allocation successfully marked as $label.';
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update allocation status: $e';
      return false;
    } finally {
      _isUpdatingStatus = false;
      notifyListeners();
    }
  }

  /// Adds a real donation partner organization for this mess.
  Future<DonationPartnerModel?> addPartner({
    required String name,
    String? contactPhone,
    String? contactPerson,
    String? address,
    String? notes,
  }) async {
    if (name.trim().isEmpty) {
      _errorMessage = 'Partner name cannot be empty.';
      notifyListeners();
      return null;
    }
    if (_messId.isEmpty) {
      _errorMessage = 'Mess ID is missing. Please ensure your mess profile is active.';
      notifyListeners();
      return null;
    }

    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final partner = await _surplusRepo.createPartner(
        messId: _messId,
        name: name,
        contactPhone: contactPhone,
        contactPerson: contactPerson,
        address: address,
        notes: notes,
      );

      await _loadPartners();
      _successMessage = 'Partner "${partner.name}" added successfully.';
      notifyListeners();
      return partner;
    } catch (e) {
      _errorMessage = 'Failed to add partner: $e';
      notifyListeners();
      return null;
    }
  }

  /// Clears transient user-facing error and success messages.
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
