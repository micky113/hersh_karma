import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/karma_provider.dart';
import '../../models/user_profile.dart';
import '../../models/karma_action.dart';
import '../../core/localization/app_localizations.dart';

class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = Provider.of<AuthProvider>(context).currentUser;
    final karmaProvider = Provider.of<KarmaProvider>(context);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('🪪 Karma Passport')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🪪 ', style: TextStyle(fontSize: 20)),
            Text('Karma Passport', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share Passport',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Karma Passport Link copied to clipboard!'),
                  backgroundColor: Color(0xFF00B074),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. PASSPORT HEADER CARD
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF00B074).withOpacity(isDark ? 0.25 : 0.12),
                      Colors.blue.withOpacity(isDark ? 0.15 : 0.04),
                    ],
                  ),
                  border: Border.all(color: const Color(0xFF00B074).withOpacity(0.3), width: 1.5),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: const Color(0xFF00B074).withOpacity(0.2),
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00B074),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.email,
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00B074).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'ID: ${user.id.substring(0, user.id.length > 8 ? 8 : user.id.length).toUpperCase()}',
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF00B074),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      user.role.name.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Divider(height: 1),
                    const SizedBox(height: 14),

                    // TRI-METRIC PASSPORT OVERVIEW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricBadge('⭐ KARMA', '${user.karmaCredits}', 'Credits', const Color(0xFF00B074)),
                        Container(height: 32, width: 1, color: isDark ? Colors.white12 : Colors.grey.shade300),
                        _buildMetricBadge('🌍 IMPACT', '${user.verifiedSubmissions}', 'Outcomes', Colors.blue),
                        Container(height: 32, width: 1, color: isDark ? Colors.white12 : Colors.grey.shade300),
                        _buildMetricBadge('🛡️ TRUST', '${(user.trustScore * 100).toInt()}%', 'Reliability', Colors.purple),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. VERIFICATION LEVEL PROGRESSION
            const Text(
              'PROOF-OF-GOOD VERIFICATION TIERS',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Colors.grey, letterSpacing: 1.1),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildVerificationRow(1, 'Level 1: Evidence Capture', 'Geotagged before/after photographic proof', true, Colors.green),
                    const Divider(height: 16),
                    _buildVerificationRow(2, 'Level 2: AI Screening', 'Scene match & manipulation detection passed', true, Colors.blue),
                    const Divider(height: 16),
                    _buildVerificationRow(3, 'Level 3: Community Consensus', 'Validated by 3+ trusted network peers', true, Colors.purple),
                    const Divider(height: 16),
                    _buildVerificationRow(4, 'Level 4: Organization Endorsement', 'Confirmed by NGO, School or Civic Authority', false, Colors.orange),
                    const Divider(height: 16),
                    _buildVerificationRow(5, 'Level 5: Independent Ledger Audit', 'Immutable cryptographic blockchain hash anchored', true, Colors.teal),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. LIFETIME PROVEN IMPACT
            const Text(
              'LIFETIME PROVEN IMPACT',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Colors.grey, letterSpacing: 1.1),
            ),
            const SizedBox(height: 10),
            _buildStatCard(Icons.park_rounded, 'Environmental Actions', '5 deeds completed', Colors.green),
            _buildStatCard(Icons.pets_rounded, 'Animal Welfare Support', '2 cases helped', Colors.orange),
            _buildStatCard(Icons.school_rounded, 'Education & Mentorship', '3 students supported', Colors.blue),
            _buildStatCard(Icons.volunteer_activism_rounded, 'Community Care Hours', '14 hours logged', Colors.redAccent),
            const SizedBox(height: 20),

            // 4. RIPPLE MULTIPLIER (Blueprint Section 18)
            const Text(
              'ESTIMATED RIPPLE IMPACT',
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
                    const Row(
                      children: [
                        Text('🌊 ', style: TextStyle(fontSize: 16)),
                        Text('Secondary Ripple Propagation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'When you complete verified deeds, you inspire others in the network to act. Your estimated ripple reach:',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildRippleMetric('🌱 1', 'Direct Action', const Color(0xFF00B074)),
                        const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.grey),
                        _buildRippleMetric('👥 3', 'Inspired', Colors.blue),
                        const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.grey),
                        _buildRippleMetric('🌍 9', 'Reached', Colors.purple),
                        const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.grey),
                        _buildRippleMetric('⚡ 27', 'Total Impact', Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 5. IMMUTABLE PROOF LOG (Ledger Blocks)
            const Text(
              'RECENT VERIFIED PROOF BLOCKS',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Colors.grey, letterSpacing: 1.1),
            ),
            const SizedBox(height: 10),
            ...karmaProvider.myActions.take(3).map((action) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: action.category.color.withOpacity(0.15),
                    child: Text(action.category.icon, style: const TextStyle(fontSize: 12)),
                  ),
                  title: Text(action.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  subtitle: Text(
                    'Hash: ${action.blockchainHash ?? "0x7F9A...B3C1"} • Consensus Verified',
                    style: const TextStyle(fontSize: 9.5, fontFamily: 'monospace', color: Colors.grey),
                  ),
                  trailing: Text(
                    '+${action.creditsAwarded} Karma',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00B074), fontSize: 11),
                  ),
                ),
              );
            }),
            if (karmaProvider.myActions.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No deeds submitted yet. Tap + Create to earn your first Karma Passport block!',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBadge(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: color)),
        Text(unit, style: const TextStyle(fontSize: 8.5, color: Colors.grey)),
      ],
    );
  }

  Widget _buildVerificationRow(int level, String title, String subtitle, bool isCompleted, Color color) {
    return Row(
      children: [
        Icon(
          isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          color: isCompleted ? color : Colors.grey,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11.5,
                  color: isCompleted ? null : Colors.grey,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 9.5, color: isCompleted ? Colors.grey : Colors.grey.shade400),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: color, size: 20),
        title: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        trailing: Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color),
        ),
      ),
    );
  }

  Widget _buildRippleMetric(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
      ],
    );
  }
}
