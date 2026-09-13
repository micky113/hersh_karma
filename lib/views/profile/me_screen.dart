import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/karma_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../models/user_profile.dart';
import '../../core/localization/app_localizations.dart';

class MeScreen extends StatefulWidget {
  const MeScreen({super.key});

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> with SingleTickerProviderStateMixin {
  late TabController _historyTabController;

  @override
  void initState() {
    super.initState();
    _historyTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _historyTabController.dispose();
    super.dispose();
  }

  String _getReputationBadge(BuildContext context, int rep) {
    if (rep >= 85) return AppLocalizations.translateWithContext(context, 'rep_gold', defaultValue: '👑 Gold Validator');
    if (rep >= 70) return AppLocalizations.translateWithContext(context, 'rep_silver', defaultValue: '🛡️ Silver Contributor');
    return AppLocalizations.translateWithContext(context, 'rep_citizen', defaultValue: '🌱 Green Citizen');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final karmaProvider = Provider.of<KarmaProvider>(context);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.translateWithContext(context, 'nav_me', defaultValue: 'Me'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. USER PROFILE HEADER
            _buildProfileHeader(context, user, theme),
            const SizedBox(height: 20),

            // 2. KARMA, IMPACT & TRUST SUMMARY
            _buildMetricsOverview(context, user, theme),
            const SizedBox(height: 20),

            // 3. KARMA PASSPORT CERTIFICATE CARD
            _buildPassportCard(context, user, theme),
            const SizedBox(height: 12),

            // 3b. ROLE & GOVERNANCE HIERARCHY CARD
            _buildRoleHierarchyCard(context, user, theme),
            const SizedBox(height: 24),

            // 4. MY HISTORY (My Actions & My Reports)
            _buildHistorySection(context, karmaProvider, theme),
            const SizedBox(height: 24),

            // 5. QUICK SETTINGS & LOGOUT
            _buildQuickSettings(context, authProvider, user, theme),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile user, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: const Color(0xFF00B074).withOpacity(0.12),
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF00B074)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(user.email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B074).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getReputationBadge(context, user.reputationScore),
                          style: const TextStyle(color: Color(0xFF00B074), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.communityRole.label,
                          style: const TextStyle(color: Colors.purple, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.badge_outlined, color: Colors.blue),
              tooltip: 'Karma Legacy Profile',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.profileDetail),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsOverview(BuildContext context, UserProfile user, ThemeData theme) {
    return Row(
      children: [
        // Karma Credits
        Expanded(
          child: _buildMetricTile(
            title: AppLocalizations.translateWithContext(context, 'dash_karma', defaultValue: '✨ Karma'),
            value: '${user.karmaCredits}',
            subtitle: AppLocalizations.translateWithContext(context, 'me_metric_recog', defaultValue: 'Recognition earned'),
            color: const Color(0xFF00B074),
            onTap: () => Navigator.pushNamed(context, AppRoutes.rewards),
          ),
        ),
        const SizedBox(width: 10),

        // Impact
        Expanded(
          child: _buildMetricTile(
            title: AppLocalizations.translateWithContext(context, 'dash_impact', defaultValue: '🌍 Impact'),
            value: '${user.verifiedSubmissions}',
            subtitle: AppLocalizations.translateWithContext(context, 'me_metric_verified', defaultValue: 'Verified deeds'),
            color: Colors.blue,
            onTap: () => Navigator.pushNamed(context, AppRoutes.impactExchange),
          ),
        ),
        const SizedBox(width: 10),

        // Trust
        Expanded(
          child: _buildMetricTile(
            title: AppLocalizations.translateWithContext(context, 'dash_trust', defaultValue: '🛡️ Trust'),
            value: '${(user.trustScore * 100).toInt()}%',
            subtitle: AppLocalizations.translateWithContext(context, 'me_metric_trust', defaultValue: 'Audited trust'),
            color: Colors.purple,
            onTap: () => Navigator.pushNamed(context, AppRoutes.karmaFirewall),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 8, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPassportCard(BuildContext context, UserProfile user, ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF00B074),
          child: Icon(Icons.verified_user_rounded, color: Colors.white),
        ),
        title: Text(
          AppLocalizations.translateWithContext(context, 'me_passport', defaultValue: '🪪 Karma Passport'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          AppLocalizations.translateWithContext(context, 'me_passport_sub', defaultValue: 'Your complete record of verified real-world impact'),
          style: const TextStyle(fontSize: 11),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF00B074)),
        onTap: () => Navigator.pushNamed(context, AppRoutes.profileDetail),
      ),
    );
  }

  Widget _buildRoleHierarchyCard(BuildContext context, UserProfile user, ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.purple.withOpacity(0.04),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple,
          child: Text(
            'L${user.communityRole.levelNumber}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        title: Text(
          '👑 Level ${user.communityRole.levelNumber}: ${user.communityRole.title}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          '${user.communityRole.tagline} • 4 Promotion Gates & 2D Matrix',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.purple),
        onTap: () => Navigator.pushNamed(context, AppRoutes.roleHierarchy),
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context, KarmaProvider karmaProvider, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          controller: _historyTabController,
          labelColor: const Color(0xFF00B074),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF00B074),
          indicatorWeight: 3,
          tabs: [
            Tab(text: '${AppLocalizations.translateWithContext(context, 'me_my_actions', defaultValue: '🌱 My Actions')} (${karmaProvider.myActions.length})'),
            Tab(text: '${AppLocalizations.translateWithContext(context, 'me_my_reports', defaultValue: '🔎 My Reports')} (3)'),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: TabBarView(
            controller: _historyTabController,
            children: [
              // My Actions
              karmaProvider.myActions.isEmpty
                  ? Center(child: Text(AppLocalizations.translateWithContext(context, 'me_no_actions', defaultValue: 'No actions submitted yet. Tap + Create!'), style: const TextStyle(color: Colors.grey, fontSize: 12)))
                  : ListView.builder(
                      itemCount: karmaProvider.myActions.length,
                      itemBuilder: (context, index) {
                        final action = karmaProvider.myActions[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(action.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            subtitle: Text('Status: ${action.status.name.toUpperCase()}', style: const TextStyle(fontSize: 10, color: Colors.green)),
                            trailing: Text('+${action.creditsAwarded} Karma', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),

              // My Reports
              ListView(
                children: const [
                  Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('Garbage dump near school gate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      subtitle: Text('Status: RESOLVED & VERIFIED (+20 Karma)', style: TextStyle(fontSize: 10, color: Colors.green)),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('Injured street puppy in Sector 4', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      subtitle: Text('Status: ADOPTED BY SHELTER', style: TextStyle(fontSize: 10, color: Colors.blue)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickSettings(BuildContext context, AuthProvider authProvider, UserProfile user, ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.language_rounded, color: Colors.blue),
            title: Text(AppLocalizations.translateWithContext(context, 'me_lang_region', defaultValue: 'Language & Region'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: Text(authProvider.currentLanguage, style: const TextStyle(fontSize: 11)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
            onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.swap_horiz_rounded, color: Colors.purple),
            title: Text(AppLocalizations.translateWithContext(context, 'me_interface_mode', defaultValue: 'Interface Mode'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: Text(user.interfaceMode == AppInterfaceMode.simple ? 'Simple (High Accessibility)' : 'Standard (Full Dashboard)', style: const TextStyle(fontSize: 11)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
            onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: Text(AppLocalizations.translateWithContext(context, 'me_logout', defaultValue: 'Logout'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red)),
            onTap: () async {
              await authProvider.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
          ),
        ],
      ),
    );
  }
}
