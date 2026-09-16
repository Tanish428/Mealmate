import 'package:flutter/material.dart';

class PreparationPlannerScreen extends StatelessWidget {
  const PreparationPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _PrepHeader(),
                    SizedBox(height: 24.0),
                    _HeroStatsCard(),
                    SizedBox(height: 24.0),
                    _EcoImpactBanner(),
                    SizedBox(height: 24.0),
                    _MenuQuantitiesSection(),
                    SizedBox(height: 24.0),
                    _KitchenSummaryCard(),
                  ],
                ),
              ),
            ),
            const _BottomActionArea(),
          ],
        ),
      ),
    );
  }
}

class _PrepHeader extends StatelessWidget {
  const _PrepHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                customBorder: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back, color: Colors.red.shade700, size: 20),
                ),
              ),
              const SizedBox(height: 12.0),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
              const SizedBox(height: 4.0),
              Text(
                "Today's Lunch  12:30 PM – 2:30 PM",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 90,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            children: [
              Icon(Icons.ramen_dining, color: Colors.orange.shade700, size: 28),
              const SizedBox(height: 8.0),
              Text(
                "Cook Serve\nMake a Difference",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroStatsCard extends StatelessWidget {
  const _HeroStatsCard();

  @override
  Widget build(BuildContext context) {
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
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.restaurant, color: Colors.red.shade700, size: 20),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Today's Lunch",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text("12:30 PM - 2:30 PM",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("42",
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                          height: 1.0,
                        )),
                    const SizedBox(height: 4.0),
                    const Text("Plates to Prepare",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4.0),
                    Text("42 of 50 members attending",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 0.84,
                      strokeWidth: 8,
                      color: Colors.red.shade700,
                      backgroundColor: Colors.grey.shade200,
                    ),
                    const Center(
                      child: Text(
                        "84%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: LinearProgressIndicator(
              value: 0.84,
              minHeight: 8,
              color: Colors.red.shade700,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("42 attending",
                  style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
              Text("8 opted out",
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EcoImpactBanner extends StatelessWidget {
  const _EcoImpactBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Icon(Icons.eco, color: Colors.green.shade700, size: 28),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("8 members opted out.",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                        fontSize: 14)),
                const SizedBox(height: 2.0),
                Text("You are saving approx. 2.5 kg of food today!",
                    style: TextStyle(
                        color: Colors.green.shade700, fontSize: 12, height: 1.3)),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          Column(
            children: [
              Icon(Icons.energy_savings_leaf, color: Colors.green.shade200, size: 24),
              const SizedBox(height: 4.0),
              Text(
                "Less Food Waste\nBrighter Tomorrow",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade600,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _MenuQuantitiesSection extends StatelessWidget {
  const _MenuQuantitiesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Menu Quantities",
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4.0),
        Text("Recommended preparation based on 42 attending members",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        const SizedBox(height: 16.0),
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            _MenuItemCard(
              name: "Paneer Butter Masala",
              isVeg: true,
              estimatedBulk: "Estimated bulk: 6.5 Liters",
              portions: "42 Portions",
            ),
            SizedBox(height: 12.0),
            _MenuItemCard(
              name: "Fresh Chapatis",
              isVeg: true,
              estimatedBulk: "Estimated bulk: 3 per person",
              portions: "126 Pieces",
            ),
            SizedBox(height: 12.0),
            _MenuItemCard(
              name: "Jeera Rice",
              isVeg: true,
              estimatedBulk: "Estimated bulk: 4.5 Kgs",
              portions: "42 Portions",
            ),
          ],
        ),
      ],
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final String name;
  final bool isVeg;
  final String estimatedBulk;
  final String portions;

  const _MenuItemCard({
    required this.name,
    required this.isVeg,
    required this.estimatedBulk,
    required this.portions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(Icons.fastfood, color: Colors.grey.shade300, size: 24),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isVeg ? Colors.green : Colors.red,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isVeg ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  estimatedBulk,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              portions,
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KitchenSummaryCard extends StatelessWidget {
  const _KitchenSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.assignment, color: Colors.red.shade700, size: 20),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Kitchen Summary",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text("Overview of today's prep",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryColumn(icon: Icons.group, value: "42", label: "Members\nAttending", color: Colors.red.shade700),
              _SummaryColumn(icon: Icons.remove_circle_outline, value: "8", label: "Opted\nOut", color: Colors.red.shade700),
              _SummaryColumn(icon: Icons.room_service, value: "3", label: "Dishes\n", color: Colors.red.shade700),
              _SummaryColumn(icon: Icons.eco, value: "2.5 kg", label: "Est. Food\nSaved", color: Colors.green.shade700),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SummaryColumn({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8.0),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black)),
          const SizedBox(height: 4.0),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                  height: 1.2)),
        ],
      ),
    );
  }
}

class _BottomActionArea extends StatelessWidget {
  const _BottomActionArea();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.download, size: 20),
            SizedBox(width: 8.0),
            Text(
              "Download Prep List",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

