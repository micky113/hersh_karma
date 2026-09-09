import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/karma_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../models/user_profile.dart';
import '../../core/localization/app_localizations.dart';
import '../widgets/visual_journey_banner.dart';
import '../widgets/universal_search_bar.dart';
import '../widgets/demo_badge.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _getReputationBadge(BuildContext context, int rep) {
    if (rep >= 85) return AppLocalizations.translateWithContext(context, 'rep_gold', defaultValue: '👑 Gold Validator');
    if (rep >= 70) return AppLocalizations.translateWithContext(context, 'rep_silver', defaultValue: '🛡️ Silver Contributor');
    return AppLocalizations.translateWithContext(context, 'rep_citizen', defaultValue: '🌱 Green Citizen');
  }

  Color _getBadgeColor(int rep) {
    if (rep >= 85) return const Color(0xFFFFD700);
    if (rep >= 70) return const Color(0xFFC0C0C0);
    return const Color(0xFFCD7F32);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AuthProvider>(context).currentUser;
    final karmaProvider = Provider.of<KarmaProvider>(context);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. WELCOME HEADER + TRUST BADGE
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF00B074).withOpacity(0.12),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Color(0xFF00B074),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.translateWithContext(context, 'dash_welcome', defaultValue: 'Welcome back') + ',',
                      style: theme.textTheme.bodySmall?.copyWith(color: isDark ? Colors.white60 : Colors.grey[600]),
                    ),
                    Text(
                      user.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getBadgeColor(user.reputationScore).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getBadgeColor(user.reputationScore).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getReputationBadge(context, user.reputationScore),
                  style: TextStyle(
                    color: _getBadgeColor(user.reputationScore).withOpacity(0.95),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. COMPACT SUMMARY (Karma, Impact, Trust)
          Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMiniMetric(
                    AppLocalizations.translateWithContext(context, 'dash_karma', defaultValue: '✨ Karma'),
                    '${user.karmaCredits} ${AppLocalizations.translateWithContext(context, 'unit_credits', defaultValue: 'Credits')}',
                    const Color(0xFF00B074),
                  ),
                  Container(height: 24, width: 1, color: isDark ? Colors.white12 : Colors.grey.shade300),
                  _buildMiniMetric(
                    AppLocalizations.translateWithContext(context, 'dash_impact', defaultValue: '🌍 Impact'),
                    '${user.verifiedSubmissions} ${AppLocalizations.translateWithContext(context, 'unit_verified', defaultValue: 'Verified')}',
                    Colors.blue,
                  ),
                  Container(height: 24, width: 1, color: isDark ? Colors.white12 : Colors.grey.shade300),
                  _buildMiniMetric(
                    AppLocalizations.translateWithContext(context, 'dash_trust', defaultValue: '🛡️ Trust'),
                    '${(user.trustScore * 100).toInt()}% ${AppLocalizations.translateWithContext(context, 'unit_rating', defaultValue: 'Rating')}',
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 3. UNIVERSAL SEARCH BAR + VOICE AGENT
          const UniversalSearchBar(),
          const SizedBox(height: 12),

          // 4. VISUAL JOURNEY BANNER (Proof-of-Good progression)
          const VisualJourneyBanner(compact: true),
          const SizedBox(height: 14),

          // 5. THE 4 PRIMARY DECISION CARDS ("What can I do now?")
          Row(
            children: [
              // 🌱 DO GOOD
              Expanded(
                child: _buildPrimaryActionCard(
                  context,
                  emoji: '🌱',
                  title: AppLocalizations.translateWithContext(context, 'dash_action_do', defaultValue: 'DO GOOD'),
                  subtitle: AppLocalizations.translateWithContext(context, 'dash_action_do_sub', defaultValue: 'Find a deed & prove impact'),
                  color: const Color(0xFF00B074),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.submitDeed),
                ),
              ),
              const SizedBox(width: 10),

              // 🔎 REPORT PROBLEM
              Expanded(
                child: _buildPrimaryActionCard(
                  context,
                  emoji: '🔎',
                  title: AppLocalizations.translateWithContext(context, 'dash_action_report', defaultValue: 'REPORT'),
                  subtitle: AppLocalizations.translateWithContext(context, 'dash_action_report_sub', defaultValue: 'Report a local problem'),
                  color: Colors.orange.shade800,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.reportAbuse),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              // ✨ MAKE A WISH
              Expanded(
                child: _buildSecondaryActionCard(
                  context,
                  emoji: '✨',
                  title: AppLocalizations.translateWithContext(context, 'dash_action_wish', defaultValue: 'MAKE A WISH'),
                  subtitle: AppLocalizations.translateWithContext(context, 'dash_action_wish_sub', defaultValue: 'Ask community for help'),
                  color: Colors.purple.shade700,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.createWish),
                ),
              ),
              const SizedBox(width: 10),

              // 🤝 HELP A WISH
              Expanded(
                child: _buildSecondaryActionCard(
                  context,
                  emoji: '🤝',
                  title: AppLocalizations.translateWithContext(context, 'dash_action_help_wish', defaultValue: 'HELP A WISH'),
                  subtitle: AppLocalizations.translateWithContext(context, 'dash_action_help_wish_sub', defaultValue: 'Support someone in need'),
                  color: Colors.blue.shade700,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.wishes),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 6. LOCATION-AWARE INDIA-FIRST OPPORTUNITIES
          Row(
            children: [
              Text(
                AppLocalizations.translateWithContext(context, 'dash_today_opps', defaultValue: '🇮🇳 Today\'s Action Opportunities'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
                child: Text(
                  AppLocalizations.translateWithContext(context, 'dash_view_all', defaultValue: 'View All'),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          _buildOpportunityTile(
            context,
            emoji: '🌍',
            title: AppLocalizations.translateWithContext(context, 'opp_plastic_title', defaultValue: 'Plastic Recovery & Segregation'),
            subtitle: AppLocalizations.translateWithContext(context, 'opp_plastic_desc', defaultValue: 'Collect & photograph 5 items of plastic waste. Verified 1.5x Multiplier today!'),
            badge: '+75 ${AppLocalizations.translateWithContext(context, 'dash_karma', defaultValue: 'Karma')}',
            badgeColor: Colors.green,
            isDemo: true,
            onTap: () => Navigator.pushNamed(context, AppRoutes.uploadProof),
          ),
          const SizedBox(height: 8),

          _buildOpportunityTile(
            context,
            emoji: '🌱',
            title: AppLocalizations.translateWithContext(context, 'opp_compost_title', defaultValue: 'Neighborhood Composting Drive'),
            subtitle: AppLocalizations.translateWithContext(context, 'opp_compost_desc', defaultValue: 'Clear organic waste near park and start community pit with before/after photos.'),
            badge: '+50 ${AppLocalizations.translateWithContext(context, 'dash_karma', defaultValue: 'Karma')}',
            badgeColor: Colors.teal,
            isDemo: true,
            onTap: () => Navigator.pushNamed(context, AppRoutes.uploadProof),
          ),
          const SizedBox(height: 14),

          // 7. ECOSYSTEM FLYWHEEL HUB BANNER
          Card(
            color: const Color(0xFF00B074).withOpacity(0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: const Color(0xFF00B074).withOpacity(0.15)),
            ),
            child: ListTile(
              leading: const Text('🌐', style: TextStyle(fontSize: 22)),
              title: Text(
                AppLocalizations.translateWithContext(context, 'dash_flywheel_title', defaultValue: 'Unified Flywheel Hub'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
              ),
              subtitle: Text(
                AppLocalizations.translateWithContext(context, 'dash_flywheel_sub', defaultValue: 'Explore Stories, Karma Graph & Collective Intelligence'),
                style: const TextStyle(fontSize: 10.5, color: Colors.grey),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF00B074)),
              onTap: () => Navigator.pushNamed(context, AppRoutes.ecosystemHub),
            ),
          ),
          const SizedBox(height: 16),

          // 8. TRANSPARENCY & TRUST PROMISE
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.translateWithContext(context, 'safety_title', defaultValue: '🛡️ Trust & Safety Promise'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.translateWithContext(context, 'safety_desc', defaultValue: 'No crypto hype • No arbitrary daily caps • Real evidence verification • Direct-to-vendor wish support'),
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.grey.shade600, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color)),
      ],
    );
  }

  Widget _buildPrimaryActionCard(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(isDark ? 0.22 : 0.1),
                color.withOpacity(isDark ? 0.08 : 0.03),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: color,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryActionCard(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: color),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 9.5, color: isDark ? Colors.white60 : Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpportunityTile(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required VoidCallback onTap,
    bool isDemo = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                          ),
                        ),
                        if (isDemo) const DemoBadge(),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.grey.shade600, height: 1.25),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, color: badgeColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
