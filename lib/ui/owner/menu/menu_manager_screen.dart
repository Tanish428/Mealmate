import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  late List<MealSlotModel> _mealSlots;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _weekDates = List.generate(7, (index) => DateTime.now().add(Duration(days: index)));
    
    // Mock Data
    _mealSlots = [
      MealSlotModel(
        id: '1',
        title: 'Breakfast',
        timeRange: '7:30 AM - 9:30 AM',
        isAvailable: true,
        iconData: Icons.wb_sunny_outlined,
        dishes: [
          DishModel(id: 'd1', name: 'Aloo Paratha', isVegetarian: true),
          DishModel(id: 'd2', name: 'Masala Chai', isVegetarian: true),
        ],
      ),
      MealSlotModel(
        id: '2',
        title: 'Lunch',
        timeRange: '12:30 PM - 2:30 PM',
        isAvailable: true,
        iconData: Icons.restaurant,
        dishes: [
          DishModel(id: 'd3', name: 'Paneer Butter Masala', isVegetarian: true, hasDessert: true),
          DishModel(id: 'd4', name: 'Jeera Rice', isVegetarian: true),
        ],
      ),
      MealSlotModel(
        id: '3',
        title: 'Dinner',
        timeRange: '7:30 PM - 9:30 PM',
        isAvailable: false,
        iconData: Icons.nights_stay_outlined,
        dishes: [],
      ),
    ];
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _onToggleSlot(String id, bool value) {
    setState(() {
      final index = _mealSlots.indexWhere((slot) => slot.id == id);
      if (index != -1) {
        final slot = _mealSlots[index];
        _mealSlots[index] = MealSlotModel(
          id: slot.id,
          title: slot.title,
          timeRange: slot.timeRange,
          isAvailable: value,
          iconData: slot.iconData,
          dishes: slot.dishes,
        );
      }
    });
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
                  return _MealCard(
                    slot: _mealSlots[index],
                    onToggle: (val) => _onToggleSlot(_mealSlots[index].id, val),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
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
          ),
        ),
        Column(
          children: [
            InkWell(
              onTap: () {},
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: Colors.red.shade700),
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              "Add Meal",
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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

  const _MealCard({
    required this.slot,
    required this.onToggle,
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
                return _DishListItem(dish: slot.dishes[index]);
              },
            ),
          ],
          
          if (slot.isAvailable) ...[
            const SizedBox(height: 16.0),
            _AddDishButton(onTap: () {}),
          ]
        ],
      ),
    );
  }
}

class _DishListItem extends StatelessWidget {
  final DishModel dish;

  const _DishListItem({required this.dish});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Thumbnail
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: dish.imageUrl != null && dish.imageUrl!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(dish.imageUrl!, fit: BoxFit.cover),
                )
              : Icon(Icons.fastfood, color: Colors.grey.shade400, size: 20),
        ),
        const SizedBox(width: 12.0),
        
        // Veg/Non-Veg Indicator
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            border: Border.all(
              color: dish.isVegetarian ? Colors.green : Colors.red,
            ),
          ),
          child: Center(
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dish.isVegetarian ? Colors.green : Colors.red,
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
              if (dish.hasDessert) ...[
                const SizedBox(height: 4.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cake, size: 10, color: Colors.red.shade700),
                      const SizedBox(width: 4.0),
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
        ),
        
        // Actions
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined, size: 20, color: Colors.grey.shade500),
              onPressed: () {},
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(4.0),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 20, color: Colors.red.shade700),
              onPressed: () {},
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
  final VoidCallback onTap;

  const _AddDishButton({required this.onTap});

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
                "Add Dish",
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
