import 'package:flutter/foundation.dart';

/// Represents a single data point in the preparation trend chart.
@immutable
class WeeklyTrendPoint {
  final String label;
  final double standardCapacity;
  final double actualPrepared;

  const WeeklyTrendPoint({
    required this.label,
    required this.standardCapacity,
    required this.actualPrepared,
  });

  WeeklyTrendPoint copyWith({
    String? label,
    double? standardCapacity,
    double? actualPrepared,
  }) {
    return WeeklyTrendPoint(
      label: label ?? this.label,
      standardCapacity: standardCapacity ?? this.standardCapacity,
      actualPrepared: actualPrepared ?? this.actualPrepared,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyTrendPoint &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          standardCapacity == other.standardCapacity &&
          actualPrepared == other.actualPrepared;

  @override
  int get hashCode =>
      label.hashCode ^ standardCapacity.hashCode ^ actualPrepared.hashCode;
}

/// Immutable data model representing operational and precision analytics.
@immutable
class AnalyticsModel {
  /// Forecasting / Preparation Accuracy percentage:
  /// ((Total Planned - Unused Surplus) / Total Planned) * 100
  final double prepAccuracyPercentage;

  /// Number of ghost meals prevented through proactive member opt-outs.
  final int ghostMealsPrevented;

  /// Meal type with the highest opt-out frequency (e.g., "Dinner").
  final String mostSkippedMeal;

  /// Day with the highest attendance/demand requirements (e.g., "Sunday (Lunch)").
  final String busiestDay;

  /// Active timeframe label (e.g., "This Week", "This Month", "All Time").
  final String timeframe;

  /// Total food saved during this timeframe (e.g., "32 kg", "128 kg").
  final String totalFoodSaved;

  /// Total mess cost saved during this timeframe (e.g., "₹3,800", "₹14,200").
  final String totalCostSaved;

  /// Numeric mess cost saved in INR.
  final int totalCostSavedValue;

  /// Numeric financial loss in INR due to discarded unserved food.
  final int totalCostLost;

  /// Surplus recovery rate: % of surplus portions successfully collected by donation partners.
  final double surplusRecoveryRate;

  /// Aggregate target portions planned.
  final int totalTargetPortions;

  /// Aggregate actual portions cooked.
  final int totalPreparedPortions;

  /// Aggregate actual portions served.
  final int totalServedPortions;

  /// Aggregate discarded portions.
  final int totalDiscardedPortions;

  /// Aggregate portions collected by donation partners.
  final int totalDonatedPortions;

  /// Total number of meal sessions recorded in this timeframe.
  final int totalMealSessions;

  /// Average daily or per-meal opt-outs.
  final String averageOptOuts;

  /// Trend data points for standard capacity vs. actual preparation.
  final List<WeeklyTrendPoint> weeklyTrend;

  const AnalyticsModel({
    required this.prepAccuracyPercentage,
    required this.ghostMealsPrevented,
    required this.mostSkippedMeal,
    required this.busiestDay,
    this.timeframe = 'This Month',
    this.totalFoodSaved = '128 kg',
    this.totalCostSaved = '₹14,200',
    this.totalCostSavedValue = 14200,
    this.totalCostLost = 0,
    this.surplusRecoveryRate = 100.0,
    this.totalTargetPortions = 0,
    this.totalPreparedPortions = 0,
    this.totalServedPortions = 0,
    this.totalDiscardedPortions = 0,
    this.totalDonatedPortions = 0,
    this.totalMealSessions = 0,
    this.averageOptOuts = '8 members / meal',
    this.weeklyTrend = const [],
  });

  AnalyticsModel copyWith({
    double? prepAccuracyPercentage,
    int? ghostMealsPrevented,
    String? mostSkippedMeal,
    String? busiestDay,
    String? timeframe,
    String? totalFoodSaved,
    String? totalCostSaved,
    int? totalCostSavedValue,
    int? totalCostLost,
    double? surplusRecoveryRate,
    int? totalTargetPortions,
    int? totalPreparedPortions,
    int? totalServedPortions,
    int? totalDiscardedPortions,
    int? totalDonatedPortions,
    int? totalMealSessions,
    String? averageOptOuts,
    List<WeeklyTrendPoint>? weeklyTrend,
  }) {
    return AnalyticsModel(
      prepAccuracyPercentage:
          prepAccuracyPercentage ?? this.prepAccuracyPercentage,
      ghostMealsPrevented: ghostMealsPrevented ?? this.ghostMealsPrevented,
      mostSkippedMeal: mostSkippedMeal ?? this.mostSkippedMeal,
      busiestDay: busiestDay ?? this.busiestDay,
      timeframe: timeframe ?? this.timeframe,
      totalFoodSaved: totalFoodSaved ?? this.totalFoodSaved,
      totalCostSaved: totalCostSaved ?? this.totalCostSaved,
      totalCostSavedValue: totalCostSavedValue ?? this.totalCostSavedValue,
      totalCostLost: totalCostLost ?? this.totalCostLost,
      surplusRecoveryRate: surplusRecoveryRate ?? this.surplusRecoveryRate,
      totalTargetPortions: totalTargetPortions ?? this.totalTargetPortions,
      totalPreparedPortions: totalPreparedPortions ?? this.totalPreparedPortions,
      totalServedPortions: totalServedPortions ?? this.totalServedPortions,
      totalDiscardedPortions:
          totalDiscardedPortions ?? this.totalDiscardedPortions,
      totalDonatedPortions: totalDonatedPortions ?? this.totalDonatedPortions,
      totalMealSessions: totalMealSessions ?? this.totalMealSessions,
      averageOptOuts: averageOptOuts ?? this.averageOptOuts,
      weeklyTrend: weeklyTrend ?? this.weeklyTrend,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsModel &&
          runtimeType == other.runtimeType &&
          prepAccuracyPercentage == other.prepAccuracyPercentage &&
          ghostMealsPrevented == other.ghostMealsPrevented &&
          mostSkippedMeal == other.mostSkippedMeal &&
          busiestDay == other.busiestDay &&
          timeframe == other.timeframe &&
          totalFoodSaved == other.totalFoodSaved &&
          totalCostSaved == other.totalCostSaved &&
          totalCostSavedValue == other.totalCostSavedValue &&
          totalCostLost == other.totalCostLost &&
          surplusRecoveryRate == other.surplusRecoveryRate &&
          totalTargetPortions == other.totalTargetPortions &&
          totalPreparedPortions == other.totalPreparedPortions &&
          totalServedPortions == other.totalServedPortions &&
          totalDiscardedPortions == other.totalDiscardedPortions &&
          totalDonatedPortions == other.totalDonatedPortions &&
          totalMealSessions == other.totalMealSessions &&
          averageOptOuts == other.averageOptOuts &&
          listEquals(weeklyTrend, other.weeklyTrend);

  @override
  int get hashCode =>
      prepAccuracyPercentage.hashCode ^
      ghostMealsPrevented.hashCode ^
      mostSkippedMeal.hashCode ^
      busiestDay.hashCode ^
      timeframe.hashCode ^
      totalFoodSaved.hashCode ^
      totalCostSaved.hashCode ^
      totalCostSavedValue.hashCode ^
      totalCostLost.hashCode ^
      surplusRecoveryRate.hashCode ^
      totalTargetPortions.hashCode ^
      totalPreparedPortions.hashCode ^
      totalServedPortions.hashCode ^
      totalDiscardedPortions.hashCode ^
      totalDonatedPortions.hashCode ^
      totalMealSessions.hashCode ^
      averageOptOuts.hashCode ^
      weeklyTrend.hashCode;
}
