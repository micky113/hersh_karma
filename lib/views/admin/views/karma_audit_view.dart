import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';
import '../../../models/admin/admin_role.dart';
import '../widgets/audit_reason_dialog.dart';

class KarmaAuditView extends StatelessWidget {
  const KarmaAuditView({super.key});

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
                  const Text('Karma & Impact Audit Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 2),
                  Text(
                    'Transparent oversight: No silent manipulation. Every adjustment requires authorized admin and mandatory audit reason.',
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // User Balances & Adjustment Table
          Expanded(
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: admin.usersList.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final user = admin.usersList[i];

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF00B074).withOpacity(0.12),
                      child: const Text('✨', style: TextStyle(fontSize: 18)),
                    ),
                    title: Row(
                      children: [
                        Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                        const SizedBox(width: 8),
                        Text('(${user.email})', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    subtitle: Text(
                      'Current Balance: ${user.karmaCredits} Karma Credits • Verified Deeds: ${user.verifiedSubmissions} • Trust: ${(user.trustScore * 100).toInt()}%',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF00B074), fontWeight: FontWeight.w600),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Adjust Karma Button
                        ElevatedButton.icon(
                          icon: const Icon(Icons.edit_note_rounded, size: 16),
                          label: const Text('Adjust Karma', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: admin.currentRole.canAdjustKarma() ? const Color(0xFF00B074) : Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            if (!admin.currentRole.canAdjustKarma()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Permission Denied: Only Super Admin can perform manual Karma adjustments.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final reason = await AuditReasonDialog.show(
                              context,
                              title: 'Adjust Karma for ${user.name}',
                              actionLabel: 'Commit Adjustment (+50 KGC)',
                              prompt: 'Enter mandatory audit justification for this manual Karma credit adjustment:',
                              actionColor: const Color(0xFF00B074),
                            );
                            if (reason != null && context.mounted) {
                              await admin.adjustUserKarma(user.id, 50, reason: reason);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Karma adjusted for ${user.name} (+50 KGC) and logged immutably.'),
                                  backgroundColor: const Color(0xFF00B074),
                                ),
                              );
                            }
                          },
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
