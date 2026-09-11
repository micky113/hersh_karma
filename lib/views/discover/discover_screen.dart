import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/karma_provider.dart';
import '../../models/karma_category.dart';
import '../../models/karma_activity.dart';
import '../../data/karma_grid_presets.dart';
import '../../core/localization/app_localizations.dart';
import '../map/impact_map_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final karmaProvider = Provider.of<KarmaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.translateWithContext(context, 'nav_discover', defaultValue: 'Discover'),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(106),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.translateWithContext(context, 'disc_search_hint', defaultValue: 'Search actions, problems, organizations...'),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.mic, color: Color(0xFF00B074)),
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.search);
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim().toLowerCase();
                    });
                  },
                ),
              ),
              // TabBar
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: const Color(0xFF00B074),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF00B074),
                indicatorWeight: 3,
                tabs: [
                  Tab(text: AppLocalizations.translateWithContext(context, 'disc_tab_actions', defaultValue: '🌱 Actions')),
                  Tab(text: AppLocalizations.translateWithContext(context, 'disc_tab_problems', defaultValue: '🚨 Problems')),
                  Tab(text: AppLocalizations.translateWithContext(context, 'disc_tab_challenges', defaultValue: '🏆 Challenges')),
                  Tab(text: AppLocalizations.translateWithContext(context, 'disc_tab_map', defaultValue: '🌍 Impact Map')),
                  Tab(text: AppLocalizations.translateWithContext(context, 'disc_tab_orgs', defaultValue: '🤝 Organizations')),
                  Tab(text: AppLocalizations.translateWithContext(context, 'disc_tab_missions', defaultValue: '🇮🇳 Missions & AI')),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. ACTIONS
          _buildActionsTab(context, karmaProvider),

          // 2. PROBLEMS
          _buildProblemsTab(context, karmaProvider),

          // 3. CHALLENGES
          _buildChallengesTab(context, karmaProvider),

          // 4. IMPACT MAP
          const ImpactMapWidget(isFullScreen: true),

          // 5. ORGANIZATIONS
          _buildOrganizationsTab(context),

          // 6. MISSIONS & AI
          _buildMissionsTab(context),
        ],
      ),
    );
  }

  Widget _buildActionsTab(BuildContext context, KarmaProvider karmaProvider) {
    final allActivities = karmaGridPresets;
    final filtered = _searchQuery.isEmpty
        ? allActivities.take(30).toList()
        : allActivities.where((a) => a.title.toLowerCase().contains(_searchQuery) || a.category.name.toLowerCase().contains(_searchQuery)).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final activity = filtered[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF00B074).withOpacity(0.12),
                  child: const Text('🌱', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(activity.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('${activity.effortRating} Effort • +${activity.baseImpact} Karma', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 74,
                  height: 32,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B074),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      karmaProvider.prefilledPreset = activity;
                      Navigator.pushNamed(context, AppRoutes.uploadProof);
                    },
                    child: Text(
                      AppLocalizations.translateWithContext(context, 'disc_do_this', defaultValue: 'Do This'),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProblemsTab(BuildContext context, KarmaProvider karmaProvider) {
    final problems = karmaProvider.problems;
    if (problems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.translateWithContext(context, 'disc_no_problems', defaultValue: 'No unresolved problems in your area!'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.reportAbuse),
              child: Text(AppLocalizations.translateWithContext(context, 'disc_report_issue', defaultValue: 'Report a new issue')),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: problems.length,
      itemBuilder: (context, index) {
        final problem = problems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(problem.category.name.toUpperCase(), style: const TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                    const Spacer(),
                    Text('By ${problem.reporterName}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(problem.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(problem.description, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Reward: +${problem.reporterReward} Karma', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 11)),
                    SizedBox(
                      width: 86,
                      height: 32,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          // Prefill deed solving this problem
                          karmaProvider.prefilledPreset = KarmaActivity(
                            id: 'solve_${problem.id}',
                            title: 'Solve: ${problem.title}',
                            tier: 2,
                            category: problem.category,
                            baseImpact: 50,
                            effortRating: 'Medium',
                            verificationMethod: VerificationMethod.gpsAndImage,
                            frequencyLimit: FrequencyLimit.unlimited,
                          );
                          Navigator.pushNamed(context, AppRoutes.uploadProof);
                        },
                        child: Text(
                          AppLocalizations.translateWithContext(context, 'disc_fix_earn', defaultValue: 'Fix & Earn'),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChallengesTab(BuildContext context, KarmaProvider karmaProvider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildChallengeCard(
          context,
          title: AppLocalizations.translateWithContext(context, 'chal_plastic_title', defaultValue: 'Global Plastic Recovery Drive 🌍'),
          description: AppLocalizations.translateWithContext(context, 'chal_plastic_desc', defaultValue: 'Collect & photograph 5 items of plastic waste. 1.5x Multiplier today!'),
          participants: '1,420 volunteers',
          reward: '+75 Karma Credits',
        ),
        const SizedBox(height: 12),
        _buildChallengeCard(
          context,
          title: AppLocalizations.translateWithContext(context, 'chal_tree_title', defaultValue: 'Delhi Tree Nurture Drive 🌳'),
          description: AppLocalizations.translateWithContext(context, 'chal_tree_desc', defaultValue: 'Water and mulch 3 young neighborhood saplings.'),
          participants: '840 volunteers',
          reward: '+60 Karma Credits',
        ),
        const SizedBox(height: 12),
        _buildChallengeCard(
          context,
          title: AppLocalizations.translateWithContext(context, 'chal_animal_title', defaultValue: 'Stray Animal Winter Aid 🐾'),
          description: AppLocalizations.translateWithContext(context, 'chal_animal_desc', defaultValue: 'Set out clean water bowls and warm bedding for neighborhood strays.'),
          participants: '610 volunteers',
          reward: '+50 Karma Credits',
        ),
      ],
    );
  }

  Widget _buildChallengeCard(BuildContext context, {required String title, required String description, required String participants, required String reward}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(description, style: const TextStyle(fontSize: 11, color: Colors.black87)),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(participants, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                const Spacer(),
                Text(reward, style: const TextStyle(color: Color(0xFF00B074), fontWeight: FontWeight.bold, fontSize: 11)),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B074),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.uploadProof),
                  child: Text(
                    AppLocalizations.translateWithContext(context, 'disc_join', defaultValue: 'Join'),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizationsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Business Portal Launcher
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: const Color(0xFF00B074).withOpacity(0.08),
          child: ListTile(
            leading: const Text('🏢', style: TextStyle(fontSize: 28)),
            title: const Text(
              'Organizations & CSR Enterprise Hub',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF00B074)),
            ),
            subtitle: const Text(
              'For Companies (ESG/CSR), Schools & NGOs • Challenges, Dashboards & Ethics',
              style: TextStyle(fontSize: 10.5),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF00B074)),
            onTap: () => Navigator.pushNamed(context, AppRoutes.businessPortal),
          ),
        ),
        const SizedBox(height: 14),

        _buildOrgTile(
          context,
          name: AppLocalizations.translateWithContext(context, 'org_green_earth', defaultValue: 'Green Earth Foundation 🌍'),
          category: AppLocalizations.translateWithContext(context, 'org_green_earth_cat', defaultValue: 'Environment & Forestry'),
          rating: AppLocalizations.translateWithContext(context, 'org_verified_ngo', defaultValue: '🛡️ Verified NGO • 98% Trust'),
          deedsCompleted: '14,200 Deeds',
        ),
        const SizedBox(height: 10),
        _buildOrgTile(
          context,
          name: AppLocalizations.translateWithContext(context, 'org_apex', defaultValue: 'Apex Academy 🏫'),
          category: AppLocalizations.translateWithContext(context, 'org_apex_cat', defaultValue: 'Civic Education & Youth'),
          rating: AppLocalizations.translateWithContext(context, 'org_verified_school', defaultValue: '🛡️ Verified School • 95% Trust'),
          deedsCompleted: '3,800 Deeds',
        ),
        const SizedBox(height: 10),
        _buildOrgTile(
          context,
          name: AppLocalizations.translateWithContext(context, 'org_mcd', defaultValue: 'Municipal Corporation Delhi 🏛️'),
          category: AppLocalizations.translateWithContext(context, 'org_mcd_cat', defaultValue: 'Civic Sanitation & Infrastructure'),
          rating: AppLocalizations.translateWithContext(context, 'org_verified_muni', defaultValue: '🛡️ Verified Authority • 92% Trust'),
          deedsCompleted: '28,400 Deeds',
        ),
      ],
    );
  }

  Widget _buildOrgTile(BuildContext context, {required String name, required String category, required String rating, required String deedsCompleted}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.12),
              child: const Text('🏢', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(category, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text(rating, style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(deedsCompleted, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Impact Marketplace Card
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: const Text('🛍️', style: TextStyle(fontSize: 32)),
            title: const Text(
              'Impact Marketplace & Opportunities',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: const Text(
              'Verified eco products, student mentoring, fellowships, and social internships',
              style: TextStyle(fontSize: 11),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF00B074)),
            onTap: () => Navigator.pushNamed(context, AppRoutes.marketplace),
          ),
        ),
        const SizedBox(height: 12),

        // India 30 Hub Card
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: const Text('🇮🇳', style: TextStyle(fontSize: 32)),
            title: Text(
              AppLocalizations.translateWithContext(context, 'mission_india30_title', defaultValue: 'India 30 Mission Hub'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              AppLocalizations.translateWithContext(context, 'mission_india30_sub', defaultValue: 'National targets for clean water, waste recovery, and education'),
              style: const TextStyle(fontSize: 11),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF00B074)),
            onTap: () => Navigator.pushNamed(context, AppRoutes.indiaMission),
          ),
        ),
        const SizedBox(height: 12),

        // Ecosystem Flywheel Hub Card
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: const Text('🌐', style: TextStyle(fontSize: 32)),
            title: Text(
              AppLocalizations.translateWithContext(context, 'mission_flywheel_title', defaultValue: 'Ecosystem Flywheel & AI Core'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              AppLocalizations.translateWithContext(context, 'mission_flywheel_sub', defaultValue: 'YouTube Stories, Karma Graph, and Collective Intelligence Query Engine'),
              style: const TextStyle(fontSize: 11),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF00B074)),
            onTap: () => Navigator.pushNamed(context, AppRoutes.ecosystemHub),
          ),
        ),
      ],
    );
  }
}
