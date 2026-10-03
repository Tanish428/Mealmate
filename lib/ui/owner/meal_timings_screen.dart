import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/mess_model.dart';
import '../../data/repos/mess_repo.dart';

class MealTimingsScreen extends StatefulWidget {
  final MessRepository? messRepo;
  final MessModel? currentMess;

  const MealTimingsScreen({super.key, this.messRepo, this.currentMess});

  @override
  State<MealTimingsScreen> createState() => _MealTimingsScreenState();
}

class _MealTimingsScreenState extends State<MealTimingsScreen> {
  late final MessRepository _messRepo;
  bool _isLoading = true;
  bool _isSaving = false;
  String _messId = '';
  List<String> _servedMeals = ['breakfast', 'dinner'];

  // Default timings matching design
  final Map<String, TimeOfDay> _startTimes = {
    'breakfast': const TimeOfDay(hour: 6, minute: 45),
    'lunch': const TimeOfDay(hour: 12, minute: 30),
    'dinner': const TimeOfDay(hour: 19, minute: 0),
  };

  final Map<String, TimeOfDay> _endTimes = {
    'breakfast': const TimeOfDay(hour: 9, minute: 0),
    'lunch': const TimeOfDay(hour: 14, minute: 30),
    'dinner': const TimeOfDay(hour: 20, minute: 30),
  };

  final Map<String, TimeOfDay> _cutoffTimes = {
    'breakfast': const TimeOfDay(hour: 5, minute: 0),
    'lunch': const TimeOfDay(hour: 10, minute: 0),
    'dinner': const TimeOfDay(hour: 16, minute: 0),
  };

  @override
  void initState() {
    super.initState();
    _messRepo = widget.messRepo ?? MessRepository();
    _loadTimings();
  }

  Future<void> _loadTimings() async {
    try {
      if (widget.currentMess != null) {
        _messId = widget.currentMess!.id;
        if (widget.currentMess!.servedMeals.isNotEmpty) {
          _servedMeals = widget.currentMess!.servedMeals.map((e) => e.toLowerCase()).toList();
        }
        final rawTimings = widget.currentMess!.mealTimings;
        if (rawTimings != null) {
          for (final entry in rawTimings.entries) {
            final meal = entry.key.toString().toLowerCase();
            final timing = entry.value as Map?;
            if (timing != null) {
              if (timing['start'] != null) {
                _startTimes[meal] = _parseTimeOfDay(timing['start'].toString(), _startTimes[meal]!);
              }
              if (timing['end'] != null) {
                _endTimes[meal] = _parseTimeOfDay(timing['end'].toString(), _endTimes[meal]!);
              }
              if (timing['cutoff'] != null) {
                _cutoffTimes[meal] = _parseTimeOfDay(timing['cutoff'].toString(), _cutoffTimes[meal]!);
              }
            }
          }
        }
      } else {
        final details = await _messRepo.getOwnerMessDetails();
        if (details != null && mounted) {
          _messId = details['id']?.toString() ?? '';
          final rawMeals = details['served_meals'];
          if (rawMeals is List && rawMeals.isNotEmpty) {
            _servedMeals = rawMeals.map((e) => e.toString().toLowerCase()).toList();
          }

          final rawTimings = details['meal_timings'];
          if (rawTimings is Map) {
            for (final entry in rawTimings.entries) {
              final meal = entry.key.toString().toLowerCase();
              final timing = entry.value as Map?;
              if (timing != null) {
                if (timing['start'] != null) {
                  _startTimes[meal] = _parseTimeOfDay(timing['start'].toString(), _startTimes[meal]!);
                }
                if (timing['end'] != null) {
                  _endTimes[meal] = _parseTimeOfDay(timing['end'].toString(), _endTimes[meal]!);
                }
                if (timing['cutoff'] != null) {
                  _cutoffTimes[meal] = _parseTimeOfDay(timing['cutoff'].toString(), _cutoffTimes[meal]!);
                }
              }
            }
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  TimeOfDay _parseTimeOfDay(String timeStr, TimeOfDay fallback) {
    if (!timeStr.contains(':')) return fallback;
    final parts = timeStr.split(':');
    final h = int.tryParse(parts[0]) ?? fallback.hour;
    final m = int.tryParse(parts[1]) ?? fallback.minute;
    return TimeOfDay(hour: h, minute: m);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hourOfPeriod = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minuteStr = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hourOfPeriod:$minuteStr $period';
  }

  String _timeOfDayTo24h(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime({
    required BuildContext context,
    required String meal,
    required String type, // 'start', 'end', or 'cutoff'
  }) async {
    final TimeOfDay initialTime;
    if (type == 'start') {
      initialTime = _startTimes[meal] ?? const TimeOfDay(hour: 7, minute: 0);
    } else if (type == 'end') {
      initialTime = _endTimes[meal] ?? const TimeOfDay(hour: 9, minute: 0);
    } else {
      initialTime = _cutoffTimes[meal] ?? const TimeOfDay(hour: 5, minute: 0);
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFBA2D1D),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E1E1E),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        if (type == 'start') {
          _startTimes[meal] = picked;
        } else if (type == 'end') {
          _endTimes[meal] = picked;
        } else {
          _cutoffTimes[meal] = picked;
        }
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_messId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mess details not found. Please try again.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final Map<String, dynamic> timings = {};
      for (final meal in _servedMeals) {
        final start = _startTimes[meal] ?? const TimeOfDay(hour: 7, minute: 0);
        final end = _endTimes[meal] ?? const TimeOfDay(hour: 9, minute: 0);
        final cutoff = _cutoffTimes[meal] ?? const TimeOfDay(hour: 5, minute: 0);

        timings[meal] = {
          'start': _timeOfDayTo24h(start),
          'end': _timeOfDayTo24h(end),
          'cutoff': _timeOfDayTo24h(cutoff),
        };
      }

      await _messRepo.updateMealTimings(messId: _messId, timings: timings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal timings updated successfully!')),
        );
        context.pop(timings);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save timings: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context, textTheme),
                    const SizedBox(height: 24.0),
                    ..._servedMeals.map((meal) => _buildMealCard(context, meal, textTheme)),
                    const SizedBox(height: 16.0),
                    _buildSaveButton(),
                    const SizedBox(height: 24.0),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TextTheme textTheme) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/owner/profile');
            }
          },
        ),
        const SizedBox(width: 16.0),
        Text(
          "Meal Timings & Cutoffs",
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(BuildContext context, String meal, TextTheme textTheme) {
    final displayName = meal[0].toUpperCase() + meal.substring(1);
    final startTime = _startTimes[meal] ?? const TimeOfDay(hour: 7, minute: 0);
    final endTime = _endTimes[meal] ?? const TimeOfDay(hour: 9, minute: 0);
    final cutoffTime = _cutoffTimes[meal] ?? const TimeOfDay(hour: 5, minute: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFCEDE9), // Soft pink/rose tint matching design
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 24.0),
          _buildTimingRow(
            label: "Serving Start Time",
            timeString: _formatTimeOfDay(startTime),
            onTap: () => _pickTime(context: context, meal: meal, type: 'start'),
          ),
          const SizedBox(height: 20.0),
          _buildTimingRow(
            label: "Serving End Time",
            timeString: _formatTimeOfDay(endTime),
            onTap: () => _pickTime(context: context, meal: meal, type: 'end'),
          ),
          const SizedBox(height: 20.0),
          _buildTimingRow(
            label: "Member Opt-Out Cutoff Time",
            timeString: _formatTimeOfDay(cutoffTime),
            onTap: () => _pickTime(context: context, meal: meal, type: 'cutoff'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingRow({
    required String label,
    required String timeString,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C2C2C),
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
            child: Text(
              timeString,
              style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w600,
                color: Color(0xFFBA2D1D),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 52.0,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF7EBE8), // Muted rose pill matching design
          foregroundColor: const Color(0xFF8C332A),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF8C332A),
                ),
              )
            : const Text(
                "Save Changes",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8C332A),
                ),
              ),
      ),
    );
  }
}
