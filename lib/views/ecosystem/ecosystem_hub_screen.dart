import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/karma_provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/karma_category.dart';
import '../../models/karma_activity.dart';

class EcosystemHubScreen extends StatefulWidget {
  const EcosystemHubScreen({super.key});

  @override
  State<EcosystemHubScreen> createState() => _EcosystemHubScreenState();
}

class _EcosystemHubScreenState extends State<EcosystemHubScreen> {
  int _selectedQueryIndex = 0;

  final List<Map<String, dynamic>> _civilizationQueries = [
    {
      'chip': '🗑️ Open Dumps near Schools',
      'query': 'What is the most effective way to eliminate open garbage dumps near schools?',
      'sampleSize': '8,400 recorded attempts across 14 cities',
      'permanenceRate': '91% permanence over 90 days',
      'whatWorked': 'Covered segregation bins + local merchant stewardship + weekly collection',
      'whatFailed': 'Occasional cleanups without infrastructure (82% recurrence rate in 14 days)',
      'insight': 'Physical infrastructure + daily economic stewards produce long-term permanence.',
      'actionPreset': 'Delhi Cleanup Composting Drive',
      'actionId': 'preset_compost',
      'actionCategory': KarmaCategory.environment,
    },
    {
      'chip': '💧 Village Water Table',
      'query': 'How can communities replenish local groundwater in semi-arid zones?',
      'sampleSize': '3,120 rainwater harvesting structures monitored',
      'permanenceRate': '88% water retention through dry season',
      'whatWorked': 'Decentralized check-dams + native vetiver grass soil binding',
      'whatFailed': 'Concrete-only canals without soil permeability maintenance',
      'insight': 'Biological retention barriers retain 3.4x more moisture than unlined concrete trenches.',
      'actionPreset': 'Community Water Channel Cleaning',
      'actionId': 'preset_water_channel',
      'actionCategory': KarmaCategory.environment,
    },
    {
      'chip': '🐕 Stray Animal Care',
      'query': 'How do neighborhoods eliminate stray rabies risks humanely?',
      'sampleSize': '12,600 verified community vaccination & feeder logs',
      'permanenceRate': '96% rabies-free rate over 12 months',
      'whatWorked': 'Designated feeding zones + cooperative volunteer vet sterilization',
      'whatFailed': 'Random relocation without neighborhood territory mapping',
      'insight': 'Territorial stabilization through sterilization prevents incoming unvaccinated packs.',
      'actionPreset': 'Street Animal Vet Aid & Feeding',
      'actionId': 'preset_animal_care',
      'actionCategory': KarmaCategory.animalWelfare,
    },
    {
      'chip': '📚 Peer Tutoring Hubs',
      'query': 'How do high school students achieve high reading fluency gains in primary schools?',
      'sampleSize': '5,400 student-tutor sessions recorded with before/after reading assessments',
      'permanenceRate': '78% literacy improvement in 60 days',
      'whatWorked': '15-minute daily phonics paired reading with elder/student badges',
      'whatFailed': 'Weekend-only lecture sessions without interactive phonics cards',
      'insight': 'High frequency (daily 15m) micro-sessions outperform weekly 2-hour cramming.',
      'actionPreset': 'Teach a Child / Student Mentorship',
      'actionId': 'preset_teaching',
      'actionCategory': KarmaCategory.education,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeQuery = _civilizationQueries[_selectedQueryIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.translateWithContext(context, 'eco_hub_title', defaultValue: 'Ecosystem Flywheel Hub'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. THE 4-FUNCTION MVP DIRECT ACTION BAR
            _buildMVPActionLoopBar(context, theme),
            const SizedBox(height: 24),

            // 2. THE FLYWHEEL SYSTEM
            _buildFlywheelSection(context, theme),
            const SizedBox(height: 24),

            // 3. THE KARMA GRAPH (Relational Problem-Solving Map)
            _buildKarmaGraphSection(context, theme),
            const SizedBox(height: 24),

            // 4. CIVILIZATION'S LEARNING ENGINE ("Ask Collective Intelligence")
            _buildCivilizationQueryEngine(context, theme, activeQuery),
            const SizedBox(height: 24),

            // 5. YOUTUBE STORIES FEED (Content becomes Action)
            _buildYouTubeStoryFeed(context, theme),
            const SizedBox(height: 24),

            // 6. AI SENSOR CORRELATION NETWORK
            _buildAISensorNetwork(context, theme),
            const SizedBox(height: 24),

            // 7. ANTI-POPULARITY KARMA INDEX EXPLAINER (6 Components)
            _buildKarmaIndexExplainer(context, theme),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 4-Function MVP Loop Bar: DO GOOD ➔ REPORT ➔ SOLVE ➔ PROVE/UPDATE
  Widget _buildMVPActionLoopBar(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B074).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('THE 4-STEP ACTION LOOP', style: TextStyle(color: Color(0xFF00B074), fontWeight: FontWeight.bold, fontSize: 10)),
                ),
                const Spacer(),
                const Text('Civilization MVP 1', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Every real-world improvement follows this 4-step lifecycle:',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildActionStepTile(
                  context,
                  emoji: '🌱',
                  title: '1. DO GOOD',
                  subtitle: 'Take action',
                  color: Colors.green,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.uploadProof),
                ),
                const SizedBox(width: 8),
                _buildActionStepTile(
                  context,
                  emoji: '🔎',
                  title: '2. REPORT',
                  subtitle: 'Flag problem',
                  color: Colors.orange,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.reportAbuse),
                ),
                const SizedBox(width: 8),
                _buildActionStepTile(
                  context,
                  emoji: '🛠️',
                  title: '3. SOLVE',
                  subtitle: 'Fix & claim',
                  color: Colors.blue,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.search),
                ),
                const SizedBox(width: 8),
                _buildActionStepTile(
                  context,
                  emoji: '📸',
                  title: '4. PROVE',
                  subtitle: '30-day update',
                  color: Colors.purple,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.karmaFirewall),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionStepTile(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: color),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 8, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Visual Flow Diagram
  Widget _buildFlywheelSection(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.translateWithContext(context, 'eco_flywheel_title', defaultValue: 'THE FLYWHEEL SYSTEM'),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF00B074)),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.translateWithContext(
                context,
                'eco_flywheel_desc',
                defaultValue: 'YouTube gives the system a voice. Karma gives it hands. AI gives it memory & intelligence. People give it purpose.',
              ),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  _FlywheelNode(
                    title: '📺 YouTube Stories',
                    subtitle: 'Change what people think about (Education/Awareness)',
                    color: Colors.red,
                  ),
                  _FlywheelArrowDown(),
                  _FlywheelNode(
                    title: '🌱 Karma Actions',
                    subtitle: 'Change what people do (Real-world Deeds/Fixes)',
                    color: Color(0xFF00B074),
                  ),
                  _FlywheelArrowDown(),
                  _FlywheelNode(
                    title: '🤖 AI Core Learning',
                    subtitle: 'Measures impact & coordinates successful solutions',
                    color: Colors.blue,
                  ),
                  _FlywheelArrowDown(),
                  _FlywheelNode(
                    title: '🔄 Collective Intelligence',
                    subtitle: 'Identifies success pattern ➔ Feeds back into YouTube stories',
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The Karma Graph Component
  Widget _buildKarmaGraphSection(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text('🕸️ THE KARMA GRAPH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF00B074))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Relational Problem-Solving', style: TextStyle(color: Colors.purple, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Instead of isolated posts, Karma maps multi-actor relationships from Problem to Durability.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Graph visualization container
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  // 1. PROBLEM ROOT
                  _buildGraphNode(
                    icon: '🚨',
                    badge: 'COMMUNITY PROBLEM',
                    badgeColor: Colors.orange,
                    title: 'Open Garbage Dump near Sector 4 School',
                    subtitle: 'Reported by local parent with GPS & Before Photo',
                  ),
                  const _GraphConnectorLine(),

                  // 2. SPLIT TO CONTRIBUTORS (Person A & Person B)
                  Row(
                    children: [
                      Expanded(
                        child: _buildGraphNode(
                          icon: '🧤',
                          badge: 'PERSON A (Volunteer)',
                          badgeColor: Colors.teal,
                          title: 'John Doe',
                          subtitle: 'Organized neighborhood cleanup drive',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildGraphNode(
                          icon: '🛠️',
                          badge: 'PERSON B (Creator)',
                          badgeColor: Colors.indigo,
                          title: 'Anita Sharma',
                          subtitle: 'Fabricated 2 covered metal segregation bins',
                        ),
                      ),
                    ],
                  ),
                  const _GraphConnectorLine(),

                  // 3. CONVERGED SOLUTION
                  _buildGraphNode(
                    icon: '📦',
                    badge: 'EMERGENT SOLUTION',
                    badgeColor: Colors.blue,
                    title: 'Permanent Community Waste Station',
                    subtitle: 'Covered bins + local tea shopkeeper stewardship',
                  ),
                  const _GraphConnectorLine(),

                  // 4. VERIFIED OUTCOME
                  _buildGraphNode(
                    icon: '🏆',
                    badge: '90-DAY VERIFIED OUTCOME',
                    badgeColor: Colors.green,
                    title: 'Area 100% Waste-Free for 90 Days',
                    subtitle: 'Verified via community audit photos & municipal logs',
                  ),
                  const _GraphConnectorLine(),

                  // 5. CIVILIZATIONAL LEARNING
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.purple.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            Text('💡 CIVILIZATIONAL LEARNING', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 10)),
                            Spacer(),
                            Text('Pattern Stored in AI Core', style: TextStyle(color: Colors.purple, fontSize: 9)),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          '“Covered segregation bins combined with local merchant stewardship produce a 91% permanence rate over 90 days vs 18% for one-off cleanups.”',
                          style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black87),
                        ),
                      ],
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

  Widget _buildGraphNode({
    required String icon,
    required String badge,
    required Color badgeColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(badge, style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 8)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        ],
      ),
    );
  }

  /// Civilization's Learning Engine ("Ask Humanity's Collective Intelligence")
  Widget _buildCivilizationQueryEngine(BuildContext context, ThemeData theme, Map<String, dynamic> activeQuery) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text('🧠 ASK THE COLLECTIVE INTELLIGENCE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Real-World Karma Data', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 9)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Instead of generic internet summaries, the AI answers using empirical data from thousands of verified Karma actions.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // Chips selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_civilizationQueries.length, (index) {
                  final isSelected = index == _selectedQueryIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(_civilizationQueries[index]['chip'] as String),
                      selected: isSelected,
                      selectedColor: Colors.blue.shade100,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.blue.shade900 : Colors.black87,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedQueryIndex = index;
                          });
                        }
                      },
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Empirical Output Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Q: "${activeQuery['query']}"',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
                  ),
                  const Divider(height: 16),

                  Row(
                    children: [
                      const Icon(Icons.analytics_outlined, size: 14, color: Colors.blue),
                      const SizedBox(width: 6),
                      Text('Dataset Sample: ${activeQuery['sampleSize']}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.verified_outlined, size: 14, color: Colors.green),
                      const SizedBox(width: 6),
                      Text('Permanence: ${activeQuery['permanenceRate']}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // What worked vs what failed
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('✅ WHAT WORKED: ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10)),
                        Expanded(child: Text(activeQuery['whatWorked'] as String, style: const TextStyle(fontSize: 10))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('❌ WHAT FAILED: ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10)),
                        Expanded(child: Text(activeQuery['whatFailed'] as String, style: const TextStyle(fontSize: 10))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Core insight
                  Text(
                    'Key Empirical Rule: ${activeQuery['insight']}',
                    style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),

                  // Action Button prefill
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B074),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 16),
                      label: const Text('Execute Verified Playbook', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        final karmaProvider = Provider.of<KarmaProvider>(context, listen: false);
                        karmaProvider.prefilledPreset = KarmaActivity(
                          id: activeQuery['actionId'] as String,
                          title: activeQuery['actionPreset'] as String,
                          tier: 2,
                          category: activeQuery['actionCategory'] as KarmaCategory,
                          baseImpact: 60,
                          effortRating: 'Medium',
                          verificationMethod: VerificationMethod.gpsAndImage,
                          frequencyLimit: FrequencyLimit.unlimited,
                        );
                        Navigator.pushNamed(context, AppRoutes.uploadProof);
                      },
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

  /// YouTube Feed
  Widget _buildYouTubeStoryFeed(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            AppLocalizations.translateWithContext(context, 'eco_youtube_title', defaultValue: '📺 YouTube Stories (Content ➔ Action)'),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),

        // Video Card 1
        _buildYouTubeVideoCard(
          context,
          theme,
          thumbnailEmoji: '🧹',
          title: 'This community solved its waste problem in 30 days. Here\'s how.',
          duration: '12:45',
          views: '14K views',
          actionLabel: '🌱 View Composting Presets',
          onActionTap: () {
            final karmaProvider = Provider.of<KarmaProvider>(context, listen: false);
            karmaProvider.prefilledPreset = const KarmaActivity(
              id: 'preset_compost',
              title: 'Delhi Cleanup Composting Drive',
              tier: 2,
              category: KarmaCategory.environment,
              baseImpact: 50,
              effortRating: 'Medium',
              verificationMethod: VerificationMethod.gpsAndImage,
              frequencyLimit: FrequencyLimit.unlimited,
            );
            Navigator.pushNamed(context, AppRoutes.uploadProof);
          },
        ),
        const SizedBox(height: 12),

        // Video Card 2
        _buildYouTubeVideoCard(
          context,
          theme,
          thumbnailEmoji: '🤖',
          title: 'AI found 10 recurring problems across India. Here\'s what we can actually fix.',
          duration: '18:20',
          views: '32K views',
          actionLabel: '🇮🇳 Open India 30 Hub',
          onActionTap: () {
            Navigator.pushNamed(context, AppRoutes.indiaMission);
          },
        ),
        const SizedBox(height: 12),

        // Video Card 3
        _buildYouTubeVideoCard(
          context,
          theme,
          thumbnailEmoji: '🌍',
          title: 'What happens when 100,000 people coordinate small acts of good?',
          duration: '15:10',
          views: '58K views',
          actionLabel: '🏆 Join Active Challenges',
          onActionTap: () {
            Navigator.pushNamed(context, AppRoutes.signatureActivities);
          },
        ),
      ],
    );
  }

  Widget _buildYouTubeVideoCard(
    BuildContext context,
    ThemeData theme, {
    required String thumbnailEmoji,
    required String title,
    required String duration,
    required String views,
    required String actionLabel,
    required VoidCallback onActionTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black87, Colors.grey.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    thumbnailEmoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'YOUTUBE STORY',
                      style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      duration,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  views,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
                const Divider(height: 16),
                
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B074),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: onActionTap,
                    child: Text(actionLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// AI Sensor Network
  Widget _buildAISensorNetwork(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            AppLocalizations.translateWithContext(context, 'eco_ai_title', defaultValue: '🤖 AI Core Wellbeing Sensor Network'),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Correlation Chains',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 12),
                
                _buildSensorCorrelationItem(
                  context,
                  problem: 'Accumulating Garbage near Central School Delhi',
                  action: 'Delhi Cleanup Composting Drive completed',
                  solution: 'Waste collection bins installed by Municipal Partner',
                  status: 'Success: Area 100% waste-free for 90 days',
                  isActive: true,
                ),
                const Divider(height: 24),
                
                _buildSensorCorrelationItem(
                  context,
                  problem: 'Stray Puppies hungry & sick in Tel Aviv Sector B',
                  action: 'Street Animal Vet Aid initiated by Jane',
                  solution: 'Local shelter adopted puppies & provided feed',
                  status: 'Success: Rehomed & healthy',
                  isActive: false,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSensorCorrelationItem(
    BuildContext context, {
    required String problem,
    required String action,
    required String solution,
    required String status,
    required bool isActive,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('AI CORRELATION', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 8)),
            ),
            const Spacer(),
            if (isActive)
              const Row(
                children: [
                  CircleAvatar(radius: 4, backgroundColor: Colors.green),
                  SizedBox(width: 4),
                  Text('Sensor Monitoring Active', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
          ],
        ),
        const SizedBox(height: 10),
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🔎 Problem: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.amber)),
            Expanded(child: Text(problem, style: const TextStyle(fontSize: 11))),
          ],
        ),
        const SizedBox(height: 4),
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🌱 Action:    ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF00B074))),
            Expanded(child: Text(action, style: const TextStyle(fontSize: 11))),
          ],
        ),
        const SizedBox(height: 4),
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🛠️ Solution:  ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blue)),
            Expanded(child: Text(solution, style: const TextStyle(fontSize: 11))),
          ],
        ),
        const SizedBox(height: 8),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.06),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.green.withOpacity(0.12)),
          ),
          child: Text(
            '✓ Outcome Status: $status',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ),
      ],
    );
  }

  /// 6-Component Anti-Popularity Explainer
  Widget _buildKarmaIndexExplainer(BuildContext context, ThemeData theme) {
    return Card(
      color: theme.colorScheme.secondary.withOpacity(0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.secondary.withOpacity(0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.translateWithContext(context, 'eco_karma_index', defaultValue: '🧬 KARMA INDEX ≠ POPULARITY'),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.secondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Conventional social media rewards ATTENTION (followers, virality). Karma Grid rewards MEANINGFUL CONTRIBUTION. A person quietly solving local problems accumulates higher trust and rank than accounts with millions of vanity views.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, height: 1.4),
            ),
            const SizedBox(height: 16),
            
            // 6-Component Grid Formula
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildFormulaItem('Contribution', '30%', Colors.green, 'Did you act?'),
                _buildFormulaItem('Reliability', '25%', Colors.blue, 'Consistent accuracy'),
                _buildFormulaItem('Impact', '20%', Colors.orange, 'Measurable delta'),
                _buildFormulaItem('Cooperation', '10%', Colors.purple, 'Helped others succeed'),
                _buildFormulaItem('Knowledge', '10%', Colors.teal, 'Shared learnings'),
                _buildFormulaItem('Regeneration', '5%', Colors.indigo, 'Persisted 90 days'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulaItem(String label, String weight, Color color, String subtitle) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(weight, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 8, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _FlywheelNode extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const _FlywheelNode({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _FlywheelArrowDown extends StatelessWidget {
  const _FlywheelArrowDown();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Icon(Icons.arrow_downward_rounded, size: 14, color: Colors.grey),
    );
  }
}

class _GraphConnectorLine extends StatelessWidget {
  const _GraphConnectorLine();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Icon(Icons.arrow_downward_rounded, size: 16, color: Colors.grey),
    );
  }
}
