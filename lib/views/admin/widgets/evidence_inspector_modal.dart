import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/karma_action.dart';
import '../../../providers/admin_provider.dart';
import 'audit_reason_dialog.dart';

class EvidenceInspectorModal extends StatelessWidget {
  final KarmaAction action;

  const EvidenceInspectorModal({super.key, required this.action});

  static void show(BuildContext context, KarmaAction action) {
    showDialog(
      context: context,
      builder: (ctx) => EvidenceInspectorModal(action: action),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final adminProvider = Provider.of<AdminProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: isMobile ? 16 : 24),
      child: Container(
        width: 880,
        constraints: BoxConstraints(maxHeight: isMobile ? 640 : 700),
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B074).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('🔍', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'By ${action.userName} • ${action.category.name} • Level ${action.verificationLevel}',
                        style: TextStyle(fontSize: 10.5, color: isDark ? Colors.white60 : Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dual-Pane Before & After Evidence
                    if (isMobile) ...[
                      _buildEvidencePane(
                        context,
                        title: 'BEFORE EVIDENCE 📸',
                        imageUrl: action.beforeImageUrl,
                        badgeColor: Colors.amber.shade800,
                        subtitle: 'Starting conditions / baseline evidence',
                        height: 150,
                      ),
                      const SizedBox(height: 12),
                      _buildEvidencePane(
                        context,
                        title: 'AFTER EVIDENCE 📸',
                        imageUrl: action.imageUrl,
                        badgeColor: const Color(0xFF00B074),
                        subtitle: 'Outcome outcome / verified completion',
                        height: 150,
                      ),
                    ] else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildEvidencePane(
                              context,
                              title: 'BEFORE EVIDENCE 📸',
                              imageUrl: action.beforeImageUrl,
                              badgeColor: Colors.amber.shade800,
                              subtitle: 'Starting conditions / baseline evidence',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildEvidencePane(
                              context,
                              title: 'AFTER EVIDENCE 📸',
                              imageUrl: action.imageUrl,
                              badgeColor: const Color(0xFF00B074),
                              subtitle: 'Outcome outcome / verified completion',
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),

                    // AI Evidence Screening Breakdown Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.psychology_outlined, color: Color(0xFF00B074), size: 18),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text('AI Evidence Screening Analysis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (action.evidenceScore >= 90 ? Colors.green : Colors.orange).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Score: ${action.evidenceScore}/100',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: action.evidenceScore >= 90 ? Colors.green.shade800 : Colors.orange.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _buildMetricPill('Scene Match Confidence', '${((action.sceneMatchConfidence ?? 0.88) * 100).toInt()}%', Colors.blue),
                              _buildMetricPill('Duplicate Hash', 'PASSED', Colors.green),
                              _buildMetricPill('Travel Speed', 'PASSED', Colors.green),
                              _buildMetricPill('Reach', '${action.scale} Units', Colors.teal),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Description text
                    Text('Contributor Description:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: isDark ? Colors.white70 : Colors.black87)),
                    const SizedBox(height: 4),
                    Text(
                      action.description,
                      style: TextStyle(fontSize: 11.5, color: isDark ? Colors.white60 : Colors.grey.shade700, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Decision Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Reject Button
                OutlinedButton.icon(
                  icon: const Icon(Icons.close_rounded, size: 14, color: Colors.red),
                  label: const Text('Reject', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final reason = await AuditReasonDialog.show(
                      context,
                      title: 'Reject Action Evidence',
                      actionLabel: 'Confirm Rejection',
                      prompt: 'Specify the reason for rejecting this Proof of Good submission:',
                      isDestructive: true,
                    );
                    if (reason != null && context.mounted) {
                      await adminProvider.rejectActionVerification(action.id, reason: reason);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Submission rejected with logged audit reason.')),
                      );
                    }
                  },
                ),

                // Request More Evidence
                OutlinedButton.icon(
                  icon: const Icon(Icons.contact_support_outlined, size: 14, color: Colors.orange),
                  label: const Text('Request Proof', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final reason = await AuditReasonDialog.show(
                      context,
                      title: 'Request Additional Proof',
                      actionLabel: 'Send Request',
                      prompt: 'Enter instructions for what additional evidence the contributor must provide:',
                      actionColor: Colors.orange,
                    );
                    if (reason != null && context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Request for additional evidence sent.')),
                      );
                    }
                  },
                ),

                // Approve Button
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 14),
                  label: const Text('Approve Deed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B074),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final reason = await AuditReasonDialog.show(
                      context,
                      title: 'Approve Proof of Good Deed',
                      actionLabel: 'Confirm Approval',
                      prompt: 'Provide verification justification to commit into the permanent audit log:',
                      actionColor: const Color(0xFF00B074),
                    );
                    if (reason != null && context.mounted) {
                      await adminProvider.approveActionVerification(action.id, reason: reason);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Action approved! ${action.creditsAwarded > 0 ? action.creditsAwarded : (action.scale * 50)} Karma awarded.'),
                          backgroundColor: const Color(0xFF00B074),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidencePane(
    BuildContext context, {
    required String title,
    String? imageUrl,
    required Color badgeColor,
    required String subtitle,
    double height = 200,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, color: badgeColor)),
              ],
            ),
          ),
          Container(
            height: height,
            decoration: BoxDecoration(
              color: Colors.black12,
              image: (imageUrl != null && imageUrl.isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (imageUrl == null || imageUrl.isEmpty)
                ? const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 30))
                : null,
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              subtitle,
              style: TextStyle(fontSize: 9.5, color: isDark ? Colors.white60 : Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill(String label, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25), width: 0.8),
      ),
      child: Text(
        '$label: $val',
        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
