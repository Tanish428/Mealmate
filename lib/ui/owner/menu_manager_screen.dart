import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../data/repos/menu_repo.dart';

// --- Data Models ---
class DishModel {
  final String id;
  final String name;
  final bool isVegetarian;
  final bool hasDessert;
  final String? imageUrl;

  DishModel({
    required this.id,
    required this.name,
    required this.isVegetarian,
    this.hasDessert = false,
    this.imageUrl,
  });

  DishModel copyWith({
    String? id,
    String? name,
    bool? isVegetarian,
    bool? hasDessert,
    String? imageUrl,
  }) {
    return DishModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      hasDessert: hasDessert ?? this.hasDessert,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class MealSlotModel {
  final String id;
  final String title;
  final String timeRange;
  final bool isAvailable;
  final IconData iconData;
  final List<DishModel> dishes;

  MealSlotModel({
    required this.id,
    required this.title,
    required this.timeRange,
    required this.isAvailable,
    required this.iconData,
    required this.dishes,
  });

  MealSlotModel copyWith({
    String? id,
    String? title,
    String? timeRange,
    bool? isAvailable,
    IconData? iconData,
    List<DishModel>? dishes,
  }) {
    return MealSlotModel(
      id: id ?? this.id,
      title: title ?? this.title,
      timeRange: timeRange ?? this.timeRange,
      isAvailable: isAvailable ?? this.isAvailable,
      iconData: iconData ?? this.iconData,
      dishes: dishes ?? this.dishes,
    );
  }
}

// --- Main Screen ---
class MenuManagerScreen extends StatefulWidget {
  const MenuManagerScreen({super.key});

  @override
  State<MenuManagerScreen> createState() => _MenuManagerScreenState();
}

class _MenuManagerScreenState extends State<MenuManagerScreen> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDates;
  List<MealSlotModel> _currentSlots = [];

  List<MealSlotModel> _createEmptySlots() {
    return [
      MealSlotModel(
        id: '1',
        title: 'Breakfast',
        timeRange: '7:30 AM - 9:30 AM',
        isAvailable: true,
        iconData: Icons.wb_sunny_outlined,
        dishes: [],
      ),
      MealSlotModel(
        id: '2',
        title: 'Lunch',
        timeRange: '12:30 PM - 2:30 PM',
        isAvailable: true,
        iconData: Icons.restaurant,
        dishes: [],
      ),
      MealSlotModel(
        id: '3',
        title: 'Dinner',
        timeRange: '7:30 PM - 9:30 PM',
        isAvailable: true,
        iconData: Icons.nights_stay_outlined,
        dishes: [],
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _weekDates = List.generate(7, (index) => DateTime.now().add(Duration(days: index)));
    _fetchMenuForDate(_selectedDate);
  }

  Future<void> _fetchMenuForDate(DateTime date) async {
    
    try {
      final dbMenu = await MenuRepository().getMenuForDate(date);
      
      final emptySlots = _createEmptySlots();
      for (var slot in emptySlots) {
        final mealTypeStr = slot.title.toLowerCase();
        final meal = dbMenu.firstWhere(
          (m) => m['meal_type'].toString().toLowerCase() == mealTypeStr,
          orElse: () => {'items': []},
        );
        final rawItems = meal['items'] as List<dynamic>? ?? [];
        slot.dishes.addAll(rawItems.asMap().entries.map((entry) {
          final val = entry.value;
          String name = val.toString();
          bool isVeg = true;
          bool hasDessert = false;
          if (val is String && val.startsWith('{')) {
            try {
              final map = jsonDecode(val);
              name = map['name'] ?? name;
              isVeg = map['isVegetarian'] ?? true;
              hasDessert = map['hasDessert'] ?? false;
            } catch (_) {}
          } else if (val is Map) {
            name = val['name']?.toString() ?? name;
            isVeg = val['isVegetarian'] ?? true;
            hasDessert = val['hasDessert'] ?? false;
          }
          return DishModel(
            id: '${mealTypeStr}_${entry.key}',
            name: name,
            isVegetarian: isVeg,
            hasDessert: hasDessert,
          );
        }));
      }
      
      if (mounted) {
        setState(() {
          _currentSlots = emptySlots;
          
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentSlots = _createEmptySlots();
          
        });
      }
    }
  }

  List<MealSlotModel> get _mealSlots => _currentSlots;

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _fetchMenuForDate(date);
  }

  void _onToggleSlot(String id, bool value) {
    setState(() {
      final index = _currentSlots.indexWhere((slot) => slot.id == id);
      if (index != -1) {
        _currentSlots[index] = _currentSlots[index].copyWith(isAvailable: value);
      }
    });
  }

  void _addDish({
    required String slotId,
    required String name,
    required bool isVegetarian,
    required bool hasDessert,
  }) {
    setState(() {
      final slotIndex = _currentSlots.indexWhere((s) => s.id == slotId);
      if (slotIndex != -1) {
        final newDish = DishModel(
          id: 'dish_${DateTime.now().millisecondsSinceEpoch}',
          name: name.trim(),
          isVegetarian: isVegetarian,
          hasDessert: hasDessert,
        );
        final updatedDishes = List<DishModel>.from(_currentSlots[slotIndex].dishes)..add(newDish);
        _currentSlots[slotIndex] = _currentSlots[slotIndex].copyWith(dishes: updatedDishes);
      }
    });

    final slotTitle = _currentSlots.firstWhere((s) => s.id == slotId).title;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text("Added '$name' to $slotTitle")),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _editDish({
    required String slotId,
    required String dishId,
    required String name,
    required bool isVegetarian,
    required bool hasDessert,
  }) {
    setState(() {
      final slotIndex = _currentSlots.indexWhere((s) => s.id == slotId);
      if (slotIndex != -1) {
        final dishes = List<DishModel>.from(_currentSlots[slotIndex].dishes);
        final dishIndex = dishes.indexWhere((d) => d.id == dishId);
        if (dishIndex != -1) {
          dishes[dishIndex] = dishes[dishIndex].copyWith(
            name: name.trim(),
            isVegetarian: isVegetarian,
            hasDessert: hasDessert,
          );
          _currentSlots[slotIndex] = _currentSlots[slotIndex].copyWith(dishes: dishes);
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text("Updated '$name'")),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _deleteDish({
    required String slotId,
    required DishModel dish,
  }) async {
    setState(() {
      final slotIndex = _currentSlots.indexWhere((s) => s.id == slotId);
      if (slotIndex != -1) {
        final updatedDishes = List<DishModel>.from(_currentSlots[slotIndex].dishes)
          ..removeWhere((d) => d.id == dish.id);
        _currentSlots[slotIndex] = _currentSlots[slotIndex].copyWith(dishes: updatedDishes);
      }
    });
    
    // Also update the database for the deletion!
    final updatedSlot = _currentSlots.firstWhere((s) => s.id == slotId);
    final items = updatedSlot.dishes.map((d) => jsonEncode({'name': d.name, 'isVegetarian': d.isVegetarian, 'hasDessert': d.hasDessert})).toList();
    try {
      await MenuRepository().addMenu(
        date: _selectedDate,
        mealType: updatedSlot.title,
        items: items,
      );
    } catch (e) {
      // Ignored error handling for brevity, just keeping db sync
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.delete, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text("Removed '${dish.name}'")),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _confirmDeleteDish({
    required MealSlotModel slot,
    required DishModel dish,
  }) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: const Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red),
              SizedBox(width: 8),
              Text("Delete Dish", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text("Are you sure you want to remove '${dish.name}' from ${slot.title}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text("Cancel", style: TextStyle(color: Colors.grey.shade700)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                _deleteDish(slotId: slot.id, dish: dish);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _showAddOrEditDishDialog({
    required MealSlotModel slot,
    DishModel? existingDish,
  }) {
    final bool isEditing = existingDish != null;
    final nameController = TextEditingController(text: existingDish?.name ?? '');
    bool isVegetarian = existingDish?.isVegetarian ?? true;
    bool hasDessert = existingDish?.hasDessert ?? false;
    String? errorMessage;
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              actionsPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit : Icons.restaurant_menu,
                      color: Colors.red.shade700,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? "Edit Dish" : "Add Dish",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "for ${slot.title}",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dish Name Field
                      const Text(
                        "Dish Name",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      TextField(
                        controller: nameController,
                        autofocus: true,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: "e.g., Paneer Butter Masala",
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          errorText: errorMessage,
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
                          ),
                        ),
                        onChanged: (val) {
                          if (errorMessage != null && val.trim().isNotEmpty) {
                            setDialogState(() {
                              errorMessage = null;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 18.0),

                      // Food Category: Veg / Non-Veg
                      const Text(
                        "Dietary Preference",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          // Vegetarian Option
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setDialogState(() {
                                  isVegetarian = true;
                                });
                              },
                              borderRadius: BorderRadius.circular(10.0),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                                decoration: BoxDecoration(
                                  color: isVegetarian ? Colors.green.shade50 : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: isVegetarian ? Colors.green.shade700 : Colors.grey.shade300,
                                    width: isVegetarian ? 2.0 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.green.shade700, width: 1.5),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade700,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      "Veg",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isVegetarian ? FontWeight.bold : FontWeight.w500,
                                        color: isVegetarian ? Colors.green.shade800 : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12.0),

                          // Non-Vegetarian Option
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setDialogState(() {
                                  isVegetarian = false;
                                });
                              },
                              borderRadius: BorderRadius.circular(10.0),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                                decoration: BoxDecoration(
                                  color: !isVegetarian ? Colors.red.shade50 : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: !isVegetarian ? Colors.red.shade700 : Colors.grey.shade300,
                                    width: !isVegetarian ? 2.0 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.red.shade700, width: 1.5),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade700,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      "Non-Veg",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: !isVegetarian ? FontWeight.bold : FontWeight.w500,
                                        color: !isVegetarian ? Colors.red.shade800 : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18.0),

                      // Dessert Included Toggle
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Icon(Icons.cake_outlined, size: 18, color: Colors.red.shade700),
                            ),
                            const SizedBox(width: 10.0),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Dessert Included",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "Served with sweet or dessert",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: hasDessert,
                              onChanged: (val) {
                                setDialogState(() {
                                  hasDessert = val;
                                });
                              },
                              activeThumbColor: Colors.white,
                              activeTrackColor: Colors.red.shade700,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  ),
                  onPressed: isSaving ? null : () async {
                    final enteredName = nameController.text.trim();
                    if (enteredName.isEmpty) {
                      setDialogState(() {
                        errorMessage = "Please enter a dish name";
                      });
                      return;
                    }
                    setDialogState(() {
                      isSaving = true;
                    });
                    
                    try {
                      // First update local state
                      if (isEditing) {
                        _editDish(
                          slotId: slot.id,
                          dishId: existingDish.id,
                          name: enteredName,
                          isVegetarian: isVegetarian,
                          hasDessert: hasDessert,
                        );
                      } else {
                        _addDish(
                          slotId: slot.id,
                          name: enteredName,
                          isVegetarian: isVegetarian,
                          hasDessert: hasDessert,
                        );
                      }

                      // Now fetch the updated slot
                      final updatedSlot = _mealSlots.firstWhere((s) => s.id == slot.id);
                      final items = updatedSlot.dishes.map((d) => jsonEncode({'name': d.name, 'isVegetarian': d.isVegetarian, 'hasDessert': d.hasDessert})).toList();

                      await MenuRepository().addMenu(
                        date: _selectedDate,
                        mealType: updatedSlot.title,
                        items: items,
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Menu saved successfully!'), backgroundColor: Colors.green),
                        );
                      }
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    } catch (e) {
                      setDialogState(() {
                        isSaving = false;
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error saving menu: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  icon: isSaving 
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Icon(isEditing ? Icons.check : Icons.add, size: 18),
                  label: Text(
                    isSaving ? "Saving..." : (isEditing ? "Save" : "Add Dish"),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MenuHeader(),
              const SizedBox(height: 24.0),
              
              _CalendarStrip(
                dates: _weekDates,
                selectedDate: _selectedDate,
                onDateSelected: _onDateSelected,
              ),
              const SizedBox(height: 24.0),
              
              _DateOverviewHeader(
                selectedDate: _selectedDate,
                slotCount: _mealSlots.length,
              ),
              const SizedBox(height: 16.0),
              
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _mealSlots.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16.0),
                itemBuilder: (context, index) {
                  final slot = _mealSlots[index];
                  return _MealCard(
                    slot: slot,
                    onToggle: (val) => _onToggleSlot(slot.id, val),
                    onAddDish: () => _showAddOrEditDishDialog(slot: slot),
                    onEditDish: (dish) => _showAddOrEditDishDialog(slot: slot, existingDish: dish),
                    onDeleteDish: (dish) => _confirmDeleteDish(slot: slot, dish: dish),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Components ---

class _MenuHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
            children: [
              const TextSpan(text: "Manage "),
              TextSpan(
                text: "Menu",
                style: TextStyle(color: Colors.red.shade700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          "Plan and update your daily meals",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }
}

class _CalendarStrip extends StatelessWidget {
  final List<DateTime> dates;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _CalendarStrip({
    required this.dates,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12.0),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;
              
          final dayName = DateFormat('E').format(date); // e.g., Mon
          final dayNumber = DateFormat('d').format(date); // e.g., 15

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 55,
              decoration: BoxDecoration(
                color: isSelected ? Colors.red.shade700 : Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: isSelected ? Colors.red.shade700 : Colors.grey.shade300,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white70 : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    dayNumber,
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DateOverviewHeader extends StatelessWidget {
  final DateTime selectedDate;
  final int slotCount;

  const _DateOverviewHeader({
    required this.selectedDate,
    required this.slotCount,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, d MMMM').format(selectedDate);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          formattedDate,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
        ),
        Text(
          "$slotCount meal slots",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  final MealSlotModel slot;
  final ValueChanged<bool> onToggle;
  final VoidCallback onAddDish;
  final ValueChanged<DishModel> onEditDish;
  final ValueChanged<DishModel> onDeleteDish;

  const _MealCard({
    required this.slot,
    required this.onToggle,
    required this.onAddDish,
    required this.onEditDish,
    required this.onDeleteDish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(slot.iconData, color: Colors.red.shade700, size: 20),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      slot.timeRange,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Switch(
                    value: slot.isAvailable,
                    onChanged: onToggle,
                    activeThumbColor: Colors.white,
                    activeTrackColor: Colors.red.shade700,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey.shade300,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: slot.isAvailable ? Colors.green.shade50 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      slot.isAvailable ? "Available" : "Not Available",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: slot.isAvailable ? Colors.green.shade700 : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          if (slot.isAvailable && slot.dishes.isNotEmpty) ...[
            const SizedBox(height: 16.0),
            const Divider(height: 1),
            const SizedBox(height: 12.0),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: slot.dishes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12.0),
              itemBuilder: (context, index) {
                final dish = slot.dishes[index];
                return _DishListItem(
                  dish: dish,
                  onEdit: () => onEditDish(dish),
                  onDelete: () => onDeleteDish(dish),
                );
              },
            ),
          ],

          if (slot.isAvailable && slot.dishes.isEmpty) ...[
            const SizedBox(height: 12.0),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 8.0),
                  Text(
                    "No dishes added yet for ${slot.title}",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (slot.isAvailable) ...[
            const SizedBox(height: 16.0),
            _AddDishButton(
              slotTitle: slot.title,
              onTap: onAddDish,
            ),
          ]
        ],
      ),
    );
  }
}

class _DishListItem extends StatelessWidget {
  final DishModel dish;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DishListItem({
    required this.dish,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Thumbnail
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: dish.isVegetarian ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: dish.imageUrl != null && dish.imageUrl!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(dish.imageUrl!, fit: BoxFit.cover),
                )
              : Icon(
                  Icons.restaurant_menu,
                  color: dish.isVegetarian ? Colors.green.shade700 : Colors.red.shade700,
                  size: 20,
                ),
        ),
        const SizedBox(width: 12.0),
        
        // Veg/Non-Veg Indicator
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            border: Border.all(
              color: dish.isVegetarian ? Colors.green.shade700 : Colors.red.shade700,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(2.0),
          ),
          child: Center(
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: dish.isVegetarian ? Colors.green.shade700 : Colors.red.shade700,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        
        // Dish Name & Optional Tag
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dish.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Text(
                    dish.isVegetarian ? "Veg" : "Non-Veg",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: dish.isVegetarian ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                  if (dish.hasDessert) ...[
                    const SizedBox(width: 6.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cake, size: 10, color: Colors.red.shade700),
                          const SizedBox(width: 3.0),
                          Text(
                            "Dessert Included",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        
        // Actions
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined, size: 20, color: Colors.blue.shade600),
              tooltip: "Edit Dish",
              onPressed: onEdit,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(4.0),
            ),
            const SizedBox(width: 4.0),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 20, color: Colors.red.shade700),
              tooltip: "Delete Dish",
              onPressed: onDelete,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(4.0),
            ),
          ],
        ),
      ],
    );
  }
}

class _AddDishButton extends StatelessWidget {
  final String slotTitle;
  final VoidCallback onTap;

  const _AddDishButton({
    required this.slotTitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: CustomPaint(
        painter: _DashedBorderPainter(color: Colors.red.shade300),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 18, color: Colors.red.shade700),
              const SizedBox(width: 4.0),
              Text(
                "Add Dish to $slotTitle",
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const double dashWidth = 5;
    const double dashSpace = 3;
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(8.0),
    );

    Path path = Path()..addRRect(rrect);
    Path dashedPath = Path();

    for (final pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dashedPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}



