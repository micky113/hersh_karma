import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';

class DemoBadge extends StatelessWidget {
  final String? customLabel;
  const DemoBadge({super.key, this.customLabel});

  @override
  Widget build(BuildContext context) {
    final label = customLabel ??
        AppLocalizations.translateWithContext(context, 'demo_badge', defaultValue: 'Example / Demo Story');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.amber.shade700.withOpacity(0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline_rounded, size: 11, color: Colors.amber.shade900),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade900,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
