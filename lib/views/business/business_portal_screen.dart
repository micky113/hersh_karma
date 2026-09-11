import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/karma_provider.dart';
import '../../core/routes/app_routes.dart';

class BusinessPortalScreen extends StatefulWidget {
  const BusinessPortalScreen({super.key});

  @override
  State<BusinessPortalScreen> createState() => _BusinessPortalScreenState();
}

class _BusinessPortalScreenState extends State<BusinessPortalScreen> with SingleTickerProviderStateMixin {
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

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🏢 ', style: TextStyle(fontSize: 20)),
            Text(
              'Organizations & CSR Hub',
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
            Tab(text: '🏢 Companies & CSR'),
            Tab(text: '🏫 Schools & Colleges'),
            Tab(text: '🤝 NGOs & Non-Profits'),
            Tab(text: '🛡️ Monetary Ethics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCorporateView(context, isDark, theme),
          _buildSchoolView(context, isDark, theme),
          _buildNgoView(context, isDark, theme),
          _buildEthicsView(context, isDark, theme),
        ],
      ),
    );
  }

  // 1. COMPANIES & CSR VIEW
  Widget _buildCorporateView(BuildContext context, bool isDark, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Banner
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🏢', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Karma Grid for Business & ESG',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF00B074)),
                          ),
                          Text(
                            'Verified Employee Engagement, CSR Campaigns & Audit-Ready ESG Reports',
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🎉 CSR Pilot Demo requested! Our enterprise team will connect within 24h.'),
                        backgroundColor: Color(0xFF00B074),
                      ),
                    );
                  },
                  icon: const Icon(Icons.rocket_launch_rounded, size: 16),
                  label: const Text('Schedule Enterprise Demo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B074),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // LIVE ESG DASHBOARD PREVIEW
          const Text(
            'ENTERPRISE ESG & CSR DASHBOARD (SAMPLE)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Colors.grey, letterSpacing: 1.1),
          ),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tata Consultancy Services (CSR)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B074).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('FY 2025-26 Active', style: TextStyle(fontSize: 10, color: Color(0xFF00B074), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem('5,420', 'Employees Enrolled', Colors.blue),
                      _buildMetricItem('42,800', 'Verified Actions', const Color(0xFF00B074)),
                      _buildMetricItem('18,400', 'Beneficiaries', Colors.purple),
                      _buildMetricItem('98.4%', 'Audit Pass Rate', Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 18),
                      const SizedBox(width: 8),
                      const Text('Audit-Ready BRSR & ESG Report Generated', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Downloading sample BRSR / ESG Compliance PDF...')),
                          );
                        },
                        child: const Text('Download PDF', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // SPONSORED CHALLENGE MODEL
          const Text(
            'CORPORATE-SPONSORED CAMPAIGNS',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Colors.grey, letterSpacing: 1.1),
          ),
          const SizedBox(height: 10),
          _buildChallengeCard(
            title: 'Clean India 100-City Mission',
            sponsor: 'Hindustan Unilever CSR Foundation',
            budget: '₹25 Lakh Grant Pool',
            participants: '10,000+ Citizens Across 100 Cities',
            impact: '150 Tons Waste Segregated & Composted',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildChallengeCard(
            title: 'Solar Literacy & Rural School Lighting',
            sponsor: 'Infosys Foundation',
            budget: '₹40 Lakh Equipment Fund',
            participants: '500 Engineers & Student Mentors',
            impact: '120 Village Schools Electrified',
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          // PRICING TIERS
          const Text(
            'ENTERPRISE PRICING TIERS',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Colors.grey, letterSpacing: 1.1),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildPricingCard('Starter', '₹25k - ₹1L / yr', '< 500 Staff', 'Basic CSR & Badges')),
              const SizedBox(width: 10),
              Expanded(child: _buildPricingCard('Enterprise', '₹5L - ₹25L+ / yr', '5,000+ Staff', 'Full ESG & API Access', isFeatured: true)),
            ],
          ),
        ],
      ),
    );
  }

  // 2. SCHOOLS & COLLEGES VIEW
  Widget _buildSchoolView(BuildContext context, bool isDark, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.blue.withOpacity(isDark ? 0.2 : 0.08),
              border: Border.all(color: Colors.blue.withOpacity(0.35)),
            ),
            child: Row(
              children: [
                const Text('🏫', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Karma Campus for Schools & Colleges', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue)),
                      const SizedBox(height: 2),
                      Text('Turn student enthusiasm into verifiable community service credits & awards.', style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.grey.shade700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // School Dashboard Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Delhi Public School (R.K. Puram)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  const Text('Challenge: 1,000 Students → 10,000 Hours of Community Service', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 14),
                  LinearProgressIndicator(value: 0.79, backgroundColor: Colors.grey.shade200, color: Colors.blue),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('7,934 Hours Verified', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue)),
                      Text('Target: 10,000 Hours', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem('1,240', 'Students', Colors.blue),
                      _buildMetricItem('8,421', 'Deeds Logged', Colors.green),
                      _buildMetricItem('52,800', 'Impact Units', Colors.purple),
                      _buildMetricItem('184k', 'Karma Earned', const Color(0xFF00B074)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🎓 School Challenge Registration Started!'), backgroundColor: Colors.blue),
              );
            },
            icon: const Icon(Icons.school_rounded),
            label: const Text('Register Your School / College'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // 3. NGOS & NON-PROFITS VIEW
  Widget _buildNgoView(BuildContext context, bool isDark, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.purple.withOpacity(isDark ? 0.2 : 0.08),
              border: Border.all(color: Colors.purple.withOpacity(0.35)),
            ),
            child: Row(
              children: [
                const Text('🤝', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Karma Grid SaaS for NGOs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.purple)),
                      const SizedBox(height: 2),
                      Text('Free basic tier for all verified non-profits. Manage volunteers, projects, and impact proof.', style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.grey.shade700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildNgoFeatureTile(Icons.people_alt_rounded, 'Volunteer Mobilization', 'Assign volunteers to verified problem hotspots on the live Google Impact Map.'),
          _buildNgoFeatureTile(Icons.verified_rounded, 'Consensus Verification Tools', 'Empower staff to validate deeds with Level 4 Organization endorsement.'),
          _buildNgoFeatureTile(Icons.card_giftcard_rounded, 'Wish Fulfillment Pipeline', 'Route sponsor funds directly to verified equipment and training milestones.'),
          _buildNgoFeatureTile(Icons.analytics_rounded, 'Grant & Impact Reports', 'Export audit-ready evidence packets for international and CSR donors.'),
        ],
      ),
    );
  }

  // 4. MONETARY ETHICS & TRUST CHARTER VIEW
  Widget _buildEthicsView(BuildContext context, bool isDark, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF00B074).withOpacity(isDark ? 0.2 : 0.08),
              border: Border.all(color: const Color(0xFF00B074).withOpacity(0.4)),
            ),
            child: const Column(
              children: [
                Text('🛡️ The Karma Grid Trust & Ethics Charter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF00B074))),
                SizedBox(height: 6),
                Text(
                  '"Karma is not money. Impact creates value; Karma records recognition; the platform monetizes the infrastructure around verified impact."',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 11.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'THE 6 STRICT NEGATIVE MONETIZATION BOUNDARIES',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Colors.grey, letterSpacing: 1.1),
          ),
          const SizedBox(height: 12),
          _buildBoundaryItem('❌ Karma is NEVER Sold', 'You can never pay ₹999 to buy Karma credits. Karma must always be earned through verified real-world good.'),
          _buildBoundaryItem('❌ Zero Pay-to-Win', 'No user or company can pay to rank higher or manipulate their proof standing.'),
          _buildBoundaryItem('❌ Verification is NEVER Bought', 'We never sell "instant verification". Every claim passes the same 5-tier evidence and consensus firewall.'),
          _buildBoundaryItem('❌ No Public Poverty Leaderboards', 'Wishes and beneficiaries are supported with dignity, never exploited as marketing spectacle.'),
          _buildBoundaryItem('❌ Personal Data is NEVER Sold', 'We never sell user profiles or browsing records. We only monetize aggregated, permissioned impact analytics.'),
          _buildBoundaryItem('❌ Zero Fake Impact Statistics', 'Every number is backed by cryptographic timestamping and reproducible before/after evidence.'),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 9.5, color: Colors.grey)),
      ],
    );
  }

  Widget _buildChallengeCard({
    required String title,
    required String sponsor,
    required String budget,
    required String participants,
    required String impact,
    required bool isDark,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B074).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(budget, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF00B074))),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Sponsored by: $sponsor', style: const TextStyle(fontSize: 11, color: Colors.blue)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.people_outline_rounded, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(participants, style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.eco_rounded, size: 14, color: Colors.green),
                const SizedBox(width: 4),
                Text(impact, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard(String tier, String price, String scope, String features, {bool isFeatured = false}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isFeatured ? const BorderSide(color: Color(0xFF00B074), width: 1.5) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tier, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isFeatured ? const Color(0xFF00B074) : null)),
            const SizedBox(height: 4),
            Text(price, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
            const SizedBox(height: 2),
            Text(scope, style: const TextStyle(fontSize: 9.5, color: Colors.grey)),
            const SizedBox(height: 6),
            Text(features, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildNgoFeatureTile(IconData icon, String title, String desc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: Colors.purple.withOpacity(0.12),
          child: Icon(icon, size: 16, color: Colors.purple),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
        subtitle: Text(desc, style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
      ),
    );
  }

  Widget _buildBoundaryItem(String title, String desc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.redAccent)),
            const SizedBox(height: 3),
            Text(desc, style: const TextStyle(fontSize: 10.5, color: Colors.grey, height: 1.25)),
          ],
        ),
      ),
    );
  }
}
