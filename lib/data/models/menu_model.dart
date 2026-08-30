class MenuModel {
  final String menuId;
  final String messId;
  final DateTime date;
  final List<Map<String, dynamic>> breakfastItems;
  final List<Map<String, dynamic>> lunchItems;
  final List<Map<String, dynamic>> dinnerItems;

  const MenuModel({
    required this.menuId,
    required this.messId,
    required this.date,
    required this.breakfastItems,
    required this.lunchItems,
    required this.dinnerItems,
  });

  MenuModel copyWith({
    String? menuId,
    String? messId,
    DateTime? date,
    List<Map<String, dynamic>>? breakfastItems,
    List<Map<String, dynamic>>? lunchItems,
    List<Map<String, dynamic>>? dinnerItems,
  }) {
    return MenuModel(
      menuId: menuId ?? this.menuId,
      messId: messId ?? this.messId,
      date: date ?? this.date,
      breakfastItems: breakfastItems ?? this.breakfastItems,
      lunchItems: lunchItems ?? this.lunchItems,
      dinnerItems: dinnerItems ?? this.dinnerItems,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'menuId': menuId,
      'messId': messId,
      'date': date,
      'breakfastItems': breakfastItems,
      'lunchItems': lunchItems,
      'dinnerItems': dinnerItems,
    };
  }

  factory MenuModel.fromMap(Map<String, dynamic> map) {
    // Parsing safety check: convert Firestore Timestamp to Dart DateTime
    final dynamic rawDate = map['date'];
    DateTime parsedDate;
    if (rawDate != null && rawDate.runtimeType.toString() == 'Timestamp') {
      // Handle Firestore Timestamp (resolved dynamically)
      parsedDate = (rawDate as dynamic).toDate();
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate is String) {
      parsedDate = DateTime.parse(rawDate);
    } else {
      parsedDate = DateTime.now();
    }

    return MenuModel(
      menuId: map['menuId'] as String,
      messId: map['messId'] as String,
      date: parsedDate,
      breakfastItems: map['breakfastItems'] != null
          ? List<Map<String, dynamic>>.from(
              (map['breakfastItems'] as List).map((e) => Map<String, dynamic>.from(e)),
            )
          : <Map<String, dynamic>>[],
      lunchItems: map['lunchItems'] != null
          ? List<Map<String, dynamic>>.from(
              (map['lunchItems'] as List).map((e) => Map<String, dynamic>.from(e)),
            )
          : <Map<String, dynamic>>[],
      dinnerItems: map['dinnerItems'] != null
          ? List<Map<String, dynamic>>.from(
              (map['dinnerItems'] as List).map((e) => Map<String, dynamic>.from(e)),
            )
          : <Map<String, dynamic>>[],
    );
  }
}
