import 'package:flutter/material.dart';

class MemberData {
  final String name;
  final String initials;
  final Color avatarBgColor;
  final Color avatarTextColor;

  const MemberData({
    required this.name,
    required this.initials,
    required this.avatarBgColor,
    required this.avatarTextColor,
  });
}

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<MemberData> members = [
      MemberData(
        name: "Tanish Mistry",
        initials: "TM",
        avatarBgColor: Colors.red.shade50,
        avatarTextColor: Colors.red.shade700,
      ),
      MemberData(
        name: "Alex Mehta",
        initials: "AM",
        avatarBgColor: Colors.orange.shade50,
        avatarTextColor: Colors.orange.shade800,
      ),
      MemberData(
        name: "Priya Shah",
        initials: "PS",
        avatarBgColor: Colors.green.shade50,
        avatarTextColor: Colors.green.shade800,
      ),
      MemberData(
        name: "Rahul Kumar",
        initials: "RK",
        avatarBgColor: Colors.blue.shade50,
        avatarTextColor: Colors.blue.shade800,
      ),
      MemberData(
        name: "Sneha Patel",
        initials: "SP",
        avatarBgColor: Colors.purple.shade50,
        avatarTextColor: Colors.purple.shade800,
      ),
      // Adding a few more to make the list look full
      MemberData(
        name: "Vikram Singh",
        initials: "VS",
        avatarBgColor: Colors.teal.shade50,
        avatarTextColor: Colors.teal.shade800,
      ),
      MemberData(
        name: "Anjali Desai",
        initials: "AD",
        avatarBgColor: Colors.pink.shade50,
        avatarTextColor: Colors.pink.shade800,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
              child: _buildHeader(context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: _buildSectionHeader(context),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
                itemCount: members.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _MemberListTile(member: members[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Members",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
        ),
        const SizedBox(height: 4.0),
        Text(
          "50 Members",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Text(
      "Active Members (50)",
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
    );
  }
}

class _MemberListTile extends StatelessWidget {
  final MemberData member;

  const _MemberListTile({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: member.avatarBgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              member.initials,
              style: TextStyle(
                color: member.avatarTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Text(
              member.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

