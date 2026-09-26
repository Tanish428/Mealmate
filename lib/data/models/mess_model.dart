class MessModel {
  final String id;
  final String ownerId;
  final String messName;
  final String inviteCode;
  final DateTime? createdAt;
  final bool billingEnabled;
  final double? perDayRate;
  final List<String> servedMeals;
  final Map<String, dynamic>? mealTimings;

  const MessModel({
    required this.id,
    required this.ownerId,
    required this.messName,
    required this.inviteCode,
    this.createdAt,
    this.billingEnabled = false,
    this.perDayRate,
    this.servedMeals = const [],
    this.mealTimings,
  });

  // Backward compatibility getters
  String get messId => id;
  String get name => messName;
  String get createdBy => ownerId;

  MessModel copyWith({
    String? id,
    String? ownerId,
    String? messName,
    String? inviteCode,
    DateTime? createdAt,
    bool? billingEnabled,
    double? perDayRate,
    List<String>? servedMeals,
    Map<String, dynamic>? mealTimings,
    String? messId,
    String? name,
    String? createdBy,
  }) {
    return MessModel(
      id: id ?? messId ?? this.id,
      ownerId: ownerId ?? createdBy ?? this.ownerId,
      messName: messName ?? name ?? this.messName,
      inviteCode: inviteCode ?? this.inviteCode,
      createdAt: createdAt ?? this.createdAt,
      billingEnabled: billingEnabled ?? this.billingEnabled,
      perDayRate: perDayRate ?? this.perDayRate,
      servedMeals: servedMeals ?? this.servedMeals,
      mealTimings: mealTimings ?? this.mealTimings,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner_id': ownerId,
      'mess_name': messName,
      'invite_code': inviteCode,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'billing_enabled': billingEnabled,
      if (perDayRate != null) 'per_day_rate': perDayRate,
      'served_meals': servedMeals,
      if (mealTimings != null) 'meal_timings': mealTimings,
      // Legacy compatibility keys
      'messId': id,
      'name': messName,
      'createdBy': ownerId,
      'billingEnabled': billingEnabled,
      'perDayRate': perDayRate,
    };
  }

  factory MessModel.fromMap(Map<String, dynamic> map) {
    DateTime? parsedCreatedAt;
    final rawDate = map['created_at'] ?? map['createdAt'];
    if (rawDate != null) {
      if (rawDate is DateTime) {
        parsedCreatedAt = rawDate;
      } else if (rawDate is String) {
        parsedCreatedAt = DateTime.tryParse(rawDate);
      }
    }

    final rawRate = map['per_day_rate'] ?? map['perDayRate'];
    double? parsedRate;
    if (rawRate is num) {
      parsedRate = rawRate.toDouble();
    } else if (rawRate is String) {
      parsedRate = double.tryParse(rawRate);
    }

    return MessModel(
      id: (map['id'] ?? map['messId'] ?? '').toString(),
      ownerId: (map['owner_id'] ?? map['createdBy'] ?? map['ownerId'] ?? '').toString(),
      messName: (map['mess_name'] ?? map['name'] ?? map['messName'] ?? '').toString(),
      inviteCode: (map['invite_code'] ?? map['inviteCode'] ?? '').toString(),
      createdAt: parsedCreatedAt,
      billingEnabled: (map['billing_enabled'] ?? map['billingEnabled'] ?? false) == true,
      perDayRate: parsedRate,
      servedMeals: List<String>.from(map['served_meals'] ?? const []),
      mealTimings: map['meal_timings'] != null ? Map<String, dynamic>.from(map['meal_timings']) : null,
    );
  }
}
