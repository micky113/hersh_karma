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
import '../map/impact_map_screen.dart';

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
          // 1. WELCOME HEADER + USER TRUST BADGE
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
                      AppLocalizations.translateWithContext(context, 'dash_welcome', defaultValue: 'Good morning') + ',',
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
          const SizedBox(height: 14),

          // 2. HERO STATS: DISTINCT KARMA vs IMPACT vs TRUST
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricColumn(
                    '⭐ KARMA',
                    '${user.karmaCredits}',
                    'Credits Earned',
                    const Color(0xFF00B074),
                  ),
                  Container(height: 36, width: 1, color: isDark ? Colors.white12 : Colors.grey.shade300),
                  _buildMetricColumn(
                    '🌍 IMPACT',
                    '${user.verifiedSubmissions}',
                    'Verified Outcomes',
                    Colors.blueAccent,
                  ),
                  Container(height: 36, width: 1, color: isDark ? Colors.white12 : Colors.grey.shade300),
                  _buildMetricColumn(
                    '🛡️ TRUST',
                    '${(user.trustScore * 100).toInt()}%',
                    'Proof Rating',
                    Colors.purpleAccent,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 3. THE 2 PRIMARY DECISION CARDS ("What can I do now?")
          Row(
            children: [
              // 🌱 DO GOOD
              Expanded(
                child: _buildHeroActionCard(
                  context,
                  emoji: '🌱',
                  title: 'DO GOOD',
                  subtitle: 'Find something meaningful & prove impact',
                  color: const Color(0xFF00B074),
                  badge: 'BEFORE → ACTION → AFTER',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.submitDeed),
                ),
              ),
              const SizedBox(width: 12),

              // 🔎 REPORT A PROBLEM
              Expanded(
                child: _buildHeroActionCard(
                  context,
                  emoji: '🔎',
                  title: 'REPORT',
                  subtitle: 'See something to fix? Report & solve it',
                  color: Colors.orange.shade800,
                  badge: 'LOCATE → RESOLVE → VERIFY',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.reportAbuse),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4. WISHES FAST ROW (✨ MAKE A WISH | 🤝 HELP ONE)
          Row(
            children: [
              Expanded(
                child: _buildSecondaryActionCard(
                  context,
                  emoji: '✨',
                  title: 'MAKE A WISH',
                  subtitle: 'Get AI Plan & community help',
                  color: Colors.purple.shade700,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.createWish),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSecondaryActionCard(
                  context,
                  emoji: '🤝',
                  title: 'HELP A WISH',
                  subtitle: 'Sponsor, mentor, or share goods',
                  color: Colors.blue.shade700,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.wishes),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 5. 🌊 YOUR RIPPLE EFFECT (Estimated Secondary Impact)
          Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🌊 ', style: TextStyle(fontSize: 16)),
                      const Text(
                        'Your Karma Ripple',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: const Text(
                          'Estimated Ripple',
                          style: TextStyle(fontSize: 9.5, color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '1 deed inspires 3 helpers, reaching 9 people and 27 community impacts.',
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.grey.shade700),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildRippleNode('🌱 You', '1 Deed', const Color(0xFF00B074)),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.grey),
                      _buildRippleNode('👥 1st Wave', '3 Inspired', Colors.blue),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.grey),
                      _buildRippleNode('🌍 2nd Wave', '9 Reached', Colors.purple),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.grey),
                      _buildRippleNode('⚡ Community', '27 Impact', Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 6. UNIVERSAL SEARCH BAR + "TALK TO KARMA" VOICE AGENT
          const UniversalSearchBar(),
          const SizedBox(height: 16),

          // 7. VISUAL JOURNEY BANNER (Proof-of-Good progression)
          const VisualJourneyBanner(compact: true),
          const SizedBox(height: 16),

          // 8. LIVE GOOGLE MAPS IMPACT RADAR
          Row(
            children: [
              const Text('🌍 ', style: TextStyle(fontSize: 15)),
              const Text(
                'Live Google Maps Impact Radar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.fullscreen_rounded, size: 14, color: Color(0xFF00B074)),
                label: const Text(
                  'Full Map',
                  style: TextStyle(fontSize: 11, color: Color(0xFF00B074), fontWeight: FontWeight.bold),
                ),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.impactMap),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const ImpactMapWidget(height: 240),
          const SizedBox(height: 18),

          // 9. LOCATION-AWARE INDIA-FIRST OPPORTUNITIES
          Row(
            children: [
              const Text(
                '🇮🇳 Today\'s Action Opportunities',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
                child: const Text(
                  'View All',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          _buildOpportunityTile(
            context,
            emoji: '🌍',
            title: 'Plastic Recovery & Segregation',
            subtitle: 'Collect & photograph 5 items of plastic waste. Verified 1.5x Multiplier today!',
            badge: '+75 Karma',
            badgeColor: Colors.green,
            isDemo: true,
            onTap: () => Navigator.pushNamed(context, AppRoutes.uploadProof),
          ),
          const SizedBox(height: 8),

          _buildOpportunityTile(
            context,
            emoji: '🌱',
            title: 'Neighborhood Composting Drive',
            subtitle: 'Clear organic waste near park and start community pit with before/after photos.',
            badge: '+50 Karma',
            badgeColor: Colors.teal,
            isDemo: true,
            onTap: () => Navigator.pushNamed(context, AppRoutes.uploadProof),
          ),
          // 10. ECOSYSTEM FLYWHEEL HUB BANNER
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

          // 11. TRANSPARENCY & TRUST PROMISE
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
                const Text(
                  '🛡️ Trust & Proof-of-Good Architecture',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'No crypto hype • No arbitrary daily caps • Multi-layer verification • Real outcomes',
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

  Widget _buildMetricColumn(String label, String value, String subtitle, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19, color: color)),
        const SizedBox(height: 1),
        Text(subtitle, style: const TextStyle(fontSize: 9, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRippleNode(String title, String subtitle, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.4), width: 1),
          ),
          child: Text(
            title,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        const SizedBox(height: 3),
        Text(subtitle, style: const TextStyle(fontSize: 8.5, color: Colors.grey)),
      ],
    );
  }

  Widget _buildHeroActionCard(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required String badge,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2.5,
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
                color.withOpacity(isDark ? 0.25 : 0.12),
                color.withOpacity(isDark ? 0.08 : 0.04),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 28)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold, color: color),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10.5,
                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                  height: 1.25,
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
        side: BorderSide(color: color.withOpacity(0.25), width: 1),
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
      child: ListTile(
        onTap: onTap,
        dense: true,
        leading: Text(emoji, style: const TextStyle(fontSize: 22)),
        title: Row(
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
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 10.5, color: isDark ? Colors.white60 : Colors.grey[600]),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: badgeColor.withOpacity(0.4), width: 0.8),
          ),
          child: Text(
            badge,
            style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ),
      ),
    );
  }
}
