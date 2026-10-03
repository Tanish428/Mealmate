import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/models.dart';
import '../../logic/controllers/surplus_controller.dart';
import '../common/custom_button.dart';
import '../common/custom_textfield.dart';

class SurplusAllocationScreen extends StatelessWidget {
  final SurplusController? controller;

  const SurplusAllocationScreen({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller != null) {
      return ChangeNotifierProvider<SurplusController>.value(
        value: controller!,
        child: const _SurplusAllocationView(),
      );
    }

    return ChangeNotifierProvider<SurplusController>(
      create: (_) => SurplusController(),
      child: const _SurplusAllocationView(),
    );
  }
}

class _SurplusAllocationView extends StatefulWidget {
  const _SurplusAllocationView();

  @override
  State<_SurplusAllocationView> createState() => _SurplusAllocationViewState();
}

class _SurplusAllocationViewState extends State<_SurplusAllocationView> {
  final TextEditingController _preparedController = TextEditingController();
  final TextEditingController _servedController = TextEditingController();
  final TextEditingController _sessionCostController = TextEditingController(text: '50');

  String? _lastLoadedRecordId;
  String? _lastLoadedMealKey;

  @override
  void dispose() {
    _preparedController.dispose();
    _servedController.dispose();
    _sessionCostController.dispose();
    super.dispose();
  }

  void _syncTextControllers(SurplusController controller) {
    final mealKey = '${controller.selectedDate.toIso8601String()}_${controller.selectedMeal}';
    final recordId = controller.currentRecord?.id;

    if (_lastLoadedMealKey != mealKey || _lastLoadedRecordId != recordId) {
      _lastLoadedMealKey = mealKey;
      _lastLoadedRecordId = recordId;

      if (controller.currentRecord != null) {
        _preparedController.text = controller.preparedPortions.toString();
        _servedController.text = controller.servedPortions.toString();
        if (controller.currentRecord!.costPerMeal != null) {
          _sessionCostController.text = controller.currentRecord!.costPerMeal.toString();
        } else {
          _sessionCostController.text = '50';
        }
      } else {
        // Crucial Rule: Do not prefill actual values from the planning target!
        _preparedController.text = '0';
        _servedController.text = '0';
        _sessionCostController.text = '50';
      }
    }
  }

  void _showNotificationSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade800 : Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SurplusController>(
      builder: (context, controller, _) {
        _syncTextControllers(controller);

        // Handle transient messages
        if (controller.errorMessage != null) {
          final error = controller.errorMessage!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showNotificationSnackBar(context, error, isError: true);
            controller.clearMessages();
          });
        } else if (controller.successMessage != null) {
          final msg = controller.successMessage!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showNotificationSnackBar(context, msg, isError: false);
            controller.clearMessages();
          });
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFDFBF7),
          body: SafeArea(
            child: controller.isLoading && controller.currentRecord == null && controller.partners.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC0392B)),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: controller.refresh,
                    color: const Color(0xFFC0392B),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context, controller),
                          const SizedBox(height: 20.0),
                          _buildDateAndMealSelector(context, controller),
                          const SizedBox(height: 16.0),
                          _buildPlannerTargetCard(context, controller),
                          const SizedBox(height: 16.0),
                          _buildSurplusLoggerCard(context, controller),
                          const SizedBox(height: 24.0),
                          _buildAllocationSection(context, controller),
                          const SizedBox(height: 24.0),
                          _buildDonationPartnersSection(context, controller),
                          const SizedBox(height: 24.0),
                          _buildAllocationHistorySection(context, controller),
                          const SizedBox(height: 24.0),
                          _buildImpactBanner(context, controller),
                          const SizedBox(height: 32.0),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Header
  // ---------------------------------------------------------------------------
  Widget _buildHeader(BuildContext context, SurplusController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => Navigator.maybePop(context),
          customBorder: const CircleBorder(),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, color: Colors.red.shade700),
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  children: [
                    const TextSpan(
                      text: "Surplus ",
                      style: TextStyle(color: Colors.black),
                    ),
                    TextSpan(
                      text: "Management",
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                "Give leftover food a second purpose",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.volunteer_activism, color: Colors.red.shade700, size: 22),
              const SizedBox(height: 2),
              const Text(
                "Good Food\nTomorrow",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Date and Meal Selector
  // ---------------------------------------------------------------------------
  Widget _buildDateAndMealSelector(BuildContext context, SurplusController controller) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final formattedDate = dateFormat.format(controller.selectedDate);
    final isToday = DateUtils.isSameDay(controller.selectedDate, DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: controller.selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 90)),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) {
                    controller.setDate(picked);
                  }
                },
                borderRadius: BorderRadius.circular(8.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 18, color: Colors.red.shade700),
                      const SizedBox(width: 8.0),
                      Text(
                        isToday ? "Today ($formattedDate)" : formattedDate,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(width: 4.0),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: controller.currentRecord != null ? Colors.green.shade50 : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  controller.currentRecord != null ? "Prep Recorded" : "Not Logged",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: controller.currentRecord != null ? Colors.green.shade800 : Colors.amber.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.servedMeals.map((meal) {
                final isSelected = controller.selectedMeal == meal;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      meal[0].toUpperCase() + meal.substring(1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey.shade800,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Colors.red.shade700,
                    backgroundColor: Colors.grey.shade100,
                    onSelected: (val) {
                      if (val) controller.setMeal(meal);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Planner Target Card (Visibly separated from actual cooked food)
  // ---------------------------------------------------------------------------
  Widget _buildPlannerTargetCard(BuildContext context, SurplusController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFD0DCE5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.assignment_outlined, color: Color(0xFF2C5E8A), size: 22),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Preparation Planner Target",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF1E3A5F),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD6E4F0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            controller.targetPortions > 0
                                ? "${controller.targetPortions} target"
                                : "No target",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A5F),
                            ),
                          ),
                        ),
                        if (controller.targetPortions > 0 && controller.preparedPortions > 0) ...[
                          const SizedBox(width: 6.0),
                          _buildVarianceBadge(controller),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  "Planning projection calculated by attendance headcount. Actual kitchen prepared & served portions are logged separately below.",
                  style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVarianceBadge(SurplusController controller) {
    final variance = controller.kitchenVariance;
    final status = controller.kitchenVarianceStatus;

    if (status == 'unlogged') return const SizedBox.shrink();

    final Color bgColor;
    final Color textColor;
    final String label;

    if (status == 'over') {
      bgColor = Colors.amber.shade100;
      textColor = Colors.amber.shade900;
      label = "+$variance Over-prep";
    } else if (status == 'under') {
      bgColor = Colors.blue.shade100;
      textColor = Colors.blue.shade900;
      label = "$variance Under-prep";
    } else {
      bgColor = Colors.green.shade100;
      textColor = Colors.green.shade900;
      label = "Exact Match";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Surplus Logger Card (Prepared, Served, Discarded, Surplus)
  // ---------------------------------------------------------------------------
  Widget _buildSurplusLoggerCard(BuildContext context, SurplusController controller) {
    final preparedVal = int.tryParse(_preparedController.text.trim()) ?? 0;
    final servedVal = int.tryParse(_servedController.text.trim()) ?? 0;
    final isInvalid = preparedVal < servedVal;
    final liveSurplus = isInvalid ? 0 : (preparedVal - servedVal);

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.restaurant_menu, color: Colors.red.shade700),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${controller.selectedMeal[0].toUpperCase()}${controller.selectedMeal.substring(1)} Kitchen Portions",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      "Enter actual quantities cooked and served",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),

          // Inputs for Prepared and Served
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Actual Prepared",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 6.0),
                    _buildPortionInputField(
                      controller: _preparedController,
                      hint: "Cooked",
                      onChanged: () => setState(() {}),
                      onDecrement: () {
                        final val = int.tryParse(_preparedController.text.trim()) ?? 0;
                        if (val > 0) {
                          _preparedController.text = (val - 1).toString();
                          setState(() {});
                        }
                      },
                      onIncrement: () {
                        final val = int.tryParse(_preparedController.text.trim()) ?? 0;
                        _preparedController.text = (val + 1).toString();
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Actual Served",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 6.0),
                    _buildPortionInputField(
                      controller: _servedController,
                      hint: "Served",
                      onChanged: () => setState(() {}),
                      onDecrement: () {
                        final val = int.tryParse(_servedController.text.trim()) ?? 0;
                        if (val > 0) {
                          _servedController.text = (val - 1).toString();
                          setState(() {});
                        }
                      },
                      onIncrement: () {
                        final val = int.tryParse(_servedController.text.trim()) ?? 0;
                        _servedController.text = (val + 1).toString();
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (isInvalid) ...[
            const SizedBox(height: 8.0),
            Text(
              "⚠️ Prepared portions ($preparedVal) cannot be less than served portions ($servedVal).",
              style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],

          const SizedBox(height: 16.0),

          // Session Baseline Cost per Meal (Option 2)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Cost Baseline (₹/plate)",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(width: 4.0),
                        Tooltip(
                          message: "Per-session procurement cost used for financial ROI & waste tracking",
                          child: Icon(Icons.info_outline, size: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6.0),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Text("₹", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: TextField(
                              controller: _sessionCostController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                hintText: "50",
                              ),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16.0),

          // Live Calculation Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Calculated Surplus",
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      "$liveSurplus portions",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: liveSurplus > 0 ? Colors.red.shade700 : Colors.black87,
                      ),
                    ),
                  ],
                ),
                Text(
                  "Prepared ($preparedVal) − Served ($servedVal)",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16.0),

          CustomButton(
            text: "Save Kitchen Portions",
            isLoading: controller.isSavingPrep,
            icon: Icons.assignment_turned_in,
            onPressed: isInvalid
                ? null
                : () async {
                    final prep = int.tryParse(_preparedController.text.trim()) ?? 0;
                    final serv = int.tryParse(_servedController.text.trim()) ?? 0;
                    final cost = int.tryParse(_sessionCostController.text.trim());
                    await controller.recordMealPrep(
                      preparedPortions: prep,
                      servedPortions: serv,
                      costPerMeal: cost,
                    );
                  },
          ),

          // Operational Summary if Record Exists
          if (controller.currentRecord != null) ...[
            const Divider(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Portions Breakdown",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                TextButton.icon(
                  onPressed: () => _showRecordDiscardedDialog(context, controller),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text("Log Discarded Food", style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: Colors.orange.shade800),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                _buildSummaryStatTile("Surplus", "${controller.calculatedSurplus}", Colors.blue.shade700),
                const SizedBox(width: 8.0),
                _buildSummaryStatTile("Discarded", "${controller.discardedPortions}", Colors.orange.shade800),
                const SizedBox(width: 8.0),
                _buildSummaryStatTile("Allocated", "${controller.activeAllocatedPortions}", Colors.purple.shade700),
                const SizedBox(width: 8.0),
                _buildSummaryStatTile("Available", "${controller.availablePortions}", Colors.green.shade800, isProminent: true),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPortionInputField({
    required TextEditingController controller,
    required String hint,
    required VoidCallback onChanged,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: onDecrement,
            visualDensity: VisualDensity.compact,
            color: Colors.grey.shade700,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              decoration: InputDecoration(
                isDense: true,
                hintText: hint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
              ),
              onChanged: (_) => onChanged(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: onIncrement,
            visualDensity: VisualDensity.compact,
            color: Colors.red.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStatTile(String label, String value, Color color, {bool isProminent = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: isProminent ? Colors.green.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: isProminent ? Colors.green.shade300 : Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4.0),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Allocation Creator Section
  // ---------------------------------------------------------------------------
  Widget _buildAllocationSection(BuildContext context, SurplusController controller) {
    if (controller.currentRecord == null) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey.shade600),
            const SizedBox(width: 12.0),
            const Expanded(
              child: Text(
                "Save kitchen portions above to unlock surplus food allocation.",
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
          ],
        ),
      );
    }

    if (controller.availablePortions <= 0) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green.shade700),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                controller.calculatedSurplus > 0
                    ? "All ${controller.calculatedSurplus} surplus portions for this meal have been allocated or discarded."
                    : "No surplus portions available for this meal.",
                style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    return _CreateAllocationCard(controller: controller);
  }

  // ---------------------------------------------------------------------------
  // 6. Food Donation Partners Section
  // ---------------------------------------------------------------------------
  Widget _buildDonationPartnersSection(BuildContext context, SurplusController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Food Donation Partners",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    "Registered organizations for surplus collection",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            OutlinedButton.icon(
              onPressed: () => _showAddPartnerDialog(context, controller),
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Add Partner", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade700),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14.0),

        if (controller.partners.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.handshake_outlined, size: 36, color: Colors.grey.shade400),
                const SizedBox(height: 8.0),
                const Text(
                  "No donation partners registered yet",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4.0),
                Text(
                  "Register an NGO, food bank, or volunteer group to allocate surplus.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12.0),
                ElevatedButton.icon(
                  onPressed: () => _showAddPartnerDialog(context, controller),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Register Partner Organization"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
              ],
            ),
          )
        else
          ...controller.partners.map((partner) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: _PartnerListItem(
                  partner: partner,
                  availablePortions: controller.availablePortions,
                  onAllocate: () => _showQuickAllocateDialog(context, controller, partner),
                  onEdit: () => _showEditPartnerDialog(context, controller, partner),
                  onDelete: () => _showDeletePartnerDialog(context, controller, partner),
                ),
              )),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 7. Allocation History Section
  // ---------------------------------------------------------------------------
  Widget _buildAllocationHistorySection(BuildContext context, SurplusController controller) {
    final allocations = controller.allocations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Allocation History",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 2.0),
        Text(
          "Track collection status for this meal",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 14.0),

        if (allocations.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Center(
              child: Text(
                "No allocations created for this meal yet.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ),
          )
        else
          ...allocations.map((alloc) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: _AllocationHistoryCard(
                  allocation: alloc,
                  isUpdating: controller.isUpdatingStatus,
                  onDispatch: () => _dispatchViaWhatsApp(context, alloc, controller),
                  onViewGatePass: () => _showGatePassDialog(context, alloc, controller),
                  onMarkCollected: () => controller.updateAllocationStatus(
                    allocationId: alloc.id,
                    status: SurplusAllocationModel.statusCollected,
                  ),
                  onCancel: () => controller.updateAllocationStatus(
                    allocationId: alloc.id,
                    status: SurplusAllocationModel.statusCancelled,
                  ),
                ),
              )),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 8. Impact Banner (Only completed/collected donations count!)
  // ---------------------------------------------------------------------------
  Widget _buildImpactBanner(BuildContext context, SurplusController controller) {
    final count = controller.monthlyDonatedMealsCount;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.volunteer_activism, color: Colors.green.shade800, size: 28),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count > 0 ? "$count meals donated this month" : "0 meals collected this month",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  "Small actions can help reduce food waste and feed someone in need. Only completed partner pickups are counted as donations.",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade900,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dialogs: Add Partner, Record Discarded, Quick Allocate
  // ---------------------------------------------------------------------------
  void _showAddPartnerDialog(BuildContext context, SurplusController controller) {
    final nameCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Register Donation Partner", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: nameCtrl,
                hintText: "Partner Organization Name *",
                prefixIcon: Icons.business,
              ),
              const SizedBox(height: 12.0),
              CustomTextField(
                controller: contactCtrl,
                hintText: "Contact Person (Optional)",
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 12.0),
              CustomTextField(
                controller: phoneCtrl,
                hintText: "Phone Number (Optional)",
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: 12.0),
              CustomTextField(
                controller: addressCtrl,
                hintText: "Address (Optional)",
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 12.0),
              CustomTextField(
                controller: notesCtrl,
                hintText: "Notes (Optional)",
                prefixIcon: Icons.notes,
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) {
                _showNotificationSnackBar(context, "Partner name is required", isError: true);
                return;
              }
              Navigator.pop(ctx);
              await controller.addPartner(
                name: name,
                contactPerson: contactCtrl.text.trim().isEmpty ? null : contactCtrl.text.trim(),
                contactPhone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                address: addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
                notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text("Register Partner"),
          ),
        ],
      ),
    );
  }

  void _showEditPartnerDialog(BuildContext context, SurplusController controller, DonationPartnerModel partner) {
    final nameCtrl = TextEditingController(text: partner.name);
    final contactCtrl = TextEditingController(text: partner.contactPerson ?? '');
    final phoneCtrl = TextEditingController(text: partner.contactPhone ?? '');
    final addressCtrl = TextEditingController(text: partner.address ?? '');
    final notesCtrl = TextEditingController(text: partner.notes ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Donation Partner", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: nameCtrl,
                hintText: "Partner Organization Name *",
                prefixIcon: Icons.business,
              ),
              const SizedBox(height: 12.0),
              CustomTextField(
                controller: contactCtrl,
                hintText: "Contact Person (Optional)",
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 12.0),
              CustomTextField(
                controller: phoneCtrl,
                hintText: "Phone Number (Optional)",
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: 12.0),
              CustomTextField(
                controller: addressCtrl,
                hintText: "Address (Optional)",
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 12.0),
              CustomTextField(
                controller: notesCtrl,
                hintText: "Notes (Optional)",
                prefixIcon: Icons.notes,
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) {
                _showNotificationSnackBar(context, "Partner name is required", isError: true);
                return;
              }
              Navigator.pop(ctx);
              await controller.updatePartner(
                partnerId: partner.id,
                name: name,
                contactPerson: contactCtrl.text.trim().isEmpty ? null : contactCtrl.text.trim(),
                contactPhone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                address: addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
                notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text("Save Changes"),
          ),
        ],
      ),
    );
  }

  void _showDeletePartnerDialog(BuildContext context, SurplusController controller, DonationPartnerModel partner) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8.0),
            Text("Delete Partner", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          "Are you sure you want to remove '${partner.name}'?\n\nIf this organization has previous donation records, it will be deactivated to preserve historical audit logs.",
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await controller.deletePartner(partnerId: partner.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text("Delete Partner"),
          ),
        ],
      ),
    );
  }

  void _showRecordDiscardedDialog(BuildContext context, SurplusController controller) {
    final discardedCtrl = TextEditingController(text: controller.discardedPortions.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Record Discarded Food", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Track spoiled, contaminated, or non-donated portions from this meal.",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16.0),
            CustomTextField(
              controller: discardedCtrl,
              hintText: "Discarded Portions",
              prefixIcon: Icons.delete_outline,
            ),
            const SizedBox(height: 8.0),
            Text(
              "Max allowable: ${controller.calculatedSurplus - controller.activeAllocatedPortions} portions",
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = int.tryParse(discardedCtrl.text.trim());
              if (val == null || val < 0) {
                _showNotificationSnackBar(context, "Enter a valid non-negative number", isError: true);
                return;
              }
              Navigator.pop(ctx);
              await controller.recordDiscardedPortions(val);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade800,
              foregroundColor: Colors.white,
            ),
            child: const Text("Save Discarded"),
          ),
        ],
      ),
    );
  }

  void _showQuickAllocateDialog(BuildContext context, SurplusController controller, DonationPartnerModel partner) {
    int quantity = 1;
    final maxAvailable = controller.availablePortions;
    final notesCtrl = TextEditingController();

    if (maxAvailable <= 0) {
      _showNotificationSnackBar(context, "No surplus portions available for allocation.", isError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Allocate to ${partner.name}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Available: $maxAvailable portions", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: quantity > 1
                        ? () => setDialogState(() => quantity--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.red.shade700,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "$quantity",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: quantity < maxAvailable
                        ? () => setDialogState(() => quantity++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                    color: Colors.red.shade700,
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              CustomTextField(
                controller: notesCtrl,
                hintText: "Pickup notes (Optional)",
                prefixIcon: Icons.notes,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await controller.createAllocation(
                  quantity: quantity,
                  partnerId: partner.id,
                  notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text("Allocate Surplus"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _dispatchViaWhatsApp(
    BuildContext context,
    SurplusAllocationModel allocation,
    SurplusController controller,
  ) async {
    final partner = controller.partners.where((p) => p.id == allocation.partnerId).firstOrNull;
    final partnerName = allocation.partnerName ?? partner?.name ?? 'Donation Partner';
    final phone = partner?.contactPhone?.replaceAll(RegExp(r'[^0-9+]'), '') ?? '';
    final messName = controller.messName.isNotEmpty ? controller.messName : 'Campus Mess';
    final meal = controller.selectedMeal.toUpperCase();
    final dateStr = DateFormat('MMM dd, yyyy').format(controller.selectedDate);
    final token = 'MM-${allocation.id.substring(0, math.min(8, allocation.id.length)).toUpperCase()}';

    final message = '''
*MEALMATE 🍲 SURPLUS DONATION DISPATCH*

Dear $partnerName,
Surplus food is packaged and ready for pickup:

*Mess:* $messName
*Meal:* $meal ($dateStr)
*Allocated Quantity:* ${allocation.quantity} portions
${partner?.address != null && partner!.address!.isNotEmpty ? "*Location:* ${partner.address}\n" : ""}*Gate Pass Token:* $token

Please arrive before service cutoff. Show this Gate Pass token at the campus gate.
'''.trim();

    final encoded = Uri.encodeComponent(message);
    final String urlString = phone.isNotEmpty
        ? 'https://wa.me/$phone?text=$encoded'
        : 'https://wa.me/?text=$encoded';

    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showNotificationSnackBar(context, 'Could not launch WhatsApp. Verification Token: $token');
        }
      }
    } catch (_) {
      if (context.mounted) {
        _showNotificationSnackBar(context, 'Error launching WhatsApp dispatch: token $token');
      }
    }
  }

  void _showGatePassDialog(
    BuildContext context,
    SurplusAllocationModel allocation,
    SurplusController controller,
  ) {
    final partner = controller.partners.where((p) => p.id == allocation.partnerId).firstOrNull;
    final partnerName = allocation.partnerName ?? partner?.name ?? 'Registered Partner';
    final messName = controller.messName.isNotEmpty ? controller.messName : 'Campus Mess';
    final token = 'MM-${allocation.id.substring(0, math.min(8, allocation.id.length)).toUpperCase()}';
    final meal = controller.selectedMeal.toUpperCase();
    final dateStr = DateFormat('EEE, MMM dd, yyyy').format(controller.selectedDate);
    final timeStr = DateFormat('h:mm a').format(allocation.createdAt);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Icon(Icons.verified_user, color: Colors.red.shade700, size: 20),
                      ),
                      const SizedBox(width: 10.0),
                      const Text(
                        "CAMPUS GATE PASS",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.8),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 24.0),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("PASS TOKEN: $token", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1.0)),
                    const SizedBox(height: 4.0),
                    Text("Facility: $messName", style: const TextStyle(fontSize: 12)),
                    Text("Date & Meal: $dateStr • $meal", style: const TextStyle(fontSize: 12)),
                    Text("Allocated To: $partnerName", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Text("Authorized Quantity: ${allocation.quantity} Portions", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                    Text("Issued At: $timeStr", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: allocation.isCompletedDonation ? Colors.green.shade50 : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: allocation.isCompletedDonation ? Colors.green.shade200 : Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      allocation.isCompletedDonation ? Icons.check_circle : Icons.schedule,
                      color: allocation.isCompletedDonation ? Colors.green.shade800 : Colors.amber.shade900,
                      size: 16,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        allocation.isCompletedDonation
                            ? "Verified & Collected. Authorized for exit."
                            : "Awaiting Arrival. Security: Verify vehicle / ID upon entry.",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: allocation.isCompletedDonation ? Colors.green.shade900 : Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                child: const Text("Close Pass"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Component: Create Allocation Card
// -----------------------------------------------------------------------------
class _CreateAllocationCard extends StatefulWidget {
  final SurplusController controller;

  const _CreateAllocationCard({required this.controller});

  @override
  State<_CreateAllocationCard> createState() => _CreateAllocationCardState();
}

class _CreateAllocationCardState extends State<_CreateAllocationCard> {
  int _allocationQuantity = 1;
  String? _selectedPartnerId;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final maxAvailable = controller.availablePortions;

    if (_allocationQuantity > maxAvailable && maxAvailable > 0) {
      _allocationQuantity = maxAvailable;
    }

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.red.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.volunteer_activism, color: Colors.red.shade700, size: 20),
              const SizedBox(width: 8.0),
              const Text(
                "Create Surplus Allocation",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Stepper for Quantity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Portions to Donate",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: _allocationQuantity > 1
                        ? () => setState(() => _allocationQuantity--)
                        : null,
                    customBorder: const CircleBorder(),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.remove, size: 16, color: Colors.grey.shade700),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "$_allocationQuantity",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _allocationQuantity < maxAvailable
                        ? () => setState(() => _allocationQuantity++)
                        : null,
                    customBorder: const CircleBorder(),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add, size: 16, color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Partner Selection Dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedPartnerId,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              hintText: "Select Partner Organization (Optional)",
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text("Unassigned / General Donation"),
              ),
              ...controller.partners.map((p) => DropdownMenuItem<String>(
                    value: p.id,
                    child: Text(p.name, overflow: TextOverflow.ellipsis),
                  )),
            ],
            onChanged: (val) {
              setState(() {
                _selectedPartnerId = val;
              });
            },
          ),
          const SizedBox(height: 12.0),

          // Notes
          CustomTextField(
            controller: _notesController,
            hintText: "Pickup instructions or food item details (Optional)",
            prefixIcon: Icons.notes,
          ),
          const SizedBox(height: 16.0),

          CustomButton(
            text: "Allocate Surplus ($maxAvailable Available)",
            isLoading: controller.isCreatingAllocation,
            icon: Icons.send_rounded,
            onPressed: () async {
              final success = await controller.createAllocation(
                quantity: _allocationQuantity,
                partnerId: _selectedPartnerId,
                notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
              );
              if (success && mounted) {
                setState(() {
                  _allocationQuantity = 1;
                  _notesController.clear();
                  _selectedPartnerId = null;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Component: Partner List Item
// -----------------------------------------------------------------------------
class _PartnerListItem extends StatelessWidget {
  final DonationPartnerModel partner;
  final int availablePortions;
  final VoidCallback onAllocate;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _PartnerListItem({
    required this.partner,
    required this.availablePortions,
    required this.onAllocate,
    this.onEdit,
    this.onDelete,
  });

  Future<void> _makePhoneCall(String phone) async {
    // CRITICAL: Opening phone app must NOT automatically mark an allocation collected!
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(Icons.handshake, color: Colors.green.shade800, size: 22),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  partner.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                if (partner.contactPerson != null && partner.contactPerson!.isNotEmpty) ...[
                  const SizedBox(height: 2.0),
                  Text(
                    "Contact: ${partner.contactPerson!}",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
                if (partner.contactPhone != null && partner.contactPhone!.isNotEmpty) ...[
                  const SizedBox(height: 2.0),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4.0),
                      Text(
                        partner.contactPhone!,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                      const SizedBox(width: 6.0),
                      InkWell(
                        onTap: () => _makePhoneCall(partner.contactPhone!),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Icon(Icons.call, size: 14, color: Colors.green.shade800),
                        ),
                      ),
                    ],
                  ),
                ],
                if (partner.address != null && partner.address!.isNotEmpty) ...[
                  const SizedBox(height: 2.0),
                  Text(
                    partner.address!,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null)
                    InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(Icons.edit_outlined, size: 18, color: Colors.blueGrey.shade600),
                      ),
                    ),
                  if (onDelete != null) ...[
                    const SizedBox(width: 4.0),
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400),
                      ),
                    ),
                  ],
                ],
              ),
              if (availablePortions > 0) ...[
                const SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: onAllocate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text("Allocate", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Component: Allocation History Card
// -----------------------------------------------------------------------------
class _AllocationHistoryCard extends StatelessWidget {
  final SurplusAllocationModel allocation;
  final bool isUpdating;
  final VoidCallback onMarkCollected;
  final VoidCallback onCancel;
  final VoidCallback? onDispatch;
  final VoidCallback? onViewGatePass;

  const _AllocationHistoryCard({
    required this.allocation,
    required this.isUpdating,
    required this.onMarkCollected,
    required this.onCancel,
    this.onDispatch,
    this.onViewGatePass,
  });

  @override
  Widget build(BuildContext context) {
    final partnerName = allocation.partnerName ?? 'Unassigned Partner';
    final isPending = allocation.isPending;
    final isCollected = allocation.isCompletedDonation;
    final isCancelled = allocation.isCancelled;

    Color badgeColor;
    Color badgeTextColor;
    String badgeText;
    IconData badgeIcon;

    if (isCollected) {
      badgeColor = Colors.green.shade50;
      badgeTextColor = Colors.green.shade800;
      badgeText = "Collected";
      badgeIcon = Icons.check_circle;
    } else if (isCancelled) {
      badgeColor = Colors.grey.shade100;
      badgeTextColor = Colors.grey.shade700;
      badgeText = "Cancelled";
      badgeIcon = Icons.cancel;
    } else {
      badgeColor = Colors.amber.shade50;
      badgeTextColor = Colors.amber.shade900;
      badgeText = "Pending Pickup";
      badgeIcon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${allocation.quantity} Portions",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, size: 12, color: badgeTextColor),
                    const SizedBox(width: 4.0),
                    Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: badgeTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          Row(
            children: [
              Icon(Icons.business_outlined, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4.0),
              Text(
                partnerName,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM d, h:mm a').format(allocation.createdAt),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
          if (allocation.notes != null && allocation.notes!.isNotEmpty) ...[
            const SizedBox(height: 6.0),
            Text(
              "Note: ${allocation.notes!}",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: 12.0),
          Row(
            children: [
              if (onViewGatePass != null)
                TextButton.icon(
                  onPressed: onViewGatePass,
                  icon: const Icon(Icons.badge_outlined, size: 14),
                  label: const Text("Gate Pass", style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    minimumSize: Size.zero,
                  ),
                ),
              if (isPending && onDispatch != null) ...[
                const SizedBox(width: 4.0),
                TextButton.icon(
                  onPressed: onDispatch,
                  icon: Icon(Icons.send_rounded, size: 14, color: Colors.green.shade800),
                  label: Text("WhatsApp", style: TextStyle(fontSize: 12, color: Colors.green.shade800, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
              const Spacer(),
              if (isPending) ...[
                OutlinedButton(
                  onPressed: isUpdating ? null : onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade400),
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    minimumSize: Size.zero,
                  ),
                  child: const Text("Cancel", style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton.icon(
                  onPressed: isUpdating ? null : onMarkCollected,
                  icon: const Icon(Icons.check, size: 14),
                  label: const Text("Mark Collected", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
