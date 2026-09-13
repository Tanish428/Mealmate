import 'package:flutter/material.dart';

class MessSettingsScreen extends StatefulWidget {
  const MessSettingsScreen({super.key});

  @override
  State<MessSettingsScreen> createState() => _MessSettingsScreenState();
}

class _MessSettingsScreenState extends State<MessSettingsScreen> {
  bool _digitalPaymentsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SettingsHeader(),
              const SizedBox(height: 24.0),
              const _ProfileCard(),
              const SizedBox(height: 32.0),
              _SettingsSection(
                title: "Operations",
                children: [
                  _SettingsRowTile(
                    icon: Icons.access_time,
                    title: "Meal Serving Times",
                    subtitle: "Breakfast, lunch & dinner timings",
                    onTap: () {},
                  ),
                  _SettingsRowTile(
                    icon: Icons.alarm,
                    title: "RSVP Cutoff Rules",
                    subtitle: "Control when members can opt out",
                    trailingLabel: const Text("2 hours before",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    onTap: () {},
                  ),
                  _SettingsRowTile(
                    icon: Icons.groups,
                    title: "Maximum Capacity",
                    subtitle: "Limit the number of active members",
                    trailingLabel: const Text("50 Members",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              _SettingsSection(
                title: "Financials",
                children: [
                  _SettingsRowTile(
                    icon: Icons.account_balance_wallet,
                    title: "Monthly Subscription Fee",
                    subtitle: "Amount members pay each month",
                    trailingLabel: const Text("₹2,500",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    onTap: () {},
                  ),
                  _SettingsRowTile(
                    icon: Icons.qr_code,
                    title: "Digital Payments",
                    subtitle: "Allow members to pay through the app",
                    trailingLabel: Switch(
                      value: _digitalPaymentsEnabled,
                      onChanged: (val) {
                        setState(() {
                          _digitalPaymentsEnabled = val;
                        });
                      },
                      activeThumbColor: Colors.white,
                      activeTrackColor: Colors.red.shade700,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey.shade300,
                    ),
                    showChevron: false,
                    onTap: () {
                      setState(() {
                        _digitalPaymentsEnabled = !_digitalPaymentsEnabled;
                      });
                    },
                  ),
                  _SettingsRowTile(
                    icon: Icons.credit_card,
                    title: "Payment Details",
                    subtitle: "UPI ID and payment configuration",
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              _SettingsSection(
                title: "Member Access",
                children: [
                  _SettingsRowTile(
                    icon: Icons.vpn_key,
                    title: "Regenerate Invite Code",
                    subtitle: "Create a new code for member invitations",
                    onTap: () {},
                  ),
                  _SettingsRowTile(
                    icon: Icons.person_add,
                    title: "Pending Requests",
                    subtitle: "Review members waiting to join",
                    trailingLabel: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text("3",
                          style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              const _LogoutButton(),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
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
                    const TextSpan(text: "Mess "),
                    TextSpan(
                      text: "Settings",
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                "Manage your mess details and preferences.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12.0),
        Container(
          width: 90,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            children: [
              Icon(Icons.rice_bowl, color: Colors.orange.shade700, size: 28),
              const SizedBox(height: 8.0),
              Text(
                "Good Food\nBetter Days",
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

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

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
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(Icons.storefront, color: Colors.grey.shade400, size: 32),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("DDU Campus Mess",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4.0),
                    Expanded(
                      child: Text("College Road, Nadiad",
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Invite Code",
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red.shade900)),
                            const SizedBox(height: 2.0),
                            Row(
                              children: [
                                Text("84X29P",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade700)),
                                const Spacer(),
                                Icon(Icons.copy, size: 14, color: Colors.red.shade700),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red.shade700),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, size: 14, color: Colors.red.shade700),
                            const SizedBox(width: 4.0),
                            Text("Edit Profile",
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 14)),
        const SizedBox(height: 12.0),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: List.generate(
              children.length * 2 - 1,
              (index) {
                if (index.isOdd) {
                  return Divider(height: 1, color: Colors.grey.shade200, indent: 64.0, endIndent: 16.0);
                }
                return children[index ~/ 2];
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsRowTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailingLabel;
  final bool showChevron;
  final VoidCallback onTap;

  const _SettingsRowTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailingLabel,
    this.showChevron = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.red.shade700, size: 20),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4.0),
                  Text(subtitle,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            Row(
              children: [
                if (trailingLabel != null) ...[
                  trailingLabel!,
                  if (showChevron) const SizedBox(width: 4.0),
                ],
                if (showChevron)
                  Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red.shade700,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout, size: 20),
            SizedBox(width: 8.0),
            Text(
              "Log Out",
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
