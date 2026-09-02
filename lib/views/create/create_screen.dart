import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../support/feedback_modal.dart';
import '../../core/localization/app_localizations.dart';

class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.translateWithContext(context, 'nav_create', defaultValue: 'Create & Contribute'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Text(
            'What would you like to contribute today?',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose how you want to create real-world positive change:',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // 1. DO AN ACTION
          _buildCreationCard(
            context,
            emoji: '🌱',
            title: 'Do an Action',
            subtitle: 'Take a positive deed from the taxonomy, capture Before/After photo evidence, and earn Karma.',
            badge: 'Earn +20 to +100 Karma',
            badgeColor: const Color(0xFF00B074),
            onTap: () => Navigator.pushNamed(context, AppRoutes.uploadProof),
          ),
          const SizedBox(height: 16),

          // 2. REPORT A PROBLEM
          _buildCreationCard(
            context,
            emoji: '🔎',
            title: 'Report a Problem',
            subtitle: 'Photograph a visible issue (garbage dump, broken pipe, injured animal) with GPS verification.',
            badge: 'Earn +20 Karma & +10 Trust',
            badgeColor: Colors.orange,
            onTap: () => Navigator.pushNamed(context, AppRoutes.reportAbuse),
          ),
          const SizedBox(height: 16),

          // 3. MAKE A WISH
          _buildCreationCard(
            context,
            emoji: '✨',
            title: 'Make a Wish',
            subtitle: 'Ask the community or NGOs for assistance with education, medical tools, or essential needs.',
            badge: 'Community Supported',
            badgeColor: Colors.purple,
            onTap: () => Navigator.pushNamed(context, AppRoutes.createWish),
          ),
          const SizedBox(height: 16),

          // 4. ADD AN ACTION PROPOSAL
          _buildCreationCard(
            context,
            emoji: '💡',
            title: 'Add an Action Proposal',
            subtitle: 'Propose a brand new leap-year action to be added to the global Karma taxonomy.',
            badge: 'Governance Consensus',
            badgeColor: Colors.blue,
            onTap: () => Navigator.pushNamed(context, AppRoutes.proposeAction),
          ),
          const SizedBox(height: 16),

          // 5. SUGGEST AN IMPROVEMENT / FEEDBACK
          _buildCreationCard(
            context,
            emoji: '💬',
            title: 'Suggest an Improvement',
            subtitle: 'Help improve Karma Grid by submitting an idea, reporting a bug, or sharing local usability feedback.',
            badge: 'App Improvement',
            badgeColor: Colors.teal,
            onTap: () => FeedbackModal.show(context, 'CreateScreen'),
          ),
        ],
      ),
    );
  }

  Widget _buildCreationCard(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(color: badgeColor, fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
