import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_profile.dart';
import '../../models/promotion/promotion_engine.dart';

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
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showPromotionDialog(BuildContext context, UserProfile user, PromotionGateResult gateResult) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('🌟 ', style: TextStyle(fontSize: 22)),
            Expanded(
              child: Text(
                'Claim ${gateResult.targetRole.title} Status',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00B074).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '🌟 You\'ve earned ${gateResult.targetRole.title} status!\n\nYour verified contributions and high trust score have earned you active community responsibility.',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF00B074)),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'RESPONSIBILITIES UNLOCKED:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            ...gateResult.unlockedResponsibilities.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Color(0xFF00B074), fontWeight: FontWeight.bold)),
                      Expanded(child: Text(r, style: const TextStyle(fontSize: 11.5))),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B074),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final updated = user.copyWith(explicitCommunityRole: gateResult.targetRole);
              auth.updateUserProfile(updated);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🎉 Congratulations! You are now a verified ${gateResult.targetRole.title}.'),
                  backgroundColor: const Color(0xFF00B074),
                ),
              );
            },
            child: const Text('Accept Responsibility'),
          ),
        ],
      ),
    );
  }

  void _showAmbassadorNominationDialog(BuildContext context, UserProfile user) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🌟 ', style: TextStyle(fontSize: 22)),
            Expanded(
              child: Text(
                'Apply for Karma Ambassador Review',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Karma Ambassador is a prestigious responsibility representing the core values and integrity of Karma Grid. Applications undergo Human Governance Board review.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe your community leadership record, civic impact, and vision for Karma Grid...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final updated = user.copyWith(isAmbassadorNominated: true);
              auth.updateUserProfile(updated);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Application submitted to Governance Board review queue.'),
                  backgroundColor: Colors.purple,
                ),
              );
            },
            child: const Text('Submit Nomination'),
          ),
        ],
      ),
    );
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
              'Role & Responsibility Progression',
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
            Tab(text: '🌱 5 Community Levels'),
            Tab(text: '🧠 2D Karma vs Trust'),
            Tab(text: '⭐ 4 Promotion Gates'),
            Tab(text: '🏢 Organization Track'),
            Tab(text: '🧑‍⚖️ Platform Governance'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCommunityLevelsView(context, user, isDark),
          _buildTwoDimensionalView(context, user, isDark),
          _buildPromotionGatesView(context, user, isDark),
          _buildOrganizationTrackView(context, user, isDark),
          _buildPlatformGovernanceView(context, isDark),
        ],
      ),
    );
  }

  // 1. THE 5 COMMUNITY RESPONSIBILITY LEVELS
  Widget _buildCommunityLevelsView(BuildContext context, UserProfile? user, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Trinity Hero Banner
        _buildTrinityBanner(isDark),
        const SizedBox(height: 16),

        _buildRoleStep(
          role: '👤 Level 1: New Member',
          subtitle: 'Starting Status for Everyone',
          desc: 'Everyone starts here. You can do actions, report hazards, make wishes, earn Karma, and build Trust.',
          responsibilities: CommunityRole.newMember.responsibilities,
          requirements: CommunityRole.newMember.promotionRequirements,
          reviewType: CommunityRole.newMember.reviewType,
          isCurrent: user?.communityRole == CommunityRole.newMember,
          color: Colors.grey,
        ),
        const SizedBox(height: 14),

        _buildRoleStep(
          role: '🌱 Level 2: Contributor',
          subtitle: 'Demonstrated Active Participation',
          desc: 'Awarded once you prove consistent real-world contribution with high-fidelity photo proof and clean conduct.',
          responsibilities: CommunityRole.contributor.responsibilities,
          requirements: CommunityRole.contributor.promotionRequirements,
          reviewType: CommunityRole.contributor.reviewType,
          isCurrent: user?.communityRole == CommunityRole.contributor,
          color: Colors.green,
        ),
        const SizedBox(height: 14),

        _buildRoleStep(
          role: '🛡️ Level 3: Trusted Contributor',
          subtitle: 'Peer Verifier & Moderate Authority',
          desc: 'High Trust score unlocks limited peer verification of low-risk community deeds. Governed by anti-collusion firewall.',
          responsibilities: CommunityRole.trustedContributor.responsibilities,
          requirements: CommunityRole.trustedContributor.promotionRequirements,
          reviewType: CommunityRole.trustedContributor.reviewType,
          isCurrent: user?.communityRole == CommunityRole.trustedContributor,
          color: Colors.blue,
        ),
        const SizedBox(height: 14),

        _buildRoleStep(
          role: '🤝 Level 4: Community Leader',
          subtitle: 'Initiative & Project Coordinator',
          desc: 'Demonstrated leadership: organizes cleanups, mobilizes volunteers, and coordinates local NGO partnerships.',
          responsibilities: CommunityRole.communityLeader.responsibilities,
          requirements: CommunityRole.communityLeader.promotionRequirements,
          reviewType: CommunityRole.communityLeader.reviewType,
          isCurrent: user?.communityRole == CommunityRole.communityLeader,
          color: Colors.purple,
        ),
        const SizedBox(height: 14),

        _buildRoleStep(
          role: '🌟 Level 5: Karma Ambassador',
          subtitle: 'Highest Honor & Values Representation',
          desc: 'Rare, prestigious responsibility representing the values of Karma Grid. Mentors leaders and leads regional civic expansions.',
          responsibilities: CommunityRole.karmaAmbassador.responsibilities,
          requirements: CommunityRole.karmaAmbassador.promotionRequirements,
          reviewType: CommunityRole.karmaAmbassador.reviewType,
          isCurrent: user?.communityRole == CommunityRole.karmaAmbassador,
          color: Colors.amber.shade800,
        ),
        const SizedBox(height: 20),

        // Aarav vs Maya Showcase
        _buildProfileComparisonCard(isDark),
      ],
    );
  }

  // 2. 2D KARMA VS TRUST MATRIX VIEW
  Widget _buildTwoDimensionalView(BuildContext context, UserProfile? user, bool isDark) {
    final quadrant = user != null ? PromotionEngine.evaluateQuadrant(user) : KarmaTrustQuadrant.lowKarmaLowTrust;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(isDark ? 0.25 : 0.1),
                  const Color(0xFF00B074).withOpacity(isDark ? 0.25 : 0.1),
                ],
              ),
              border: Border.all(color: Colors.purple.withOpacity(0.3)),
            ),
            child: const Column(
              children: [
                Text(
                  '🧠 Two-Dimensional Progression Model',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.purple),
                ),
                SizedBox(height: 6),
                Text(
                  'Karma is NOT Rank. High Karma with low Trust means questionable reliability—and results in NO promotion. Low Karma with high Trust enables steady responsibility progression.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.5, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // User's Position Badge
          if (user != null) ...[
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              color: quadrant.isPromotionEligible ? const Color(0xFF00B074).withOpacity(0.08) : Colors.orange.withOpacity(0.08),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: quadrant.isPromotionEligible ? const Color(0xFF00B074) : Colors.orange,
                      child: Icon(
                        quadrant.isPromotionEligible ? Icons.verified_rounded : Icons.info_outline_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Quadrant: ${quadrant.label}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            quadrant.description,
                            style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 2D Visual Cartesian Grid
          const Text(
            'THE 4 QUADRANTS OF INTEGRITY',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Colors.grey, letterSpacing: 1),
          ),
          const SizedBox(height: 10),

          // Top Row
          Row(
            children: [
              Expanded(
                child: _buildQuadrantBox(
                  title: '⚠️ High Karma • Low Trust',
                  subtitle: 'High Volume / Unverified',
                  verdict: '❌ NO PROMOTION',
                  color: Colors.redAccent,
                  isDark: isDark,
                  isUserHere: quadrant == KarmaTrustQuadrant.highKarmaLowTrust,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuadrantBox(
                  title: '🌟 High Karma • High Trust',
                  subtitle: 'Pillars of Impact',
                  verdict: '👑 LEADER / AMBASSADOR',
                  color: Colors.amber.shade800,
                  isDark: isDark,
                  isUserHere: quadrant == KarmaTrustQuadrant.highKarmaHighTrust,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Bottom Row
          Row(
            children: [
              Expanded(
                child: _buildQuadrantBox(
                  title: '🌱 Low Karma • Low Trust',
                  subtitle: 'Early Stage Explorer',
                  verdict: '👤 BUILDING BASELINE',
                  color: Colors.grey,
                  isDark: isDark,
                  isUserHere: quadrant == KarmaTrustQuadrant.lowKarmaLowTrust,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuadrantBox(
                  title: '🛡️ Low Karma • High Trust',
                  subtitle: 'High-Integrity Contributor',
                  verdict: '✅ PROGRESSION PATH ACTIVE',
                  color: const Color(0xFF00B074),
                  isDark: isDark,
                  isUserHere: quadrant == KarmaTrustQuadrant.lowKarmaHighTrust,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Anti-Gaming Charter
          _buildAntiGamingCharter(isDark),
        ],
      ),
    );
  }

  // 3. THE 4 PROMOTION GATES VIEW
  Widget _buildPromotionGatesView(BuildContext context, UserProfile? user, bool isDark) {
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final gateResult = PromotionEngine.evaluateNextLevelGates(user);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Current Status & Target Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CURRENT LEVEL', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(user.communityRole.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: Color(0xFF00B074)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('TARGET LEVEL', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(gateResult.targetRole.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF00B074))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: gateResult.overallProgress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00B074)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Overall Gate Readiness: ${(gateResult.overallProgress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'THE 4 GATES OF PROMOTION',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Colors.grey, letterSpacing: 1),
          ),
          const SizedBox(height: 10),

          _buildGateTile(
            gateNum: 1,
            title: '① Contribution Gate',
            desc: 'What have you actually done? Real-world deeds, actions, and projects.',
            status: gateResult.contributionDetail,
            progress: gateResult.contributionProgress,
            passed: gateResult.contributionPassed,
            color: const Color(0xFF00B074),
          ),
          const SizedBox(height: 10),

          _buildGateTile(
            gateNum: 2,
            title: '② Verification Gate',
            desc: 'How much is independently verified by AI & consensus peers?',
            status: gateResult.verificationDetail,
            progress: gateResult.verificationProgress,
            passed: gateResult.verificationPassed,
            color: Colors.blue,
          ),
          const SizedBox(height: 10),

          _buildGateTile(
            gateNum: 3,
            title: '③ Trust Gate',
            desc: 'How reliable is your evidence and past verification accuracy?',
            status: gateResult.trustDetail,
            progress: gateResult.trustProgress,
            passed: gateResult.trustPassed,
            color: Colors.purple,
          ),
          const SizedBox(height: 10),

          _buildGateTile(
            gateNum: 4,
            title: '④ Conduct Gate',
            desc: 'Have you behaved responsibly toward the community without gaming or spam?',
            status: gateResult.conductDetail,
            progress: gateResult.conductProgress,
            passed: gateResult.conductPassed,
            color: Colors.orange,
          ),
          const SizedBox(height: 20),

          // Action Button
          if (gateResult.isEligibleForNextLevel) ...[
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.verified_rounded),
                label: Text(
                  'Claim ${gateResult.targetRole.title} Status',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B074),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => _showPromotionDialog(context, user, gateResult),
              ),
            ),
          ] else if (user.communityRole == CommunityRole.communityLeader) ...[
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.star_rounded),
                label: const Text(
                  'Apply for Karma Ambassador Review',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => _showAmbassadorNominationDialog(context, user),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline_rounded, color: Colors.grey, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      gateResult.statusSummary,
                      style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 4. ORGANIZATION TRACK VIEW
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

  // 5. PLATFORM GOVERNANCE VIEW (LEAST PRIVILEGE)
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

  // HELPER WIDGETS
  Widget _buildTrinityBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00B074).withOpacity(isDark ? 0.25 : 0.12),
            Colors.blue.withOpacity(isDark ? 0.15 : 0.05),
          ],
        ),
        border: Border.all(color: const Color(0xFF00B074).withOpacity(0.35)),
      ),
      child: const Column(
        children: [
          Text(
            '🌟 The Core Trinity Principle',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Color(0xFF00B074)),
          ),
          SizedBox(height: 8),
          Text(
            '• Karma shows what you\'ve contributed.\n• Trust shows how reliably you\'ve contributed.\n• Status shows what responsibility you\'ve earned.',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleStep({
    required String role,
    required String subtitle,
    required String desc,
    required List<String> responsibilities,
    required String requirements,
    required String reviewType,
    required bool isCurrent,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCurrent ? BorderSide(color: color, width: 2) : BorderSide(color: Colors.grey.shade200),
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
                    isCurrent ? 'Your Current Role' : 'Level',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isCurrent ? Colors.white : color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(desc, style: const TextStyle(fontSize: 11.5, height: 1.3)),
            const SizedBox(height: 10),

            // Responsibilities
            const Text('RESPONSIBILITIES:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 4),
            ...responsibilities.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 3.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 12, color: color),
                      const SizedBox(width: 6),
                      Expanded(child: Text(r, style: const TextStyle(fontSize: 10.5))),
                    ],
                  ),
                )),
            const SizedBox(height: 8),

            // Promotion criteria footer
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, size: 14, color: color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Requirements: $requirements ($reviewType)',
                      style: TextStyle(fontSize: 9.5, color: color, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuadrantBox({
    required String title,
    required String subtitle,
    required String verdict,
    required Color color,
    required bool isDark,
    required bool isUserHere,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUserHere ? color.withOpacity(isDark ? 0.3 : 0.15) : color.withOpacity(isDark ? 0.12 : 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isUserHere ? color : color.withOpacity(0.3), width: isUserHere ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: color))),
              if (isUserHere)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                  child: const Text('YOU', style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 9.5, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(verdict, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildGateTile({
    required int gateNum,
    required String title,
    required String desc,
    required String status,
    required double progress,
    required bool passed,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: passed ? color.withOpacity(0.5) : Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: passed ? color : Colors.grey.shade300,
                  child: Icon(passed ? Icons.check : Icons.hourglass_empty_rounded, size: 14, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: passed ? color : null)),
                ),
                Text(status, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: passed ? color : Colors.grey)),
              ],
            ),
            const SizedBox(height: 6),
            Text(desc, style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(passed ? color : Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAntiGamingCharter(bool isDark) {
    final rules = [
      'Having money, wealth, or high donations',
      'Having high follower counts or social media fame',
      'Purchasing PoG crypto tokens or premium tiers',
      'Friend networks / collusion (Conflict-of-Interest Firewall)',
      'Spamming low-value actions or repetitive problem reports',
      'Accumulating Karma through gaming the automated verification score',
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.redAccent.withOpacity(isDark ? 0.15 : 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.block_flipped, color: Colors.redAccent, size: 20),
                SizedBox(width: 8),
                Text(
                  '🚫 What NEVER Qualifies for Promotion',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.redAccent),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'To protect the integrity of the platform, the following never grant responsibility:',
              style: TextStyle(fontSize: 10.5, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            ...rules.map((rule) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✕ ', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                      Expanded(child: Text(rule, style: const TextStyle(fontSize: 10.5))),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileComparisonCard(bool isDark) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🌍 REAL COMMUNITY PROFILE COMPARISON',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 1),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSampleUser(
                    name: 'Aarav',
                    karma: '18,420',
                    impact: '1,240',
                    trust: '96%',
                    role: 'Community Leader 🤝',
                    ripple: '3,800 reached',
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSampleUser(
                    name: 'Maya',
                    karma: '4,200',
                    impact: '680',
                    trust: '99%',
                    role: 'Trusted Contributor 🛡️',
                    ripple: '1,420 reached',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Maya isn\'t "less important" because she has less Karma than Aarav. She simply has a different, well-earned level of responsibility.',
              style: TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleUser({
    required String name,
    required String karma,
    required String impact,
    required String trust,
    required String role,
    required String ripple,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
          const SizedBox(height: 4),
          Text('⭐ Karma: $karma', style: const TextStyle(fontSize: 10)),
          Text('🌍 Impact: $impact', style: const TextStyle(fontSize: 10)),
          Text('🛡️ Trust: $trust', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          Text('🏅 Role: $role', style: TextStyle(fontSize: 9.5, color: color, fontWeight: FontWeight.bold)),
          Text('🌊 Ripple: $ripple', style: const TextStyle(fontSize: 9.5, color: Colors.grey)),
        ],
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

