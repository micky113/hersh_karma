import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/localization/app_localizations.dart';

class KarmaResultScreen extends StatelessWidget {
  const KarmaResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final int creditsEarned = (args is int) ? args : 350;

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.translateWithContext(context, '🎉 Karma Earned', defaultValue: '🎉 Karma Earned')),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Success Confetti Graphic
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  size: 80,
                  color: Color(0xFF00B074),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              AppLocalizations.translateWithContext(context, '🎉 YOU EARNED KARMA', defaultValue: '🎉 YOU EARNED KARMA'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1.5,
                color: Color(0xFF00B074),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '+$creditsEarned ${AppLocalizations.translateWithContext(context, 'Verified Karma', defaultValue: 'Verified Karma')}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            Text(
              AppLocalizations.translateWithContext(context, 'What would you like to do with your Karma?', defaultValue: 'What would you like to do with your Karma?'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Loop options
            _buildLoopCard(
              context,
              icon: Icons.star_rounded,
              color: Colors.amber,
              title: AppLocalizations.translateWithContext(context, '✨ Make a Wish', defaultValue: '✨ Make a Wish'),
              desc: AppLocalizations.translateWithContext(context, 'Submit a personal or community wish and let the network coordinate to fulfill it.', defaultValue: 'Submit a personal or community wish and let the network coordinate to fulfill it.'),
              route: AppRoutes.createWish,
            ),
            const SizedBox(height: 12),

            _buildLoopCard(
              context,
              icon: Icons.waves_rounded,
              color: Colors.blue,
              title: AppLocalizations.translateWithContext(context, '🌊 Help Someone\'s Wish', defaultValue: '🌊 Help Someone\'s Wish'),
              desc: AppLocalizations.translateWithContext(context, 'Contribute your Karma, tools, goods, or mentorship to a community member\'s wish plan.', defaultValue: 'Contribute your Karma, tools, goods, or mentorship to a community member\'s wish plan.'),
              route: AppRoutes.wishes,
            ),
            const SizedBox(height: 12),

            _buildLoopCard(
              context,
              icon: Icons.eco_rounded,
              color: Colors.green,
              title: AppLocalizations.translateWithContext(context, '🌱 Support Impact', defaultValue: '🌱 Support Impact'),
              desc: AppLocalizations.translateWithContext(context, 'Sponsor verified NGO projects, fund carbon offsets, or mint cryptocurrency tokens.', defaultValue: 'Sponsor verified NGO projects, fund carbon offsets, or mint cryptocurrency tokens.'),
              route: AppRoutes.rewards,
            ),
            const SizedBox(height: 12),

            _buildLoopCard(
              context,
              icon: Icons.emoji_events_rounded,
              color: Colors.purple,
              title: AppLocalizations.translateWithContext(context, '🏆 Continue Your Impact', defaultValue: '🏆 Continue Your Impact'),
              desc: AppLocalizations.translateWithContext(context, 'Complete active challenges and unlock development quest multipliers.', defaultValue: 'Complete active challenges and unlock development quest multipliers.'),
              route: AppRoutes.home,
              args: 0, // goes back to home dashboard
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLoopCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
    required String route,
    dynamic args,
  }) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          if (route == AppRoutes.home) {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false, arguments: args);
          } else {
            Navigator.pushReplacementNamed(context, route);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: TextStyle(color: Colors.grey[700], fontSize: 11, height: 1.4),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
