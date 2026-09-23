class SkipModel {
  final String id;
  final String messId;
  final String memberId;
  final DateTime skipDate;
  final String mealType;
  final DateTime createdAt;

  SkipModel({
    required this.id,
    required this.messId,
    required this.memberId,
    required this.skipDate,
    required this.mealType,
    required this.createdAt,
  });

  factory SkipModel.fromJson(Map<dynamic, dynamic> json) {
    return SkipModel(
      id: json['id'] as String,
      messId: json['mess_id'] as String,
      memberId: json['member_id'] as String,
      skipDate: DateTime.parse(json['skip_date'] as String),
      mealType: json['meal_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mess_id': messId,
      'member_id': memberId,
      'skip_date': skipDate.toIso8601String(),
      'meal_type': mealType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
