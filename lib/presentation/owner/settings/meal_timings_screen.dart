import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/mess_model.dart';
import '../../../data/repos/mess_repo.dart';
import 'package:intl/intl.dart';

class MealTimingsScreen extends StatefulWidget {
  final MessModel currentMess;

  const MealTimingsScreen({Key? key, required this.currentMess}) : super(key: key);

  @override
  State<MealTimingsScreen> createState() => _MealTimingsScreenState();
}

class _MealTimingsScreenState extends State<MealTimingsScreen> {
  final Map<String, Map<String, TimeOfDay>> _timings = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeTimings();
  }

  void _initializeTimings() {
    final mealTimings = widget.currentMess.mealTimings ?? {};
    for (String meal in widget.currentMess.servedMeals) {
      if (mealTimings.containsKey(meal)) {
        final data = mealTimings[meal] as Map<String, dynamic>;
        _timings[meal] = {
          'start': _parseTime(data['start'] ?? '00:00'),
          'end': _parseTime(data['end'] ?? '00:00'),
          'cutoff': _parseTime(data['cutoff'] ?? '00:00'),
        };
      } else {
        // Defaults if missing but served
        if (meal == 'breakfast') {
          _timings[meal] = {
            'start': const TimeOfDay(hour: 7, minute: 30),
            'end': const TimeOfDay(hour: 9, minute: 30),
            'cutoff': const TimeOfDay(hour: 7, minute: 0),
          };
        } else if (meal == 'lunch') {
          _timings[meal] = {
            'start': const TimeOfDay(hour: 12, minute: 30),
            'end': const TimeOfDay(hour: 14, minute: 30),
            'cutoff': const TimeOfDay(hour: 10, minute: 0),
          };
        } else if (meal == 'dinner') {
          _timings[meal] = {
            'start': const TimeOfDay(hour: 19, minute: 30),
            'end': const TimeOfDay(hour: 21, minute: 30),
            'cutoff': const TimeOfDay(hour: 19, minute: 0),
          };
        }
      }
    }
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _selectTime(String meal, String key) async {
    final initialTime = _timings[meal]?[key] ?? TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null && picked != initialTime) {
      setState(() {
        _timings[meal]![key] = picked;
      });
    }
  }

  bool _validateTimings() {
    for (String meal in _timings.keys) {
      final start = _timings[meal]!['start']!;
      final end = _timings[meal]!['end']!;
      final cutoff = _timings[meal]!['cutoff']!;

      final startMinutes = start.hour * 60 + start.minute;
      final endMinutes = end.hour * 60 + end.minute;
      final cutoffMinutes = cutoff.hour * 60 + cutoff.minute;

      if (cutoffMinutes > startMinutes) {
        _showError('For $meal, Cutoff time must be before or equal to Start Time.');
        return false;
      }
      if (startMinutes >= endMinutes) {
        _showError('For $meal, Start Time must be before End Time.');
        return false;
      }
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  Future<void> _saveChanges() async {
    if (!_validateTimings()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedTimings = <String, dynamic>{};
      for (String meal in _timings.keys) {
        updatedTimings[meal] = {
          'start': _formatTime(_timings[meal]!['start']!),
          'end': _formatTime(_timings[meal]!['end']!),
          'cutoff': _formatTime(_timings[meal]!['cutoff']!),
        };
      }

      final repo = MessRepository();
      await repo.updateMealTimings(
        messId: widget.currentMess.id,
        mealTimings: updatedTimings,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal timings saved successfully')),
      );
      context.pop(updatedTimings);
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to save changes: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatTimeForDisplay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Timings & Cutoffs'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (widget.currentMess.servedMeals.isEmpty)
                  const Center(child: Text("No served meals configured.")),
                ...widget.currentMess.servedMeals.map((meal) => _buildMealCard(meal)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Changes'),
                ),
              ],
            ),
    );
  }

  Widget _buildMealCard(String meal) {
    final mealCapitalized = '${meal[0].toUpperCase()}${meal.substring(1)}';
    if (!_timings.containsKey(meal)) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mealCapitalized,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildTimePickerRow(meal, 'start', 'Serving Start Time'),
            const SizedBox(height: 12),
            _buildTimePickerRow(meal, 'end', 'Serving End Time'),
            const SizedBox(height: 12),
            _buildTimePickerRow(meal, 'cutoff', 'Member Opt-Out Cutoff Time'),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerRow(String meal, String key, String label) {
    final time = _timings[meal]![key]!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        TextButton(
          onPressed: () => _selectTime(meal, key),
          child: Text(_formatTimeForDisplay(time)),
        ),
      ],
    );
  }
}
