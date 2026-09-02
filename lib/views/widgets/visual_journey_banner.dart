import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';

class VisualJourneyBanner extends StatelessWidget {
  final bool compact;
  const VisualJourneyBanner({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final steps = [
      {'icon': '📸', 'title': AppLocalizations.translateWithContext(context, 'step_before', defaultValue: 'BEFORE 📸'), 'desc': 'Capture starting condition'},
      {'icon': '⚡', 'title': AppLocalizations.translateWithContext(context, 'step_action', defaultValue: 'DO / FIX ⚡'), 'desc': 'Take positive action'},
      {'icon': '📸', 'title': AppLocalizations.translateWithContext(context, 'step_after', defaultValue: 'AFTER 📸'), 'desc': 'Capture result'},
      {'icon': '✓', 'title': AppLocalizations.translateWithContext(context, 'step_verified', defaultValue: 'VERIFIED ✓'), 'desc': 'Multi-layer screening'},
      {'icon': '🌍', 'title': AppLocalizations.translateWithContext(context, 'step_impact', defaultValue: 'IMPACT 🌍'), 'desc': 'Real-world difference'},
      {'icon': '✨', 'title': AppLocalizations.translateWithContext(context, 'step_karma', defaultValue: 'KARMA ✨'), 'desc': 'Passport recognition'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00B074).withOpacity(isDark ? 0.25 : 0.18),
          width: 1,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: compact ? 10 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.translateWithContext(context, 'demo_banner_title', defaultValue: 'The Proof of Good Journey'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: compact ? 12 : 13,
                    color: isDark ? Colors.white : const Color(0xFF0F5132),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(steps.length * 2 - 1, (index) {
                if (index.isOdd) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: const Color(0xFF00B074).withOpacity(0.5),
                    ),
                  );
                }
                final stepIndex = index ~/ 2;
                final step = steps[stepIndex];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(step['icon']!, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 6),
                      Text(
                        step['title']!,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
