import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../logic/controllers/preparation_planner_controller.dart';

class PreparationPlannerScreen extends StatefulWidget {
  const PreparationPlannerScreen({super.key});

  @override
  State<PreparationPlannerScreen> createState() => _PreparationPlannerScreenState();
}

class _PreparationPlannerScreenState extends State<PreparationPlannerScreen> {
  late PreparationPlannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PreparationPlannerController();
    _controller.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }
  
  void _shareWithCook() async {
    final text = _controller.generateWhatsAppSummary();
    final url = Uri.parse("https://api.whatsapp.com/send?text=${Uri.encodeComponent(text)}");
    
    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        throw Exception('Could not launch');
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp not found. Prep summary copied to clipboard!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFBF7),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.red.shade700),
          onPressed: () => Navigator.pop(context),
        ),
        title: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
            children: [
              const TextSpan(text: "Preparation "),
              TextSpan(
                text: "Planner",
                style: TextStyle(color: Colors.red.shade700),
              ),
            ],
          ),
        ),
      ),
      body: _controller.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DateNavigator(controller: _controller),
                    const SizedBox(height: 16.0),
                    _MealFilter(controller: _controller),
                    const SizedBox(height: 16.0),
                    _CutoffBanner(controller: _controller),
                    const SizedBox(height: 24.0),
                    _HeroStatsCard(controller: _controller),
                    const SizedBox(height: 24.0),
                    _QuickAdjustmentsCard(controller: _controller),
                    const SizedBox(height: 32.0),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _shareWithCook,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.chat),
                        label: const Text(
                          "Share with Cook",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                  ],
                ),
              ),
            ),
    );
  }
}

class _DateNavigator extends StatelessWidget {
  final PreparationPlannerController controller;
  
  const _DateNavigator({required this.controller});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final selectedDate = DateTime(controller.selectedDate.year, controller.selectedDate.month, controller.selectedDate.day);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _DateChip(
              label: "Today",
              isSelected: selectedDate.isAtSameMomentAs(today),
              onTap: () => controller.setDate(today),
            ),
            const SizedBox(width: 8),
            _DateChip(
              label: "Tomorrow",
              isSelected: selectedDate.isAtSameMomentAs(tomorrow),
              onTap: () => controller.setDate(tomorrow),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => controller.setDate(controller.selectedDate.subtract(const Duration(days: 1))),
            ),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: controller.selectedDate,
                  firstDate: today.subtract(const Duration(days: 30)),
                  lastDate: today.add(const Duration(days: 30)),
                );
                if (date != null) {
                  controller.setDate(date);
                }
              },
              child: Row(
                children: [
                  Text(
                    DateFormat('MMM dd').format(controller.selectedDate),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.calendar_month, size: 18),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => controller.setDate(controller.selectedDate.add(const Duration(days: 1))),
            ),
          ],
        )
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.shade700 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _MealFilter extends StatelessWidget {
  final PreparationPlannerController controller;
  
  const _MealFilter({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.servedMeals.isEmpty) {
      return const Text("No meals configured");
    }
    
    return Row(
      children: controller.servedMeals.map((meal) {
        final isSelected = controller.selectedMeal == meal;
        return Expanded(
          child: GestureDetector(
            onTap: () => controller.setMeal(meal),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange.shade100 : Colors.white,
                border: Border.all(
                  color: isSelected ? Colors.orange.shade700 : Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                meal[0].toUpperCase() + meal.substring(1),
                style: TextStyle(
                  color: isSelected ? Colors.orange.shade900 : Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CutoffBanner extends StatelessWidget {
  final PreparationPlannerController controller;
  
  const _CutoffBanner({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isFinalized = controller.isFinalized;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFinalized ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isFinalized ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isFinalized ? Icons.check_circle : Icons.timer,
            color: isFinalized ? Colors.green.shade700 : Colors.orange.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isFinalized 
                  ? "Finalized - Cutoff Closed" 
                  : "Live Headcount - ${controller.remainingTimeUntilCutoff}",
              style: TextStyle(
                color: isFinalized ? Colors.green.shade800 : Colors.orange.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStatsCard extends StatelessWidget {
  final PreparationPlannerController controller;
  
  const _HeroStatsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          const Text(
            "FINAL COOKING TARGET",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "${controller.finalCookingTarget}",
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  color: Colors.red.shade700,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Plates",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: "Joined", value: "${controller.totalJoinedMembers}"),
              _StatItem(label: "Attending", value: "${controller.attendingMembers}", color: Colors.green.shade700),
              _StatItem(label: "Opted Out", value: "${controller.optedOutCount}", color: Colors.orange.shade700),
              _StatItem(label: "Extra", value: "+${controller.extraPlates}", color: Colors.blue.shade700),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatItem({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _QuickAdjustmentsCard extends StatelessWidget {
  final PreparationPlannerController controller;
  
  const _QuickAdjustmentsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Adjustments",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Extra Plates", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text("Staff, guests, or walk-ins", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: controller.decrementExtraPlates,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.red.shade700,
                  ),
                  SizedBox(
                    width: 30,
                    child: Text(
                      "${controller.extraPlates}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  IconButton(
                    onPressed: controller.incrementExtraPlates,
                    icon: const Icon(Icons.add_circle_outline),
                    color: Colors.red.shade700,
                  ),
                ],
              )
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Safety Buffer (5%)", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text("Add extra margin just in case", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
              Switch(
                value: controller.safetyBufferEnabled,
                onChanged: controller.toggleSafetyBuffer,
                activeColor: Colors.red.shade700,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
