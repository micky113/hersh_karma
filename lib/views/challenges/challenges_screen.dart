import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/karma_provider.dart';
import '../../models/challenge.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final karmaProvider = Provider.of<KarmaProvider>(context);
    final challenges = karmaProvider.challenges;

    final available = challenges.where((e) => !e.isAccepted && !e.isCompleted).toList();
    final active = challenges.where((e) => e.isAccepted && !e.isCompleted).toList();
    final completed = challenges.where((e) => e.isCompleted).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Card
          Card(
            color: theme.colorScheme.primary.withOpacity(0.08),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded, color: Color(0xFFFFB300), size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Karma Challenges',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Complete daily missions to earn bonus Karma credits and boost your validator reputation.',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Active Challenges
          if (active.isNotEmpty) ...[
            _buildSectionHeader(theme, 'Active Missions (${active.length})'),
            const SizedBox(height: 10),
            ...active.map((ch) => _buildChallengeCard(context, ch, theme)),
            const SizedBox(height: 24),
          ],

          // Available Challenges
          _buildSectionHeader(theme, 'Available Missions (${available.length})'),
          const SizedBox(height: 10),
          if (available.isEmpty)
            _buildEmptyState('No new missions available today. Check back tomorrow!')
          else
            ...available.map((ch) => _buildChallengeCard(context, ch, theme)),
          const SizedBox(height: 24),

          // Completed Challenges
          if (completed.isNotEmpty) ...[
            _buildSectionHeader(theme, 'Completed Missions (${completed.length})'),
            const SizedBox(height: 10),
            ...completed.map((ch) => _buildChallengeCard(context, ch, theme)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            msg,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeCard(BuildContext context, KarmaChallenge ch, ThemeData theme) {
    final karmaProvider = Provider.of<KarmaProvider>(context, listen: false);
    final progress = ch.targetCount > 0 ? ch.currentCount / ch.targetCount : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ch.category.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(ch.category.icon, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        ch.category.label,
                        style: TextStyle(
                          color: ch.category.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '+${ch.rewardCredits} CR',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ch.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              ch.description,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 16),

            if (ch.isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B074).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00B074).withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.check_circle_rounded, color: Color(0xFF00B074), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Mission Completed! Credits Rewarded.',
                      style: TextStyle(
                        color: Color(0xFF00B074),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            else if (ch.isAccepted)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress: ${ch.currentCount}/${ch.targetCount}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(fontSize: 11, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Submit verified deeds in the ${ch.category.label} category to complete this challenge.',
                    style: TextStyle(fontSize: 10, color: Colors.grey[500], fontStyle: FontStyle.italic),
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: () {
                  karmaProvider.acceptChallenge(ch.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Joined challenge: ${ch.title}! 🌱'),
                      backgroundColor: const Color(0xFF00B074),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 38),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Accept Challenge', style: TextStyle(fontSize: 13)),
              ),
          ],
        ),
      ),
    );
  }
}
