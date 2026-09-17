class AnalyticsModel {
  final String totalFoodSaved;
  final String totalCostSaved;
  final String averageOptOuts;
  final String mostSkippedMeal;
  final String busiestDay;
  final List<double> weeklyStandardCapacity;
  final List<double> weeklyActualPrep;

  const AnalyticsModel({
    required this.totalFoodSaved,
    required this.totalCostSaved,
    required this.averageOptOuts,
    required this.mostSkippedMeal,
    required this.busiestDay,
    required this.weeklyStandardCapacity,
    required this.weeklyActualPrep,
  });
}
