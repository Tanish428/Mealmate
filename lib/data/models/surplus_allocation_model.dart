class SurplusAllocationModel {
  static const String statusPending = 'pending';
  static const String statusCollected = 'collected';
  static const String statusCancelled = 'cancelled';

  final String id;
  final String messId;
  final String mealPrepRecordId;
  final String? partnerId;
  final String? partnerName;
  final int quantity;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  SurplusAllocationModel({
    required this.id,
    required this.messId,
    required this.mealPrepRecordId,
    this.partnerId,
    this.partnerName,
    required this.quantity,
    this.status = statusPending,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Whether the allocation is currently active (reserves surplus portions).
  /// Both pending and collected allocations consume surplus capacity.
  bool get isActive => status == statusPending || status == statusCollected;

  /// Crucial rule: ONLY collected allocations count as completed donations.
  /// Notifications and pending allocations are NOT completed donations.
  bool get isCompletedDonation => status == statusCollected;

  bool get isPending => status == statusPending;
  bool get isCancelled => status == statusCancelled;

  factory SurplusAllocationModel.fromJson(Map<dynamic, dynamic> json) {
    final createdAtRaw = json['created_at'];
    final updatedAtRaw = json['updated_at'];

    // If joined partner record is present
    String? resolvedPartnerName;
    if (json['donation_partners'] is Map) {
      resolvedPartnerName = json['donation_partners']['name']?.toString();
    } else if (json['partner_name'] != null) {
      resolvedPartnerName = json['partner_name']?.toString();
    }

    return SurplusAllocationModel(
      id: json['id']?.toString() ?? '',
      messId: json['mess_id']?.toString() ?? '',
      mealPrepRecordId: json['meal_prep_record_id']?.toString() ?? '',
      partnerId: json['partner_id']?.toString(),
      partnerName: resolvedPartnerName,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString().toLowerCase() ?? statusPending,
      notes: json['notes']?.toString(),
      createdAt: createdAtRaw != null ? DateTime.parse(createdAtRaw.toString()) : DateTime.now(),
      updatedAt: updatedAtRaw != null ? DateTime.parse(updatedAtRaw.toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'mess_id': messId,
      'meal_prep_record_id': mealPrepRecordId,
      if (partnerId != null) 'partner_id': partnerId,
      'quantity': quantity,
      'status': status,
      if (notes != null) 'notes': notes,
    };
  }

  SurplusAllocationModel copyWith({
    String? id,
    String? messId,
    String? mealPrepRecordId,
    String? partnerId,
    String? partnerName,
    int? quantity,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SurplusAllocationModel(
      id: id ?? this.id,
      messId: messId ?? this.messId,
      mealPrepRecordId: mealPrepRecordId ?? this.mealPrepRecordId,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
