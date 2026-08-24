import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/karma_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../models/karma_action.dart';
import '../../models/karma_category.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _getReputationBadge(int rep) {
    if (rep >= 85) return '👑 Gold Validator';
    if (rep >= 70) return '🛡️ Silver Contributor';
    return '🌱 Green Citizen';
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

    final hasCredits = user.categoryCredits.isNotEmpty &&
        user.categoryCredits.values.any((val) => val > 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header / Welcome
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    Text(
                      user.name,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getBadgeColor(user.reputationScore).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getBadgeColor(user.reputationScore).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getReputationBadge(user.reputationScore),
                  style: TextStyle(
                    color: _getBadgeColor(user.reputationScore).withOpacity(0.9),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // INDIA 30 MISSION BANNER
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.indiaMission),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9933), Color(0xFFFFFFFF), Color(0xFF128807)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.05, 0.5, 0.95],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
                border: Border.all(color: const Color(0xFF000080).withOpacity(0.2), width: 1.5),
              ),
              child: Row(
                children: [
                  const Text(
                    '🇮🇳',
                    style: TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'INDIA 30 MISSION HUB',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF000080),
                            fontSize: 14,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Support India\'s priority development goals. Pick a mission & earn multipliers.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[850],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF000080),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.signatureActivities),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text(
                    '🌈',
                    style: TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SIGNATURE QUESTS & FUN HUB',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontSize: 13,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Explore Ripple chains, Olympics leaderboards, and nearby location quests.',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.feed),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.feed_outlined, color: Color(0xFF00B074), size: 18),
                          const SizedBox(width: 8),
                          Text('Community Feed', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.leaderboard),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.leaderboard_outlined, color: Color(0xFF00B074), size: 18),
                          const SizedBox(width: 8),
                          Text('Leaderboard', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.impactExchange),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.swap_horizontal_circle_outlined, color: Colors.green, size: 18),
                          const SizedBox(width: 8),
                          Text('Impact Exchange', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.governance),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.gavel_outlined, color: Colors.purple, size: 18),
                          const SizedBox(width: 8),
                          Text('Governance Node', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.karmaFirewall),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shield_outlined, color: Colors.blueGrey, size: 18),
                          const SizedBox(width: 8),
                          Text('Firewall Ledger', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.settings, color: Colors.grey, size: 18),
                          const SizedBox(width: 8),
                          Text('System Settings', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // WISH COME TRUE HUB BANNER CARD
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.wishes),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB300), Color(0xFFFF6F00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text(
                    '🌟',
                    style: TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'WISH COME TRUE HUB',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontSize: 13,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Submit your wish & let the network fulfill it. Support others through Wish Ripples.',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.95),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Passport Main Card
          Card(
            clipBehavior: Clip.antiAlias,
            elevation: 4,
            shadowColor: Colors.black12,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00B074), Color(0xFF009060)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'POG KARMA PASSPORT',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          fontSize: 12,
                        ),
                      ),
                      Icon(
                        Icons.qr_code_2_rounded,
                        color: Colors.white.withOpacity(0.8),
                        size: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Karma Score',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                          Row(
                            textBaseline: TextBaseline.alphabetic,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            children: [
                              Text(
                                '${user.karmaCredits}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'credits',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Trust Rating',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                          Row(
                            textBaseline: TextBaseline.alphabetic,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            children: [
                              Text(
                                '${(user.trustScore * 100).toInt()}%',
                                style: TextStyle(
                                  color: user.trustScore >= 0.8
                                      ? Colors.white
                                      : user.trustScore >= 0.5
                                          ? Colors.orange[100]
                                          : Colors.red[100],
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.trustScore >= 0.8
                                    ? 'Trusted'
                                    : user.trustScore >= 0.5
                                        ? 'Pending'
                                        : 'Scrutiny',
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPassportStat(
                        'Reputation',
                        '${user.reputationScore}%',
                        Icons.security_rounded,
                      ),
                      _buildPassportStat(
                        'Token Balance',
                        '${user.tokensBalance.toStringAsFixed(2)} PoG',
                        Icons.account_balance_wallet_rounded,
                      ),
                      _buildPassportStat(
                        'Impact Index',
                        '${user.verifiedSubmissions}/${user.totalSubmissions}',
                        Icons.spa_rounded,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Categories Breakdown Chart
          Text(
            'Your Impact Allocation',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: hasCredits
                  ? Column(
                      children: [
                        SizedBox(
                          height: 180,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: _buildPieChartSections(user.categoryCredits),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: _buildChartLegend(user.categoryCredits),
                        ),
                      ],
                    )
                  : SizedBox(
                      height: 120,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pie_chart_outline_rounded,
                              size: 40, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'No verified impact categories yet.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            'Submit and verify good deeds to populate your breakdown!',
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // My Deeds Feed
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Submissions',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (karmaProvider.myActions.isNotEmpty)
                Text(
                  '${karmaProvider.myActions.length} total',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (karmaProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (karmaProvider.myActions.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_rounded, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No submissions yet',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap "Submit Deed" to log your first positive impact.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: karmaProvider.myActions.length,
              itemBuilder: (context, index) {
                final action = karmaProvider.myActions[index];
                return _buildDeedItem(context, action);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPassportStat(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, int> data) {
    final List<PieChartSectionData> sections = [];
    final totalCredits = data.values.fold(0, (sum, value) => sum + value);
    if (totalCredits == 0) return [];

    data.forEach((catKey, value) {
      if (value > 0) {
        final category = KarmaCategory.fromJson(catKey);
        final percentage = (value / totalCredits) * 100;
        sections.add(
          PieChartSectionData(
            color: category.color,
            value: value.toDouble(),
            title: '${percentage.toStringAsFixed(0)}%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
    });

    return sections;
  }

  List<Widget> _buildChartLegend(Map<String, int> data) {
    final List<Widget> legend = [];
    data.forEach((catKey, value) {
      if (value > 0) {
        final category = KarmaCategory.fromJson(catKey);
        legend.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: category.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${category.icon} ${category.label} ($value)',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }
    });
    return legend;
  }

  Widget _buildDeedItem(BuildContext context, KarmaAction action) {
    final theme = Theme.of(context);
    final isVerified = action.status == DeedStatus.verified;
    final isRejected = action.status == DeedStatus.rejected;

    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.pending_actions_rounded;
    if (isVerified) {
      statusColor = const Color(0xFF00B074);
      statusIcon = Icons.check_circle_rounded;
    } else if (isRejected) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel_rounded;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: action.category.color.withOpacity(0.15),
          child: Text(
            action.category.icon,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                action.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isVerified)
              Text(
                '+${action.creditsAwarded} CR',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              action.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      action.status.name.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatDate(action.timestamp),
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
