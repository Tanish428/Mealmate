import 'package:flutter/material.dart';
import '../../data/repos/mess_repo.dart';

class MemberData {
  final String id;
  final String name;
  final String initials;
  final Color avatarBgColor;
  final Color avatarTextColor;

  const MemberData({
    required this.id,
    required this.name,
    required this.initials,
    required this.avatarBgColor,
    required this.avatarTextColor,
  });
}

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final MessRepository _messRepo = MessRepository();
  late Future<List<Map<String, dynamic>>> _membersFuture;

  final List<(Color, Color)> _avatarColors = [
    (Colors.red.shade50, Colors.red.shade700),
    (Colors.orange.shade50, Colors.orange.shade800),
    (Colors.green.shade50, Colors.green.shade800),
    (Colors.blue.shade50, Colors.blue.shade800),
    (Colors.purple.shade50, Colors.purple.shade800),
    (Colors.teal.shade50, Colors.teal.shade800),
    (Colors.pink.shade50, Colors.pink.shade800),
  ];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  void _loadMembers() {
    setState(() {
      _membersFuture = _messRepo.getMessMembers();
    });
  }

  String _extractInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'M';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  MemberData _mapToMemberData(Map<String, dynamic> data, int index) {
    final rawName = data['full_name'] as String?;
    final role = data['role'] as String?;
    final name = (rawName != null && rawName.trim().isNotEmpty)
        ? rawName.trim()
        : (role != null && role.isNotEmpty ? 'Member (${role.toUpperCase()})' : 'Active Member');
    final colors = _avatarColors[index % _avatarColors.length];

    return MemberData(
      id: data['id']?.toString() ?? index.toString(),
      name: name,
      initials: _extractInitials(name),
      avatarBgColor: colors.$1,
      avatarTextColor: colors.$2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadMembers(),
          color: Colors.red.shade700,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _membersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
                        child: _buildHeader(context, countText: "Loading..."),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        child: _buildSectionHeader(context, countText: "..."),
                      ),
                    ),
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ],
                );
              }

              if (snapshot.hasError) {
                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
                        child: _buildHeader(context, countText: "Error"),
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                              const SizedBox(height: 12),
                              Text(
                                "Failed to load members",
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                snapshot.error.toString(),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: _loadMembers,
                                icon: const Icon(Icons.refresh),
                                label: const Text("Retry"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              final rawMembers = snapshot.data ?? [];
              final memberItems = List.generate(
                rawMembers.length,
                (i) => _mapToMemberData(rawMembers[i], i),
              );

              final int count = memberItems.length;
              final countString = "$count ${count == 1 ? 'Member' : 'Members'}";

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
                      child: _buildHeader(context, countText: countString),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: _buildSectionHeader(context, countText: "$count"),
                    ),
                  ),
                  if (memberItems.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.group_outlined,
                                  size: 48,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No Active Members Yet",
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "When members join your mess using your invite code, they will appear here.",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _MemberListTile(member: memberItems[index]),
                            );
                          },
                          childCount: memberItems.length,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {required String countText}) {
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
          countText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String countText}) {
    return Text(
      "Active Members ($countText)",
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
