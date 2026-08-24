import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/karma_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../models/karma_action.dart';
import '../../models/karma_category.dart';
import '../../models/user_profile.dart';
import '../../services/voice_service.dart';

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

    if (user.interfaceMode == AppInterfaceMode.simple) {
      return _buildSimpleDashboard(context, user, karmaProvider, theme);
    }

    switch (user.role) {
      case UserRole.institution:
        return _buildSchoolDashboard(context, user, karmaProvider, theme);
      case UserRole.ngo:
        return _buildNgoDashboard(context, user, karmaProvider, theme);
      case UserRole.corporate:
        return _buildCorporateDashboard(context, user, karmaProvider, theme);
      case UserRole.communityGroup:
        return _buildCommunityGroupDashboard(context, user, karmaProvider, theme);
      default:
        return _buildIndividualDashboard(context, user, karmaProvider, theme);
    }
  }

  Widget _buildIndividualDashboard(BuildContext context, UserProfile user, KarmaProvider karmaProvider, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          const SizedBox(height: 24),

          // 1. TOP METRICS PANEL (Your Karma & Your Impact)
          Row(
            children: [
              Expanded(
                child: Card(
                  color: const Color(0xFF00B074).withOpacity(0.06),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('YOUR KARMA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 6),
                        Text('${user.karmaCredits} Credits', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00B074))),
                        Text('Trust score: ${(user.trustScore * 100).toInt()}%', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  color: Colors.blue.withOpacity(0.06),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('YOUR IMPACT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 6),
                        Text('${user.verifiedSubmissions} Deeds', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                        Text('${user.wasteRecoveredKg.toInt()} kg recovered', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. THREE PRIMARY ACTIONS
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.uploadProof),
                  child: Card(
                    color: Colors.green[50],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.green.withOpacity(0.2))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          const Text('🌱', style: TextStyle(fontSize: 24)),
                          const SizedBox(height: 4),
                          Text(KarmaVoice.getTranslation('do_good', defaultValue: 'DO GOOD'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.reportAbuse),
                  child: Card(
                    color: Colors.amber[50],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.amber.withOpacity(0.2))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          const Text('🔎', style: TextStyle(fontSize: 24)),
                          const SizedBox(height: 4),
                          Text(KarmaVoice.getTranslation('report', defaultValue: 'REPORT'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.createWish),
                  child: Card(
                    color: Colors.purple[50],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.purple.withOpacity(0.2))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          const Text('✨', style: TextStyle(fontSize: 24)),
                          const SizedBox(height: 4),
                          Text(KarmaVoice.getTranslation('make_wish', defaultValue: 'MAKE WISH'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 🎙️ TALK TO KARMA MICROPHONE TILE
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.mic, color: Colors.red),
              title: const Text('Talk to Karma Grid', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Speak naturally to ask for deeds or report garbage'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () => _showSpeechAgentModal(context),
            ),
          ),
          const SizedBox(height: 20),

          // 3. TODAY'S OPPORTUNITIES
          _buildSectionTitle(theme, '🔥 Today\'s Opportunities'),
          const SizedBox(height: 8),
          _buildChallengeCard(
            title: 'Global Plastic Recovery Drive',
            desc: 'Collect & photograph 5 items of plastic waste. 1.5x Multiplier today!',
            volunteers: '1,420 people participating',
            deadline: 'Active now',
          ),
          const SizedBox(height: 24),

          // 4. YOUR RIPPLE
          _buildSectionTitle(theme, '🌊 Your Ripple'),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.tealAccent,
                child: Text('🌊', style: TextStyle(fontSize: 16)),
              ),
              title: Text('${user.karmaRipplesCount} Active Ripple Chains', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Matching donations & continuous downstream impact generated'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(8)),
                child: const Text('+20% Multiplier', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSimpleDashboard(BuildContext context, UserProfile user, KarmaProvider karmaProvider, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Namaste, ${user.name}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up, size: 32, color: Color(0xFF00B074)),
                onPressed: () {
                  KarmaVoice.speak('do_good', directText: 'Welcome back ${user.name}. Pick an action below.', context: context);
                },
              ),
            ],
          ),
          const SizedBox(height: 30),

          // TALK TO KARMA MICROPHONE TARGET (VERY LARGE)
          InkWell(
            onTap: () => _showSpeechAgentModal(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
              ),
              child: Column(
                children: const [
                  Icon(Icons.mic, size: 64, color: Colors.red),
                  SizedBox(height: 12),
                  Text(
                    '🎙️ TALK TO KARMA',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tap and speak to ask what to do, or report garbage',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 🌱 DO GOOD
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.uploadProof);
            },
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
              ),
              child: Row(
                children: [
                  const Text('🌱', style: TextStyle(fontSize: 48)),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(KarmaVoice.getTranslation('do_good', defaultValue: 'DO GOOD'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                        const Text('Start a verified positive activity', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 28, color: Colors.green),
                    onPressed: () {
                      KarmaVoice.speak('before_proof', context: context);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 🔎 REPORT A PROBLEM
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.reportAbuse);
            },
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.amber.withOpacity(0.3), width: 2),
              ),
              child: Row(
                children: [
                  const Text('🔎', style: TextStyle(fontSize: 48)),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(KarmaVoice.getTranslation('report', defaultValue: 'REPORT'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber)),
                        const Text('Flag garbage, water or animal issues', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 28, color: Colors.amber),
                    onPressed: () {
                      KarmaVoice.speak('report', context: context);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ✨ MAKE A WISH
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.createWish);
            },
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.purple.withOpacity(0.3), width: 2),
              ),
              child: Row(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 48)),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(KarmaVoice.getTranslation('make_wish', defaultValue: 'MAKE WISH'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple)),
                        const Text('Submit your wish to the community', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 28, color: Colors.purple),
                    onPressed: () {
                      KarmaVoice.speak('make_wish', context: context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSpeechAgentModal(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            String status = '🎙️ Listening... Speak naturally';
            String response = '';
            
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Talk to Karma Grid'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    status,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      labelText: 'Type or simulate speech command',
                      hintText: 'e.g. "What can I do today?" or "yahan bahut kachra hai"',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (response.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        '🤖 Karma: $response',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ]
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final query = textController.text.trim().toLowerCase();
                    String reply = '';
                    if (query.contains('what can i do') || query.contains('kya karu') || query.contains('today')) {
                      reply = 'Here are three things you can do nearby. You can help clean a public space, help an animal, or teach someone a skill.';
                    } else if (query.contains('garbage') || query.contains('kachra') || query.contains('report')) {
                      reply = 'I understand you want to report a garbage problem. Opening the problem reporter now. Please take a photo of the area.';
                      Future.delayed(const Duration(seconds: 2), () {
                        if (context.mounted) {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.reportAbuse);
                        }
                      });
                    } else {
                      reply = 'Understood! I will guide you to complete a verified proof of good deed.';
                    }
                    setState(() {
                      status = 'Heard command';
                      response = reply;
                    });
                    KarmaVoice.speak('', directText: reply, context: context);
                  },
                  child: const Text('Send Speech 🎙️'),
                )
              ],
            );
          }
        );
      }
    );
  }

  Widget _buildSchoolDashboard(BuildContext context, UserProfile user, KarmaProvider karmaProvider, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOrgHeader(user, theme),
          const SizedBox(height: 20),
          _buildOrgPassportCard(
            title: 'INSTITUTION PASSPORT',
            orgName: user.name,
            roleName: 'EDUCATIONAL INSTITUTION',
            karmaCredits: 82400,
            primaryMetric: '${user.studentsCount} Students Participating',
            secondaryMetric: '3,820 Actions Completed',
            bgColor: Colors.indigo,
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(theme, '🌱 Community Impact'),
          _buildStatGrid([
            _buildMiniStatCard('Trees Planted', '1,200', Icons.park_outlined, Colors.green),
            _buildMiniStatCard('Litter Cleanups', '150', Icons.cleaning_services_outlined, Colors.amber),
            _buildMiniStatCard('Tutoring Hours', '820 hrs', Icons.menu_book_outlined, Colors.blue),
            _buildMiniStatCard('Food Donated', '450 meals', Icons.volunteer_activism_outlined, Colors.red),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle(theme, '🏫 Classes Leaderboard'),
          const SizedBox(height: 8),
          _buildLeaderboardItem(1, 'Class 10-A', '24,100 Karma'),
          _buildLeaderboardItem(2, 'Class 12-B', '18,200 Karma'),
          _buildLeaderboardItem(3, 'Class 9-C', '15,500 Karma'),
          const SizedBox(height: 24),
          _buildSectionTitle(theme, '🏆 Active School Challenges'),
          _buildChallengeCard(
            title: 'Clean Our Neighborhood Challenge',
            desc: 'Collaborative cleanup around the neighborhood park. NGO Verified.',
            volunteers: '240 students active',
            deadline: 'Ends in 4 days',
          ),
        ],
      ),
    );
  }

  Widget _buildNgoDashboard(BuildContext context, UserProfile user, KarmaProvider karmaProvider, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOrgHeader(user, theme),
          const SizedBox(height: 20),
          _buildOrgPassportCard(
            title: 'IMPACT ORGANIZATION PASSPORT',
            orgName: user.name,
            roleName: 'VERIFIED NGO / TRUSTEE',
            karmaCredits: user.karmaCredits,
            primaryMetric: '1.2M Project Impact (PoG)',
            secondaryMetric: '${user.projectsCount} Active Projects  •  ${user.peopleReached} Reached',
            bgColor: Colors.teal,
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(theme, '🔐 Pending Verifications Queue'),
          const SizedBox(height: 8),
          _buildVerificationQueueCard(
            actionTitle: 'Neighborhood Waste Collection & Segregation',
            submitter: 'Apex Academy Class 10-A',
            timeAgo: 'Submitted 2 hours ago',
            evidenceScore: '92/100 (Scene Match: 95%)',
          ),
          _buildVerificationQueueCard(
            actionTitle: 'Wetland Restoration & Clean Plant Seedlings',
            submitter: 'Rajesh Kumar (Individual)',
            timeAgo: 'Submitted 4 hours ago',
            evidenceScore: '87/100 (Scene Match: 91%)',
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(theme, '🌊 Active Volunteers Feed'),
          _buildVolunteerCard('John Doe completed tree planting', '+35 Karma provisional'),
          _buildVolunteerCard('Apex Academy Class 12-B started neighborhood quest', 'Quorum pending'),
        ],
      ),
    );
  }

  Widget _buildCorporateDashboard(BuildContext context, UserProfile user, KarmaProvider karmaProvider, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOrgHeader(user, theme),
          const SizedBox(height: 20),
          _buildOrgPassportCard(
            title: 'CSR CORPORATE PASSPORT',
            orgName: user.name,
            roleName: 'BUSINESS / SPONSOR',
            karmaCredits: user.karmaCredits,
            primaryMetric: '4.8M CSR Impact Created',
            secondaryMetric: '${user.employeesCount} Participating  •  ${user.projectsCount} Sponsored',
            bgColor: Colors.purple,
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(theme, '🏢 CSR Initiative Funding allocations'),
          const SizedBox(height: 8),
          _buildCSRFundCard('Environmental Restoration Restoration', '1,200,000 Karma Funded', 'Active (NGO Verified)', 0.8),
          _buildCSRFundCard('Education & Mentorship Course Scholarships', '800,000 Karma Funded', 'Active (Institution Verified)', 0.5),
          const SizedBox(height: 24),
          _buildSectionTitle(theme, '🎯 Active Corporate Challenges'),
          _buildChallengeCard(
            title: 'Ride to Work Green Challenge',
            desc: 'Cycle or walk to work. Earn reputation and company matching carbon points.',
            volunteers: '480 employees active',
            deadline: 'Ends in 2 weeks',
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityGroupDashboard(BuildContext context, UserProfile user, KarmaProvider karmaProvider, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOrgHeader(user, theme),
          const SizedBox(height: 20),
          _buildOrgPassportCard(
            title: 'GROUP COLLABORATION PASSPORT',
            orgName: user.name,
            roleName: 'COMMUNITY GROUP',
            karmaCredits: user.karmaCredits,
            primaryMetric: '${user.totalVolunteers} Volunteers/Members',
            secondaryMetric: '${user.verifiedSubmissions} Group Actions completed',
            bgColor: Colors.deepOrange,
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(theme, '👥 Nearby Collaborative Opportunities'),
          _buildChallengeCard(
            title: 'Public Park Tree Care',
            desc: 'Group weeding and sapling watering at Central Gardens.',
            volunteers: '18 active groups participating',
            deadline: 'Every Saturday morning',
          ),
        ],
      ),
    );
  }

  Widget _buildOrgHeader(UserProfile user, ThemeData theme) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'O',
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
              Row(
                children: [
                  Text(
                    user.name,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (user.isOrgVerified) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.verified_rounded, color: Colors.blue, size: 18),
                  ],
                ],
              ),
              Text(
                user.role.label,
                style: TextStyle(fontSize: 12, color: Colors.grey[650], fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrgPassportCard({
    required String title,
    required String orgName,
    required String roleName,
    required int karmaCredits,
    required String primaryMetric,
    required String secondaryMetric,
    required Color bgColor,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shadowColor: Colors.black12,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgColor, bgColor.withRed((bgColor.red + 30).clamp(0, 255))],
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
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 10,
                  ),
                ),
                const Icon(
                  Icons.verified_user_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              orgName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              roleName,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL KARMA',
                      style: TextStyle(color: Colors.white70, fontSize: 8),
                    ),
                    Text(
                      '$karmaCredits Karma',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      primaryMetric,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    Text(
                      secondaryMetric,
                      style: const TextStyle(color: Colors.white70, fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatGrid(List<Widget> children) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: children,
    );
  }

  Widget _buildMiniStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 10, color: Colors.grey, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(int rank, String className, String score) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: rank == 1 ? Colors.amber[100] : Colors.grey[200],
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: rank == 1 ? Colors.amber[900] : Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                className,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            Text(
              score,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00B074), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard({
    required String title,
    required String desc,
    required String volunteers,
    required String deadline,
  }) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(desc, style: TextStyle(color: Colors.grey[700], fontSize: 11, height: 1.4)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people_alt_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(volunteers, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                Text(deadline, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationQueueCard({
    required String actionTitle,
    required String submitter,
    required String timeAgo,
    required String evidenceScore,
  }) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(actionTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text('By $submitter  •  $timeAgo', style: const TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4)),
                  child: Text('AI Confidence: $evidenceScore', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B074),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {},
                  child: const Text('Verify Deed ✅', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolunteerCard(String text, String reward) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.volunteer_activism_outlined, color: Colors.teal),
        title: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        trailing: Text(reward, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber)),
      ),
    );
  }

  Widget _buildCSRFundCard(String title, String funded, String status, double progress) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(status, style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            Text(funded, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progress, minHeight: 4, backgroundColor: Colors.grey[200], valueColor: const AlwaysStoppedAnimation(Colors.purple)),
          ],
        ),
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
