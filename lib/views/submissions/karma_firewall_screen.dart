import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/karma_provider.dart';
import '../../models/karma_action.dart';

class KarmaFirewallScreen extends StatelessWidget {
  const KarmaFirewallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AuthProvider>(context).currentUser;
    final karmaProvider = Provider.of<KarmaProvider>(context);

    final actions = karmaProvider.myActions;
    final trustPct = user != null ? (user.trustScore * 100).toInt() : 95;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🛡️ Karma Firewall Engine'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Firewall Status Card
            Card(
              color: Colors.blueGrey.withOpacity(0.08),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.blueGrey, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      '🛡️ KARMA FIREWALL STATUS',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Analyzes Travel Velocity, Duplicate Evidence, Collusion, Auditing Flags, and Verification splits to protect reward protocol integrity.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.blueGrey),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '$trustPct%',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueGrey),
                            ),
                            const Text('Account Trust', style: TextStyle(fontSize: 11)),
                          ],
                        ),
                        Container(width: 1, height: 30, color: Colors.grey[300]),
                        Column(
                          children: [
                            Text(
                              '${actions.where((e) => e.isAudited).length}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange),
                            ),
                            const Text('Audited Deeds', style: TextStyle(fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Security Ledger Logs',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (actions.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      'No firewall logs found. Submit deeds to view analytics.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: actions.length,
                itemBuilder: (context, idx) {
                  final action = actions[idx];
                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  action.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Level ${action.verificationLevel}',
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          _buildDetailRow('Confidence Strength', '${(action.confidenceScore * 100).toInt()}% confidence rating'),
                          _buildDetailRow('POG Split release', '⚡ Prov: ${action.provisionalCredits} | 🛡️ Ver: ${action.verifiedCredits} | 🌱 Out: ${action.outcomeCredits}'),
                          
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('AI Evidence Score', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                Row(
                                  children: [
                                    Text('${action.evidenceScore}/100', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: action.status == DeedStatus.verified
                                            ? Colors.green.withOpacity(0.12)
                                            : action.status == DeedStatus.rejected
                                                ? Colors.red.withOpacity(0.12)
                                                : Colors.amber.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        action.status == DeedStatus.verified
                                            ? 'Auto-Verified'
                                            : action.status == DeedStatus.rejected
                                                ? 'Flagged/Hold'
                                                : 'Community Review',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: action.status == DeedStatus.verified
                                              ? Colors.green
                                              : action.status == DeedStatus.rejected
                                                  ? Colors.red
                                                  : Colors.amber[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          if (action.isAudited) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.verified_user_rounded, color: Colors.orange, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  action.auditPassed ? 'Random Audit Passed' : 'Random Audit Failed (Suspected fraud)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: action.auditPassed ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          if (action.proofBondStaked > 0) ...[
                            const SizedBox(height: 6),
                            Text(
                              '🔒 Proof Bond Active: ${action.proofBondStaked} Reputation Points staked.',
                              style: const TextStyle(fontSize: 11, color: Colors.purple, fontWeight: FontWeight.bold),
                            ),
                          ],

                          if (action.anonymizedWitnessCode != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              '👤 Vulnerable protection active. QR Code ID: ${action.anonymizedWitnessCode}',
                              style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(val, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
