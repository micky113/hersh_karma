import 'package:flutter/material.dart';
import '../../../models/admin/fraud_alert.dart';

class RiskScoreBadge extends StatelessWidget {
  final double score; // 0.0 to 1.0
  final FraudSeverity? severity;

  const RiskScoreBadge({
    super.key,
    required this.score,
    this.severity,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    if (score >= 0.85 || severity == FraudSeverity.critical) {
      color = Colors.red.shade700;
      label = 'CRITICAL RISK ${(score * 100).toInt()}%';
    } else if (score >= 0.70 || severity == FraudSeverity.high) {
      color = Colors.orange.shade800;
      label = 'HIGH RISK ${(score * 100).toInt()}%';
    } else if (score >= 0.40 || severity == FraudSeverity.medium) {
      color = Colors.amber.shade800;
      label = 'MEDIUM RISK ${(score * 100).toInt()}%';
    } else {
      color = const Color(0xFF00B074);
      label = 'LOW RISK ${(score * 100).toInt()}%';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
