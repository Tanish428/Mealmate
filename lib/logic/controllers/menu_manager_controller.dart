import 'package:flutter/material.dart';
import 'dart:convert';
import '../../data/repos/menu_repo.dart';

class DishItem {
  final String id;
  final String name;
  final bool isVegetarian;
  final bool hasDessert;

  DishItem({
    required this.id,
    required this.name,
    this.isVegetarian = true,
    this.hasDessert = false,
  });

  DishItem copyWith({
    String? id,
    String? name,
    bool? isVegetarian,
    bool? hasDessert,
  }) {
    return DishItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      hasDessert: hasDessert ?? this.hasDessert,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isVegetarian': isVegetarian,
      'hasDessert': hasDessert,
    };
  }

  factory DishItem.fromMap(Map<String, dynamic> map, {String? id}) {
    return DishItem(
      id: id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: (map['name'] ?? '').toString(),
      isVegetarian: map['isVegetarian'] as bool? ?? true,
      hasDessert: map['hasDessert'] as bool? ?? false,
    );
  }
}

class MenuManagerController extends ChangeNotifier {
  final MenuRepository _menuRepo;

  DateTime _selectedDate = DateTime.now();
  String _selectedMealSlot = 'breakfast'; // 'breakfast', 'lunch', 'dinner'
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  // Meal dishes by slot
  final Map<String, List<DishItem>> _slotDishes = {
    'breakfast': [],
    'lunch': [],
    'dinner': [],
  };

  MenuManagerController({MenuRepository? menuRepo, bool autoLoad = true})
      : _menuRepo = menuRepo ?? MenuRepository() {
    if (autoLoad) {
      loadMenuForDate(_selectedDate);
    }
  }

  DateTime get selectedDate => _selectedDate;
  String get selectedMealSlot => _selectedMealSlot;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  List<DishItem> get currentSlotDishes => _slotDishes[_selectedMealSlot] ?? [];

  List<DishItem> getDishesForSlot(String slot) => _slotDishes[slot.toLowerCase()] ?? [];

  void setSelectedDate(DateTime date) {
    if (_selectedDate.year != date.year ||
        _selectedDate.month != date.month ||
        _selectedDate.day != date.day) {
      _selectedDate = date;
      loadMenuForDate(date);
    }
  }

  void setSelectedMealSlot(String slot) {
    final lower = slot.toLowerCase();
    if (_slotDishes.containsKey(lower) && _selectedMealSlot != lower) {
      _selectedMealSlot = lower;
      notifyListeners();
    }
  }

  void addDish({
    required String name,
    bool isVegetarian = true,
    bool hasDessert = false,
    String? slot,
  }) {
    final targetSlot = (slot ?? _selectedMealSlot).toLowerCase();
    if (name.trim().isEmpty) return;

    final dish = DishItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      isVegetarian: isVegetarian,
      hasDessert: hasDessert,
    );

    _slotDishes.putIfAbsent(targetSlot, () => []).add(dish);
    notifyListeners();
  }

  void removeDish(String dishId, {String? slot}) {
    final targetSlot = (slot ?? _selectedMealSlot).toLowerCase();
    _slotDishes[targetSlot]?.removeWhere((d) => d.id == dishId);
    notifyListeners();
  }

  void updateDish(DishItem updated, {String? slot}) {
    final targetSlot = (slot ?? _selectedMealSlot).toLowerCase();
    final list = _slotDishes[targetSlot];
    if (list != null) {
      final index = list.indexWhere((d) => d.id == updated.id);
      if (index != -1) {
        list[index] = updated;
        notifyListeners();
      }
    }
  }

  Future<void> loadMenuForDate(DateTime date) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final menuDataList = await _menuRepo.getMenuForDate(date);

      // Reset slots
      _slotDishes['breakfast'] = [];
      _slotDishes['lunch'] = [];
      _slotDishes['dinner'] = [];

      for (final menuRecord in menuDataList) {
        final mealType = menuRecord['meal_type']?.toString().toLowerCase();
        if (mealType != null && _slotDishes.containsKey(mealType)) {
          final rawItems = menuRecord['items'] as List<dynamic>? ?? [];
          final dishList = <DishItem>[];

          for (final raw in rawItems) {
            if (raw is Map) {
              dishList.add(DishItem.fromMap(Map<String, dynamic>.from(raw)));
            } else if (raw is String) {
              if (raw.startsWith('{')) {
                try {
                  final decoded = jsonDecode(raw);
                  dishList.add(DishItem.fromMap(Map<String, dynamic>.from(decoded)));
                  continue;
                } catch (_) {}
              }
              dishList.add(DishItem(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                name: raw,
                isVegetarian: true,
              ));
            }
          }
          _slotDishes[mealType] = dishList;
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load menu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveCurrentSlotMenu() async {
    await saveMenuForSlot(_selectedMealSlot);
  }

  Future<void> saveMenuForSlot(String slot) async {
    final targetSlot = slot.toLowerCase();
    final dishes = _slotDishes[targetSlot] ?? [];

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final itemsToSave = dishes.map((d) => jsonEncode(d.toMap())).toList();

      await _menuRepo.addMenu(
        date: _selectedDate,
        mealType: targetSlot,
        items: itemsToSave,
      );
    } catch (e) {
      _errorMessage = 'Failed to save menu: $e';
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> saveAllSlots() async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      for (final entry in _slotDishes.entries) {
        if (entry.value.isNotEmpty) {
          final itemsToSave = entry.value.map((d) => jsonEncode(d.toMap())).toList();
          await _menuRepo.addMenu(
            date: _selectedDate,
            mealType: entry.key,
            items: itemsToSave,
          );
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to save menus: $e';
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
