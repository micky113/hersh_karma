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
            Tab(text: '🏆 Numerical Hierarchy'),
            Tab(text: '🔥 Impact Diversity & 2D'),
            Tab(text: '⭐ "Your Next Level" Gates'),
            Tab(text: '🛡️ Demotion Rules'),
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
          _buildDemotionRulesView(context, user, isDark),
          _buildPlatformGovernanceView(context, isDark),
        ],
      ),
    );
  }

  Widget _buildTrinityBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00B074), Color(0xFF0288D1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B074).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🌟 RESPONSIBILITY IS EARNED, NOT BOUGHT',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Transparent, Numerical & Anti-Gaming',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Anyone can earn Karma. Community governance responsibility requires proven Trust fidelity, verified deeds across multiple categories, and clean conduct.',
            style: TextStyle(color: Colors.white, fontSize: 12, height: 1.35),
          ),
        ],
      ),
    );
  }

  // 1. THE 5 COMMUNITY RESPONSIBILITY LEVELS + NUMERICAL TABLE
  Widget _buildCommunityLevelsView(BuildContext context, UserProfile? user, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Trinity Hero Banner
        _buildTrinityBanner(isDark),
        const SizedBox(height: 16),

        // Numerical Hierarchy Table Card
        _buildNumericalHierarchyTable(isDark),
        const SizedBox(height: 16),

        // Strict Rule Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade700.withOpacity(0.4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.rule_rounded, color: Colors.amber.shade800, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'THE MANDATORY RULE: ALL conditions must be met simultaneously. Someone with 10,000 Karma + 65% Trust is blocked from promotion. Someone with 6,000 Karma + 94% Trust + 120 verified deeds qualifies for Community Leader.',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, height: 1.3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _buildRoleStep(
          role: '👤 Level 1: New Member',
          subtitle: '0–99 Lifetime Karma • 0–4 Verified Deeds',
          desc: 'Starting status for everyone. Can do actions, report civic hazards, make wishes, earn Karma, and build baseline Trust.',
          responsibilities: CommunityRole.newMember.responsibilities,
          requirements: CommunityRole.newMember.promotionRequirements,
          reviewType: CommunityRole.newMember.reviewType,
          isCurrent: user?.communityRole == CommunityRole.newMember,
          color: Colors.grey,
        ),
        const SizedBox(height: 14),

        _buildRoleStep(
          role: '🌱 Level 2: Contributor',
          subtitle: '100+ Lifetime Karma • ≥70% Trust • ≥5 Verified Deeds',
          desc: 'Demonstrated active participation with verified photo proof and clean conduct record (0 violations). Unlocks enhanced passport.',
          responsibilities: CommunityRole.contributor.responsibilities,
          requirements: CommunityRole.contributor.promotionRequirements,
          reviewType: CommunityRole.contributor.reviewType,
          isCurrent: user?.communityRole == CommunityRole.contributor,
          color: Colors.green,
        ),
        const SizedBox(height: 14),

        _buildRoleStep(
          role: '🛡️ Level 3: Trusted Contributor',
          subtitle: '1,000+ Lifetime Karma • ≥80% Trust • ≥25 Verified Deeds',
          desc: 'High Trust score unlocks low-risk peer verification and mentoring assistance. Requires at least 5 successful community/help contributions.',
          responsibilities: CommunityRole.trustedContributor.responsibilities,
          requirements: CommunityRole.trustedContributor.promotionRequirements,
          reviewType: CommunityRole.trustedContributor.reviewType,
          isCurrent: user?.communityRole == CommunityRole.trustedContributor,
          color: Colors.blue,
        ),
        const SizedBox(height: 14),

        _buildRoleStep(
          role: '🤝 Level 4: Community Leader',
          subtitle: '5,000+ Lifetime Karma • ≥90% Trust • ≥100 Verified Deeds',
          desc: 'Initiative coordinator: creates local cleanups, organizes challenges, coordinates volunteers, and completes ≥3 community initiatives.',
          responsibilities: CommunityRole.communityLeader.responsibilities,
          requirements: CommunityRole.communityLeader.promotionRequirements,
          reviewType: CommunityRole.communityLeader.reviewType,
          isCurrent: user?.communityRole == CommunityRole.communityLeader,
          color: Colors.purple,
        ),
        const SizedBox(height: 14),

        _buildRoleStep(
          role: '🌟 Level 5: Karma Ambassador',
          subtitle: '25,000+ Lifetime Karma • ≥95% Trust • ≥300 Verified Deeds',
          desc: 'Highest honor of values representation. Requires ≥5 distinct impact categories, ≥12 months standing, and Human Governance Board review.',
          responsibilities: CommunityRole.karmaAmbassador.responsibilities,
          requirements: CommunityRole.karmaAmbassador.promotionRequirements,
          reviewType: CommunityRole.karmaAmbassador.reviewType,
          isCurrent: user?.communityRole == CommunityRole.karmaAmbassador,
          color: Colors.amber.shade800,
        ),
      ],
    );
  }

  Widget _buildNumericalHierarchyTable(bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.table_chart_rounded, size: 18, color: Color(0xFF00B074)),
                SizedBox(width: 8),
                Text(
                  '🏆 Karma Grid Individual Hierarchy',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 36,
                dataRowMinHeight: 38,
                dataRowMaxHeight: 46,
                columnSpacing: 14,
                headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF00B074)),
                columns: const [
                  DataColumn(label: Text('Lvl')),
                  DataColumn(label: Text('Position')),
                  DataColumn(label: Text('Karma')),
                  DataColumn(label: Text('Trust')),
                  DataColumn(label: Text('Verified')),
                  DataColumn(label: Text('Other Requirements')),
                ],
                rows: const [
                  DataRow(cells: [
                    DataCell(Text('1', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text('👤 New Member')),
                    DataCell(Text('0–99')),
                    DataCell(Text('—')),
                    DataCell(Text('0–4')),
                    DataCell(Text('Account verified')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('2', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text('🌱 Contributor')),
                    DataCell(Text('100+')),
                    DataCell(Text('≥70%')),
                    DataCell(Text('≥5')),
                    DataCell(Text('No serious violations')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('3', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text('🛡️ Trusted Contributor')),
                    DataCell(Text('1,000+')),
                    DataCell(Text('≥80%')),
                    DataCell(Text('≥25')),
                    DataCell(Text('≥5 help contributions')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('4', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text('🤝 Community Leader')),
                    DataCell(Text('5,000+')),
                    DataCell(Text('≥90%')),
                    DataCell(Text('≥100')),
                    DataCell(Text('≥3 completed initiatives')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('5', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text('🌟 Karma Ambassador')),
                    DataCell(Text('25,000+')),
                    DataCell(Text('≥95%')),
                    DataCell(Text('≥300')),
                    DataCell(Text('Human review + ≥12 mo + ≥5 cats')),
                  ]),
                ],
              ),
            ),
          ],
        ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent ? color.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? color : Colors.grey.withOpacity(0.25),
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isCurrent ? color : null),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                    ),
                  ],
                ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'CURRENT RANK',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9.5),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.35)),
          const SizedBox(height: 10),
          const Text('Unlocked Responsibilities:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
          const SizedBox(height: 4),
          ...responsibilities.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                    Expanded(child: Text(r, style: const TextStyle(fontSize: 11.5, height: 1.25))),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Promotion Review: $reviewType',
                    style: const TextStyle(fontSize: 10.5, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. 2D KARMA VS TRUST MATRIX VIEW + IMPACT DIVERSITY
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
                  '🔥 Impact Diversity & Anti-Gaming Engine',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.purple),
                ),
                SizedBox(height: 6),
                Text(
                  'Don\'t let anyone achieve 25,000 Karma through hundreds of tiny micro-actions. Impact Diversity requires contributions spanning at least 5 distinct domains to qualify for Ambassador.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.5, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 8 Impact Categories Showcase
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🌐 8 RECOGNIZED IMPACT CATEGORIES',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 1),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildCategoryChip('🌱 Environment', Colors.green),
                      _buildCategoryChip('📚 Education', Colors.blue),
                      _buildCategoryChip('🤝 Community', Colors.purple),
                      _buildCategoryChip('🐾 Animals', Colors.orange),
                      _buildCategoryChip('💧 Water Conservation', Colors.cyan),
                      _buildCategoryChip('🏥 Healthcare', Colors.redAccent),
                      _buildCategoryChip('💼 Employment & Skills', Colors.teal),
                      _buildCategoryChip('🏙️ Civic Improvement', Colors.indigo),
                    ],
                  ),
                ],
              ),
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
                  subtitle: 'High Volume / Questionable Proof',
                  verdict: '❌ NO PROMOTION (BLOCKED)',
                  color: Colors.redAccent,
                  isDark: isDark,
                  isUserHere: quadrant == KarmaTrustQuadrant.highKarmaLowTrust,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuadrantBox(
                  title: '🌟 High Karma • High Trust',
                  subtitle: 'Pillars of Impact (≥80% Trust)',
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
                  subtitle: 'High-Integrity Emerging',
                  verdict: '✅ PROGRESSION ACTIVE',
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
          const SizedBox(height: 16),

          // Aarav vs Maya Showcase
          _buildProfileComparisonCard(isDark),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
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
        color: isUserHere
            ? color.withOpacity(isDark ? 0.25 : 0.12)
            : (isDark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUserHere ? color : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          width: isUserHere ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                    color: color,
                  ),
                ),
              ),
              if (isUserHere)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'YOU',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10.5, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              verdict,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 9.5,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAntiGamingCharter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(isDark ? 0.2 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'Anti-Gaming & Farming Prevention',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Karma measures impact volume, but Trust measures fidelity. A user submitting 500 low-quality actions in a single category cannot reach Ambassador or Leader rank without diverse domain contributions and pristine community verification.',
            style: TextStyle(fontSize: 11.5, height: 1.4, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileComparisonCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CASE STUDY: WHY ALL-CONDITIONS MATTER',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          // User A
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 16),
                    SizedBox(width: 6),
                    Text('Aarav: 10,000 Karma + 65% Trust', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.redAccent)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Blocked from Trusted Contributor (requires ≥80% Trust). High volume cannot override low evidence fidelity.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // User B
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00B074).withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00B074).withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Color(0xFF00B074), size: 16),
                    SizedBox(width: 6),
                    Text('Maya: 6,000 Karma + 94% Trust + 120 Deeds', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF00B074))),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Promoted to Community Leader! Meets all 4 gates (Karma ≥5k, Trust ≥90%, Deeds ≥100, Initiatives ≥3).',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. THE "YOUR NEXT LEVEL" PROMOTION GATES VIEW
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
          // Your Next Level Summary Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 3,
            color: const Color(0xFF00B074).withOpacity(isDark ? 0.2 : 0.06),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('YOUR NEXT LEVEL', style: TextStyle(fontSize: 10.5, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          const SizedBox(height: 2),
                          Text(gateResult.targetRole.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF00B074))),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B074),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Level ${gateResult.targetRole.levelNumber}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress metrics row
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _buildMetricSummaryPill('⭐ Karma', gateResult.karmaDetail, gateResult.karmaPassed),
                      _buildMetricSummaryPill('🌍 Deeds', gateResult.verificationDetail, gateResult.verificationPassed),
                      _buildMetricSummaryPill('🛡️ Trust', gateResult.trustDetail, gateResult.trustPassed),
                      _buildMetricSummaryPill('🌐 Diversity', gateResult.categoryDiversityDetail, gateResult.categoryDiversityPassed),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: gateResult.overallProgress,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00B074)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Overall Gate Readiness: ${(gateResult.overallProgress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
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
            title: '① Lifetime Karma Gate (Cumulative)',
            desc: 'Karma is not reset on promotion (0 → 100 → 1,000 → 5,000 → 25,000 ⭐).',
            status: gateResult.karmaDetail,
            progress: gateResult.karmaProgress,
            passed: gateResult.karmaPassed,
            color: const Color(0xFF00B074),
          ),
          const SizedBox(height: 10),

          _buildGateTile(
            gateNum: 2,
            title: '② Verified Contributions Gate',
            desc: 'Real-world actions verified through before/after proof & community consensus.',
            status: gateResult.verificationDetail,
            progress: gateResult.verificationProgress,
            passed: gateResult.verificationPassed,
            color: Colors.blue,
          ),
          const SizedBox(height: 10),

          _buildGateTile(
            gateNum: 3,
            title: '③ Mandatory Trust Gate',
            desc: 'Evidence fidelity & zero false reporting. Trust is a non-negotiable prerequisite.',
            status: gateResult.trustDetail,
            progress: gateResult.trustProgress,
            passed: gateResult.trustPassed,
            color: Colors.purple,
          ),
          const SizedBox(height: 10),

          _buildGateTile(
            gateNum: 4,
            title: '④ Role-Specific & Conduct Gate',
            desc: 'Clean record (0 violations), help contributions, initiatives led, or human review.',
            status: gateResult.conductDetail,
            progress: gateResult.conductProgress,
            passed: gateResult.conductPassed,
            color: Colors.orange,
          ),
          const SizedBox(height: 10),

          _buildGateTile(
            gateNum: 5,
            title: '🔥 Impact Diversity Gate',
            desc: 'Must span cross-domain categories to prevent tiny repetitive micro-spam.',
            status: gateResult.categoryDiversityDetail,
            progress: gateResult.categoryDiversityProgress,
            passed: gateResult.categoryDiversityPassed,
            color: Colors.teal,
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

  Widget _buildGateTile({
    required int gateNum,
    required String title,
    required String desc,
    required String status,
    required double progress,
    required bool passed,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: passed ? color.withOpacity(0.06) : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: passed ? color.withOpacity(0.4) : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: passed ? color : Colors.grey.shade400,
                ),
                child: Icon(
                  passed ? Icons.check : Icons.lock_outline_rounded,
                  size: 12,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: passed ? color : Colors.grey.shade700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (passed ? color : Colors.grey).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: passed ? color : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.3),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(passed ? color : Colors.grey),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricSummaryPill(String title, String value, bool passed) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(passed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, size: 12, color: passed ? const Color(0xFF00B074) : Colors.grey),
        const SizedBox(width: 4),
        Text(
          '$title: $value',
          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: passed ? const Color(0xFF00B074) : Colors.grey.shade700),
        ),
      ],
    );
  }

  // 4. DEMOTION RULES & TRUST LOSS CENTER
  Widget _buildDemotionRulesView(BuildContext context, UserProfile? user, bool isDark) {
    final demotionRisk = user != null
        ? PromotionEngine.evaluateDemotionRisk(user)
        : const DemotionRiskResult(isAtRisk: false, isCurrentlySuspended: false, currentTrust: 1.0, requiredTrust: 0.0, violationCount: 0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Demotion Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.redAccent.withOpacity(isDark ? 0.2 : 0.08),
            border: Border.all(color: Colors.redAccent.withOpacity(0.35)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 22),
                  SizedBox(width: 8),
                  Text(
                    '🛡️ Status Isn\'t Permanent: Demotion Rules',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.redAccent),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'The system works downward as well as upward. Earned responsibility can be lost if trust is lost.',
                style: TextStyle(fontSize: 11.5, height: 1.3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Live User Demotion Risk Status
        if (demotionRisk.isCurrentlySuspended) ...[
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            color: Colors.redAccent.withOpacity(0.12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    child: Icon(Icons.block_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '⚠️ RESPONSIBILITY PRIVILEGES SUSPENDED',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Colors.redAccent),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          demotionRisk.warningMessage ?? 'Your privileges are currently paused.',
                          style: const TextStyle(fontSize: 11, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ] else ...[
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            color: const Color(0xFF00B074).withOpacity(0.08),
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(0xFF00B074),
                    child: Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '✅ Account In Good Standing',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF00B074)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Zero conduct violations and trust score meets or exceeds current responsibility tier.',
                          style: TextStyle(fontSize: 10.5, color: Colors.grey),
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

        // Demotion Rules Table Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📋 DEMOTION & PENALTY MATRIX',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 1),
                ),
                const SizedBox(height: 10),
                _buildDemotionRow('Trust falls below required threshold', 'Promotion locked & responsibilities suspended', Colors.orange),
                const Divider(height: 16),
                _buildDemotionRow('Repeated false claims / blurry photos', 'Trust score reduction (–5% to –20%)', Colors.orange),
                const Divider(height: 16),
                _buildDemotionRow('Serious fraud / duplicate photo sybil attack', 'Immediate suspension & Trust Center investigation', Colors.redAccent),
                const Divider(height: 16),
                _buildDemotionRow('Proven manipulation / fake witnesses', 'Karma reversal + Trust reset + penalty log', Colors.redAccent),
                const Divider(height: 16),
                _buildDemotionRow('Abuse of leadership / peer verification', 'Permanent loss of leadership & verification privileges', Colors.red.shade900),
                const Divider(height: 16),
                _buildDemotionRow('Account suspension', 'All status suspended across network', Colors.red.shade900),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDemotionRow(String event, String consequence, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.remove_circle_outline_rounded, size: 14, color: color),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(event, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(consequence, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ),
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

