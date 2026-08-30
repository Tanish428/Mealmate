class MessModel {
  final String messId;
  final String name;
  final String createdBy;
  final String inviteCode;
  final bool billingEnabled;
  final double? perDayRate;

  const MessModel({
    required this.messId,
    required this.name,
    required this.createdBy,
    required this.inviteCode,
    required this.billingEnabled,
    this.perDayRate,
  });

  MessModel copyWith({
    String? messId,
    String? name,
    String? createdBy,
    String? inviteCode,
    bool? billingEnabled,
    double? perDayRate,
  }) {
    return MessModel(
      messId: messId ?? this.messId,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      inviteCode: inviteCode ?? this.inviteCode,
      billingEnabled: billingEnabled ?? this.billingEnabled,
      perDayRate: perDayRate ?? this.perDayRate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messId': messId,
      'name': name,
      'createdBy': createdBy,
      'inviteCode': inviteCode,
      'billingEnabled': billingEnabled,
      'perDayRate': perDayRate,
    };
  }

  factory MessModel.fromMap(Map<String, dynamic> map) {
    return MessModel(
      messId: map['messId'] as String,
      name: map['name'] as String,
      createdBy: map['createdBy'] as String,
      inviteCode: map['inviteCode'] as String,
      billingEnabled: map['billingEnabled'] as bool? ?? false,
      perDayRate: map['perDayRate'] as double?,
    );
  }
}