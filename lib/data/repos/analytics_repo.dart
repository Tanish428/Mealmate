import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/analytics_model.dart';
import '../models/surplus_allocation_model.dart';

/// Repository responsible for live operational and financial waste analytics calculations.
class AnalyticsRepository {
  final SupabaseClient? _client;

  AnalyticsRepository({SupabaseClient? client}) : _client = client;

  SupabaseClient get _dbClient => _client ?? Supabase.instance.client;

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Calculates real-time analytics for a mess across the specified timeframe.
  Future<AnalyticsModel> getAnalytics({
    required String messId,
    required String timeframe,
    int costPerMeal = 50,
    int messStandardCapacity = 100,
  }) async {
    final now = DateTime.now();
    late final DateTime startDate;
    late final DateTime endDate;

    switch (timeframe) {
      case 'This Week':
        // Monday to Sunday of the current week
        final daysFromMon = now.weekday - 1;
        startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysFromMon));
        endDate = startDate.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        break;

      case 'All Time':
        // 6 months window
        startDate = DateTime(now.year, now.month - 5, 1);
        endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;

      case 'This Month':
      default:
        // 1st of month to end of month
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
    }

    try {
      final startStr = _formatDate(startDate);
      final endStr = _formatDate(endDate);

      // 1. Fetch meal prep records
      final prepRecordsRes = await _dbClient
          .from('meal_prep_records')
          .select()
          .eq('mess_id', messId)
          .gte('prep_date', startStr)
          .lte('prep_date', endStr)
          .order('prep_date', ascending: true);

      final List<dynamic> prepRows = prepRecordsRes;

      // 2. Fetch skips (opt-outs / ghost meals prevented)
      final skipsRes = await _dbClient
          .from('skips')
          .select('skip_date, meal_type')
          .eq('mess_id', messId)
          .gte('skip_date', startStr)
          .lte('skip_date', endStr);

      final List<dynamic> skipRows = skipsRes;

      // 3. Fetch completed allocations (status = 'collected')
      final allocationsRes = await _dbClient
          .from('surplus_allocations')
          .select('quantity, status, created_at')
          .eq('mess_id', messId)
          .eq('status', SurplusAllocationModel.statusCollected)
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      final List<dynamic> allocationRows = allocationsRes;

      // Compute aggregates
      int totalTarget = 0;
      int totalPrepared = 0;
      int totalServed = 0;
      int totalDiscarded = 0;

      final Map<String, int> servedByDayOfWeek = {};
      final Map<String, int> skipsByMealType = {};

      for (final r in prepRows) {
        final row = Map<String, dynamic>.from(r as Map);
        final target = (row['target_portions'] as num?)?.toInt() ?? 0;
        final prepared = (row['prepared_portions'] as num?)?.toInt() ?? 0;
        final served = (row['served_portions'] as num?)?.toInt() ?? 0;
        final discarded = (row['discarded_portions'] as num?)?.toInt() ?? 0;

        totalTarget += target;
        totalPrepared += prepared;
        totalServed += served;
        totalDiscarded += discarded;

        final rawDate = row['prep_date']?.toString();
        if (rawDate != null) {
          final parsed = DateTime.tryParse(rawDate);
          if (parsed != null) {
            final dayName = DateFormat('EEEE').format(parsed);
            final mealType = (row['meal_type']?.toString() ?? '').toLowerCase();
            final key = '$dayName (${mealType.isNotEmpty ? mealType[0].toUpperCase() + mealType.substring(1) : ''})';
            servedByDayOfWeek[key] = (servedByDayOfWeek[key] ?? 0) + served;
          }
        }
      }

      int totalDonated = 0;
      for (final a in allocationRows) {
        final row = Map<String, dynamic>.from(a as Map);
        final q = (row['quantity'] as num?)?.toInt() ?? 0;
        totalDonated += q;
      }

      for (final s in skipRows) {
        final row = Map<String, dynamic>.from(s as Map);
        final mealType = (row['meal_type']?.toString() ?? 'Dinner').trim();
        final normalized = mealType.isNotEmpty
            ? mealType[0].toUpperCase() + mealType.substring(1).toLowerCase()
            : 'Dinner';
        skipsByMealType[normalized] = (skipsByMealType[normalized] ?? 0) + 1;
      }

      final ghostMealsPrevented = skipRows.length;
      final totalCostSavedValue = ghostMealsPrevented * costPerMeal;
      final totalCostLost = totalDiscarded * costPerMeal;

      // Accuracy: ((Prepared - Discarded) / Prepared) * 100
      double prepAccuracy = 100.0;
      if (totalPrepared > 0) {
        prepAccuracy = ((totalPrepared - totalDiscarded) / totalPrepared) * 100.0;
        prepAccuracy = prepAccuracy.clamp(0.0, 100.0);
      }

      // Surplus recovery rate: Donated / (Donated + Discarded)
      double recoveryRate = 100.0;
      final totalLostOrDonated = totalDonated + totalDiscarded;
      if (totalLostOrDonated > 0) {
        recoveryRate = (totalDonated / totalLostOrDonated) * 100.0;
        recoveryRate = recoveryRate.clamp(0.0, 100.0);
      }

      // Food saved in kg (estimated 350g per meal saved from ghost meals + donations)
      final double totalFoodSavedKg = (ghostMealsPrevented + totalDonated) * 0.35;
      final String foodSavedString = '${totalFoodSavedKg.toStringAsFixed(totalFoodSavedKg >= 10 ? 0 : 1)} kg';

      // Most skipped meal
      String mostSkipped = 'Dinner';
      int maxSkips = -1;
      skipsByMealType.forEach((meal, count) {
        if (count > maxSkips) {
          maxSkips = count;
          mostSkipped = meal;
        }
      });

      // Busiest day
      String busiest = 'Sunday (Lunch)';
      int maxServed = -1;
      servedByDayOfWeek.forEach((dayMeal, count) {
        if (count > maxServed) {
          maxServed = count;
          busiest = dayMeal;
        }
      });

      // Average opt-outs string
      final daysDiff = math.max(1, endDate.difference(startDate).inDays + 1);
      final avgOptOutsPerDay = (ghostMealsPrevented / daysDiff).toStringAsFixed(1);
      final averageOptOuts = '$avgOptOutsPerDay members / day';

      // Generate trend points
      final trendPoints = _buildTrendPoints(
        timeframe: timeframe,
        startDate: startDate,
        endDate: endDate,
        prepRows: prepRows,
        defaultCapacity: messStandardCapacity,
      );

      final currencyFormatter = NumberFormat('#,##,###');

      return AnalyticsModel(
        timeframe: timeframe,
        prepAccuracyPercentage: double.parse(prepAccuracy.toStringAsFixed(1)),
        ghostMealsPrevented: ghostMealsPrevented,
        mostSkippedMeal: mostSkipped,
        busiestDay: busiest,
        totalFoodSaved: foodSavedString,
        totalCostSaved: '₹${currencyFormatter.format(totalCostSavedValue)}',
        totalCostSavedValue: totalCostSavedValue,
        totalCostLost: totalCostLost,
        surplusRecoveryRate: double.parse(recoveryRate.toStringAsFixed(1)),
        totalTargetPortions: totalTarget,
        totalPreparedPortions: totalPrepared,
        totalServedPortions: totalServed,
        totalDiscardedPortions: totalDiscarded,
        totalDonatedPortions: totalDonated,
        totalMealSessions: prepRows.length,
        averageOptOuts: averageOptOuts,
        weeklyTrend: trendPoints,
      );
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to compute analytics: $e');
    }
  }

  List<WeeklyTrendPoint> _buildTrendPoints({
    required String timeframe,
    required DateTime startDate,
    required DateTime endDate,
    required List<dynamic> prepRows,
    required int defaultCapacity,
  }) {
    switch (timeframe) {
      case 'This Week':
        // Mon - Sun (7 points)
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final Map<int, List<Map<String, dynamic>>> byWeekday = {};
        for (final r in prepRows) {
          final row = Map<String, dynamic>.from(r as Map);
          final rawDate = row['prep_date']?.toString();
          if (rawDate != null) {
            final p = DateTime.tryParse(rawDate);
            if (p != null) {
              byWeekday.putIfAbsent(p.weekday, () => []).add(row);
            }
          }
        }

        return List.generate(7, (i) {
          final weekday = i + 1; // 1 = Monday
          final rows = byWeekday[weekday] ?? [];
          double totalPrep = 0;
          double totalTarget = 0;
          for (final row in rows) {
            totalPrep += (row['prepared_portions'] as num?)?.toDouble() ?? 0;
            totalTarget += (row['target_portions'] as num?)?.toDouble() ?? 0;
          }
          final capacity = totalTarget > 0 ? totalTarget : defaultCapacity.toDouble();
          return WeeklyTrendPoint(
            label: days[i],
            standardCapacity: capacity,
            actualPrepared: totalPrep,
          );
        });

      case 'All Time':
        // Last 6 months (Jan, Feb, etc.)
        final now = DateTime.now();
        return List.generate(6, (i) {
          final monthDate = DateTime(now.year, now.month - 5 + i, 1);
          final monthLabel = DateFormat('MMM').format(monthDate);
          double totalPrep = 0;
          double totalTarget = 0;
          for (final r in prepRows) {
            final row = Map<String, dynamic>.from(r as Map);
            final rawDate = row['prep_date']?.toString();
            if (rawDate != null) {
              final p = DateTime.tryParse(rawDate);
              if (p != null && p.year == monthDate.year && p.month == monthDate.month) {
                totalPrep += (row['prepared_portions'] as num?)?.toDouble() ?? 0;
                totalTarget += (row['target_portions'] as num?)?.toDouble() ?? 0;
              }
            }
          }
          final capacity = totalTarget > 0 ? totalTarget : defaultCapacity.toDouble();
          return WeeklyTrendPoint(
            label: monthLabel,
            standardCapacity: capacity,
            actualPrepared: totalPrep,
          );
        });

      case 'This Month':
      default:
        // 4 weeks breakdown
        return List.generate(4, (i) {
          final weekStartDay = (i * 7) + 1;
          final weekEndDay = (i == 3) ? 31 : (i + 1) * 7;
          double totalPrep = 0;
          double totalTarget = 0;

          for (final r in prepRows) {
            final row = Map<String, dynamic>.from(r as Map);
            final rawDate = row['prep_date']?.toString();
            if (rawDate != null) {
              final p = DateTime.tryParse(rawDate);
              if (p != null && p.day >= weekStartDay && p.day <= weekEndDay) {
                totalPrep += (row['prepared_portions'] as num?)?.toDouble() ?? 0;
                totalTarget += (row['target_portions'] as num?)?.toDouble() ?? 0;
              }
            }
          }
          final capacity = totalTarget > 0 ? totalTarget : defaultCapacity.toDouble();
          return WeeklyTrendPoint(
            label: 'Week ${i + 1}',
            standardCapacity: capacity,
            actualPrepared: totalPrep,
          );
        });
    }
  }
}
