import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/admin/fraud_alert.dart';
import '../../../providers/admin_provider.dart';
import '../widgets/risk_score_badge.dart';
import '../widgets/audit_reason_dialog.dart';

class AntiGamingView extends StatelessWidget {
  const AntiGamingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final admin = Provider.of<AdminProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Anti-Gaming & Fraud Center', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 2),
                  Text(
                    'AI proof firewall flags: duplicate image hashes, velocity anomalies, spam & collusion.',
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: admin.fraudAlerts.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final alert = admin.fraudAlerts[i];

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('🚨', style: TextStyle(fontSize: 22)),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            alert.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                          ),
                        ),
                        RiskScoreBadge(score: alert.riskScore, severity: alert.severity),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(alert.description, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey.shade800)),
                          const SizedBox(height: 4),
                          Text(
                            'Flagged User: ${alert.userName} • Type: ${alert.alertType} • Status: ${alert.status.name.toUpperCase()}',
                            style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
                          ),
                          if (alert.resolutionReason != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Resolved by ${alert.resolvedByAdmin}: "${alert.resolutionReason}"',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF00B074)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Dismiss Action
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            final reason = await AuditReasonDialog.show(
                              context,
                              title: 'Dismiss Fraud Alert',
                              actionLabel: 'Dismiss (False Alarm)',
                              prompt: 'Provide justification why this anomaly is benign / false positive:',
                              actionColor: Colors.blueGrey,
                            );
                            if (reason != null && context.mounted) {
                              await admin.resolveFraudAlert(alert.id, FraudStatus.dismissed, reason: reason);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Alert marked as dismissed with audit log.')),
                              );
                            }
                          },
                          child: const Text('Dismiss', style: TextStyle(fontSize: 11)),
                        ),
                        const SizedBox(width: 8),

                        // Penalize Action
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            final reason = await AuditReasonDialog.show(
                              context,
                              title: 'Penalize Fraudulent Activity',
                              actionLabel: 'Confirm Penalty',
                              prompt: 'Specify the evidence verification and penalty reason (e.g. reduced trust score to 40%):',
                              isDestructive: true,
                            );
                            if (reason != null && context.mounted) {
                              await admin.resolveFraudAlert(alert.id, FraudStatus.penalized, reason: reason);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('User penalized & logged in tamper-resistant audit.')),
                              );
                            }
                          },
                          child: const Text('Penalize', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
