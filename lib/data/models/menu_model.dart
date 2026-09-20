class MenuModel {
  final String id;
  final String messId;
  final DateTime date;
  final String? mealType;
  final List<dynamic> items;

  // Legacy full-day meal item lists
  final List<Map<String, dynamic>> breakfastItems;
  final List<Map<String, dynamic>> lunchItems;
  final List<Map<String, dynamic>> dinnerItems;

  const MenuModel({
    required this.id,
    required this.messId,
    required this.date,
    this.mealType,
    this.items = const [],
    this.breakfastItems = const [],
    this.lunchItems = const [],
    this.dinnerItems = const [],
  });

  // Backward compatibility getters
  String get menuId => id;
  String get menuDate => date.toIso8601String().split('T')[0];

  MenuModel copyWith({
    String? id,
    String? messId,
    DateTime? date,
    String? mealType,
    List<dynamic>? items,
    List<Map<String, dynamic>>? breakfastItems,
    List<Map<String, dynamic>>? lunchItems,
    List<Map<String, dynamic>>? dinnerItems,
    String? menuId,
  }) {
    return MenuModel(
      id: id ?? menuId ?? this.id,
      messId: messId ?? this.messId,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      items: items ?? this.items,
      breakfastItems: breakfastItems ?? this.breakfastItems,
      lunchItems: lunchItems ?? this.lunchItems,
      dinnerItems: dinnerItems ?? this.dinnerItems,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mess_id': messId,
      'menu_date': menuDate,
      if (mealType != null) 'meal_type': mealType,
      'items': items,
      // Legacy compatibility keys
      'menuId': id,
      'date': date.toIso8601String(),
      'breakfastItems': breakfastItems,
      'lunchItems': lunchItems,
      'dinnerItems': dinnerItems,
    };
  }

  factory MenuModel.fromMap(Map<String, dynamic> map) {
    final dynamic rawDate = map['menu_date'] ?? map['date'];
    DateTime parsedDate;
    if (rawDate != null && rawDate.runtimeType.toString() == 'Timestamp') {
      parsedDate = (rawDate as dynamic).toDate();
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    final rawItems = map['items'];
    List<dynamic> parsedItems = [];
    if (rawItems is List) {
      parsedItems = rawItems;
    }

    List<Map<String, dynamic>> parseMapList(dynamic list) {
      if (list is List) {
        return list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return <Map<String, dynamic>>[];
    }

    return MenuModel(
      id: (map['id'] ?? map['menuId'] ?? '').toString(),
      messId: (map['mess_id'] ?? map['messId'] ?? '').toString(),
      date: parsedDate,
      mealType: (map['meal_type'] ?? map['mealType'])?.toString(),
      items: parsedItems,
      breakfastItems: parseMapList(map['breakfastItems']),
      lunchItems: parseMapList(map['lunchItems']),
      dinnerItems: parseMapList(map['dinnerItems']),
    );
  }
}
