class MealPrepRecordModel {
  final String id;
  final String messId;
  final DateTime prepDate;
  final String mealType;
  final int targetPortions;
  final int preparedPortions;
  final int servedPortions;
  final int discardedPortions;
  final int surplusPortions;
  final DateTime createdAt;
  final DateTime updatedAt;

  MealPrepRecordModel({
    required this.id,
    required this.messId,
    required this.prepDate,
    required this.mealType,
    this.targetPortions = 0,
    this.preparedPortions = 0,
    this.servedPortions = 0,
    this.discardedPortions = 0,
    int? surplusPortions,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : surplusPortions = surplusPortions ?? (preparedPortions - servedPortions),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Surplus is strictly calculated as actual prepared minus actual served.
  int get calculatedSurplus => preparedPortions - servedPortions;

  /// Available portions for allocation after subtracting discarded portions.
  int get grossAvailableForAllocation => calculatedSurplus - discardedPortions;

  factory MealPrepRecordModel.fromJson(Map<dynamic, dynamic> json) {
    final prepDateRaw = json['prep_date'];
    final DateTime parsedDate;
    if (prepDateRaw is DateTime) {
      parsedDate = prepDateRaw;
    } else {
      parsedDate = DateTime.parse(prepDateRaw.toString());
    }

    final createdAtRaw = json['created_at'];
    final updatedAtRaw = json['updated_at'];

    final prepared = (json['prepared_portions'] as num?)?.toInt() ?? 0;
    final served = (json['served_portions'] as num?)?.toInt() ?? 0;

    return MealPrepRecordModel(
      id: json['id']?.toString() ?? '',
      messId: json['mess_id']?.toString() ?? '',
      prepDate: parsedDate,
      mealType: json['meal_type']?.toString().toLowerCase() ?? 'lunch',
      targetPortions: (json['target_portions'] as num?)?.toInt() ?? 0,
      preparedPortions: prepared,
      servedPortions: served,
      discardedPortions: (json['discarded_portions'] as num?)?.toInt() ?? 0,
      surplusPortions: (json['surplus_portions'] as num?)?.toInt() ?? (prepared - served),
      createdAt: createdAtRaw != null ? DateTime.parse(createdAtRaw.toString()) : DateTime.now(),
      updatedAt: updatedAtRaw != null ? DateTime.parse(updatedAtRaw.toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    final dateString =
        '${prepDate.year}-${prepDate.month.toString().padLeft(2, '0')}-${prepDate.day.toString().padLeft(2, '0')}';
    return {
      if (id.isNotEmpty) 'id': id,
      'mess_id': messId,
      'prep_date': dateString,
      'meal_type': mealType.toLowerCase(),
      'target_portions': targetPortions,
      'prepared_portions': preparedPortions,
      'served_portions': servedPortions,
      'discarded_portions': discardedPortions,
    };
  }

  MealPrepRecordModel copyWith({
    String? id,
    String? messId,
    DateTime? prepDate,
    String? mealType,
    int? targetPortions,
    int? preparedPortions,
    int? servedPortions,
    int? discardedPortions,
    int? surplusPortions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealPrepRecordModel(
      id: id ?? this.id,
      messId: messId ?? this.messId,
      prepDate: prepDate ?? this.prepDate,
      mealType: mealType ?? this.mealType,
      targetPortions: targetPortions ?? this.targetPortions,
      preparedPortions: preparedPortions ?? this.preparedPortions,
      servedPortions: servedPortions ?? this.servedPortions,
      discardedPortions: discardedPortions ?? this.discardedPortions,
      surplusPortions: surplusPortions ?? this.surplusPortions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
