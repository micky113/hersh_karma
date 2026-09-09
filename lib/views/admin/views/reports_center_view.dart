import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/community_problem.dart';
import '../../../providers/admin_provider.dart';
import '../widgets/audit_reason_dialog.dart';

class ReportsCenterView extends StatelessWidget {
  const ReportsCenterView({super.key});

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
                  const Text('Problem Reports Center', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 2),
                  Text(
                    'Track civic problems: Report ➔ Verify ➔ Fix ➔ Outcome ➔ Reward.',
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
                itemCount: admin.problemReports.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final problem = admin.problemReports[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('🔎', style: TextStyle(fontSize: 20)),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            problem.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                          ),
                        ),
                        _buildStatusChip(problem.status),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(problem.description, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey.shade700)),
                          const SizedBox(height: 4),
                          Text(
                            'Reported by ${problem.reporterName} • Category: ${problem.category.name} • Assigned: ${problem.resolverName ?? "Unassigned"}',
                            style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    trailing: PopupMenuButton<ProblemStatus>(
                      icon: const Icon(Icons.more_vert_rounded),
                      tooltip: 'Update Report Status',
                      onSelected: (status) async {
                        final reason = await AuditReasonDialog.show(
                          context,
                          title: 'Update Report Status',
                          actionLabel: 'Confirm Status Change',
                          prompt: 'Provide audit justification for changing report status to "${status.name}":',
                        );
                        if (reason != null && context.mounted) {
                          await admin.updateReportStatus(problem.id, status, reason: reason);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Report updated to ${status.name} with logged audit reason.')),
                          );
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: ProblemStatus.reported, child: Text('Mark as Reported')),
                        const PopupMenuItem(value: ProblemStatus.underReview, child: Text('Mark Under Review')),
                        const PopupMenuItem(value: ProblemStatus.assigned, child: Text('Assign to Resolver')),
                        const PopupMenuItem(value: ProblemStatus.resolved, child: Text('Mark Resolved & Award Karma')),
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

  Widget _buildStatusChip(ProblemStatus status) {
    Color color = Colors.orange;
    if (status == ProblemStatus.resolved) color = const Color(0xFF00B074);
    if (status == ProblemStatus.underReview) color = Colors.blue;
    if (status == ProblemStatus.assigned) color = Colors.purple;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
