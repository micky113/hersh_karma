import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_profile.dart';
import '../../../providers/admin_provider.dart';
import '../widgets/audit_reason_dialog.dart';

class UsersOrgsView extends StatelessWidget {
  const UsersOrgsView({super.key});

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
                  const Text('Users & Organization Management', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 2),
                  Text(
                    'Manage Individuals, NGOs, Schools & Corporates: KYC verification, Trust scores & history.',
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
                itemCount: admin.usersList.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final user = admin.usersList[i];
                  final isOrg = user.role == UserRole.ngo || user.role == UserRole.institution || user.role == UserRole.corporate;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF00B074).withOpacity(0.12),
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Color(0xFF00B074), fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                        const SizedBox(width: 8),
                        Text('(${user.role.label})', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(width: 8),
                        if (isOrg) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (user.isOrgVerified ? Colors.green : Colors.amber.shade800).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user.isOrgVerified ? '✓ VERIFIED ORG' : '⏳ PENDING KYC',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: user.isOrgVerified ? Colors.green.shade800 : Colors.amber.shade800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          Text('Karma: ${user.karmaCredits} KGC', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF00B074))),
                          const SizedBox(width: 14),
                          Text('Trust: ${(user.trustScore * 100).toInt()}% Rating', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.purple)),
                          const SizedBox(width: 14),
                          Text('Verified Deeds: ${user.verifiedSubmissions}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isOrg)
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () async {
                              final reason = await AuditReasonDialog.show(
                                context,
                                title: user.isOrgVerified ? 'Revoke Org Verification' : 'Approve Organization KYC',
                                actionLabel: user.isOrgVerified ? 'Revoke' : 'Approve KYC',
                                prompt: 'Provide audit justification for organization verification change:',
                              );
                              if (reason != null && context.mounted) {
                                await admin.setOrganizationVerification(user.id, !user.isOrgVerified, reason: reason);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Org KYC updated for ${user.name} with audit entry.')),
                                );
                              }
                            },
                            child: Text(user.isOrgVerified ? 'Revoke KYC' : 'Verify KYC', style: const TextStyle(fontSize: 11)),
                          ),
                        const SizedBox(width: 8),

                        // Adjust Trust Score
                        IconButton(
                          icon: const Icon(Icons.tune_rounded, size: 18, color: Colors.purple),
                          tooltip: 'Adjust Trust Score',
                          onPressed: () async {
                            final reason = await AuditReasonDialog.show(
                              context,
                              title: 'Adjust Contributor Trust Score',
                              actionLabel: 'Set Trust Score',
                              prompt: 'Enter reason and new trust score (e.g. "95% based on stellar cleanups"):',
                              actionColor: Colors.purple,
                            );
                            if (reason != null && context.mounted) {
                              await admin.adjustUserTrustScore(user.id, 0.95, reason: reason);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Trust score updated for ${user.name}')),
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
