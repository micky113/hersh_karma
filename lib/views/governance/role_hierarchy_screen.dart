import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_profile.dart';

class RoleHierarchyScreen extends StatefulWidget {
  const RoleHierarchyScreen({super.key});

  @override
  State<RoleHierarchyScreen> createState() => _RoleHierarchyScreenState();
}

class _RoleHierarchyScreenState extends State<RoleHierarchyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('👑 ', style: TextStyle(fontSize: 20)),
            Text(
              'Role & Governance Hierarchy',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF00B074),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF00B074),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: '🌐 The 3 Dimensions'),
            Tab(text: '🌱 Community Track'),
            Tab(text: '🏢 Organization Track'),
            Tab(text: '🧑‍⚖️ Platform Governance'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildThreeDimensionsView(context, user, isDark),
          _buildCommunityTrackView(context, user, isDark),
          _buildOrganizationTrackView(context, user, isDark),
          _buildPlatformGovernanceView(context, isDark),
        ],
      ),
    );
  }

  // 1. THE 3 DIMENSIONS VIEW
  Widget _buildThreeDimensionsView(BuildContext context, UserProfile? user, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Philosophy Hero Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF00B074).withOpacity(isDark ? 0.25 : 0.12),
                  Colors.blue.withOpacity(isDark ? 0.15 : 0.05),
                ],
              ),
              border: Border.all(color: const Color(0xFF00B074).withOpacity(0.35)),
            ),
            child: Column(
              children: [
                const Text(
                  '⚖️ Role-Based Authority vs Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF00B074)),
                ),
                const SizedBox(height: 6),
                const Text(
                  '"Karma is not authority. Nobody is above another person because they have more Karma. Karma measures contribution, Trust measures reliability, and Authority measures responsibility."',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 11.5, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // The 3 Pillars Cards
          _buildDimensionCard(
            title: '⭐ ① KARMA: Recognition for Good',
            desc: 'Measures lifetime positive deeds. Recognizes your efforts for the world, but confers zero authoritarian power over others.',
            stat: user != null ? '${user.karmaCredits} Credits Earned' : 'Contribution Metric',
            color: const Color(0xFF00B074),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildDimensionCard(
            title: '🛡️ ② TRUST: Reliability Score',
            desc: 'Measures consistency and photographic evidence authenticity. Determines if your claims pass automated audit thresholds.',
            stat: user != null ? '${(user.trustScore * 100).toInt()}% Proof Rating' : 'Reliability Metric',
            color: Colors.blue,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildDimensionCard(
            title: '👑 ③ AUTHORITY: Responsibility & Role',
            desc: 'Determines what you are permitted to do (e.g. peer verification, project coordination, institutional challenge creation).',
            stat: user != null ? user.communityRole.label : 'Permission Scope',
            color: Colors.purple,
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          // User's Current Alignment Matrix
          if (user != null) ...[
            const Text(
              'YOUR THREE-DIMENSIONAL MATRIX',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Colors.grey, letterSpacing: 1.1),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMatrixNode('⭐ Contribution', '${user.karmaCredits} CR', const Color(0xFF00B074)),
                    Container(height: 32, width: 1, color: Colors.grey.shade300),
                    _buildMatrixNode('🛡️ Reliability', '${(user.trustScore * 100).toInt()}%', Colors.blue),
                    Container(height: 32, width: 1, color: Colors.grey.shade300),
                    _buildMatrixNode('👑 Role Level', user.communityRole.name.toUpperCase(), Colors.purple),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 2. COMMUNITY TRACK VIEW
  Widget _buildCommunityTrackView(BuildContext context, UserProfile? user, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildRoleStep(
          role: '👤 1. Member',
          subtitle: 'Default Starting Status',
          desc: 'Every person starts here. You can do good, report problems, make wishes, help others, participate in challenges, and build Karma & Trust.',
          badge: 'Default for All',
          isCurrent: user?.communityRole == CommunityRole.member,
          color: Colors.grey,
        ),
        const SizedBox(height: 12),
        _buildRoleStep(
          role: '🌱 2. Contributor',
          subtitle: 'Verified Good Deeds Completed',
          desc: 'Achieved after completing verified real-world actions. This is recognition of genuine impact, not authority over other members.',
          badge: 'Verified Deeds',
          isCurrent: user?.communityRole == CommunityRole.contributor,
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildRoleStep(
          role: '🛡️ 3. Trusted Contributor',
          subtitle: 'Consistent High-Trust History',
          desc: 'Granted to members with a proven track record of reliable evidence. Earns permissions to verify low-risk peer submissions and moderate community activities.',
          badge: 'Peer Verifier',
          isCurrent: user?.communityRole == CommunityRole.trustedContributor,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildRoleStep(
          role: '🤝 4. Community Leader',
          subtitle: 'Project & Volunteer Coordinator',
          desc: 'Coordinates local cleanup drives, student volunteer teams, or problem-solving initiatives. Manages approved challenges without controlling others\' Karma.',
          badge: 'Local Coordinator',
          isCurrent: user?.communityRole == CommunityRole.communityLeader,
          color: Colors.purple,
        ),
      ],
    );
  }

  // 3. ORGANIZATION TRACK VIEW
  Widget _buildOrganizationTrackView(BuildContext context, UserProfile? user, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildOrgCard('🏫 School / College', 'Creates student challenges (e.g. 1,000 students → 10,000 hours), oversees student certificates, and manages campus volunteer credits.', Colors.blue),
        const SizedBox(height: 12),
        _buildOrgCard('🤝 NGO / Impact Organization', 'Mobilizes volunteers, verifies eligible problem solutions, manages wish fulfillment pipelines, and exports audit-ready impact reports.', Colors.purple),
        const SizedBox(height: 12),
        _buildOrgCard('🏢 Company & CSR Partner', 'Drives employee volunteering, funds corporate-sponsored challenges (e.g. Clean India), and accesses audit-ready ESG/BRSR compliance reports.', const Color(0xFF00B074)),
        const SizedBox(height: 12),
        _buildOrgCard('🏛️ Civic Authority & City Department', 'Receives verified geotagged problem reports (potholes, garbage, broken infrastructure) and approves municipal repairs.', Colors.orange),
      ],
    );
  }

  // 4. PLATFORM GOVERNANCE VIEW (LEAST PRIVILEGE)
  Widget _buildPlatformGovernanceView(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.redAccent.withOpacity(isDark ? 0.2 : 0.08),
            border: Border.all(color: Colors.redAccent.withOpacity(0.35)),
          ),
          child: const Row(
            children: [
              Icon(Icons.security_rounded, color: Colors.redAccent, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Principle of Least Privilege: Administrators only have access to tools required for their specific governance duties.',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildGovCard('🔍 Verification Team', 'Reviews high-impact claims (Level 4/5), organization endorsements, difficult evidence, and audit appeals.', Colors.teal),
        const SizedBox(height: 10),
        _buildGovCard('🛡️ Trust & Safety Team', 'Detects duplicate photo sybil attacks, impossible velocity travel anomalies, fake accounts, and spam manipulation.', Colors.redAccent),
        const SizedBox(height: 10),
        _buildGovCard('💬 Support & Beneficiary Team', 'Handles user assistance, wish disbursement support, account inquiries, and general disputes.', Colors.blue),
        const SizedBox(height: 10),
        _buildGovCard('👑 Super Admin / Platform Governance', 'Oversees platform configuration, verification policy, dispute resolution, and immutable cryptographic audit trails.', Colors.amber.shade800),
      ],
    );
  }

  Widget _buildDimensionCard({
    required String title,
    required String desc,
    required String stat,
    required Color color,
    required bool isDark,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.3), width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: color))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(stat, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(desc, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.grey.shade700, height: 1.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildMatrixNode(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
      ],
    );
  }

  Widget _buildRoleStep({
    required String role,
    required String subtitle,
    required String desc,
    required String badge,
    required bool isCurrent,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCurrent ? BorderSide(color: color, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(role, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isCurrent ? color : null)),
                      Text(subtitle, style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCurrent ? color : color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isCurrent ? 'Your Current Role' : badge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isCurrent ? Colors.white : color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(desc, style: const TextStyle(fontSize: 11, height: 1.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrgCard(String title, String desc, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
            const SizedBox(height: 6),
            Text(desc, style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildGovCard(String title, String desc, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(Icons.shield_outlined, color: color, size: 18),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: color)),
        subtitle: Text(desc, style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
      ),
    );
  }
}
