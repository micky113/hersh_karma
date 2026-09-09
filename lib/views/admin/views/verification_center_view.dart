import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/karma_action.dart';
import '../../../providers/admin_provider.dart';
import '../widgets/evidence_inspector_modal.dart';

class VerificationCenterView extends StatefulWidget {
  const VerificationCenterView({super.key});

  @override
  State<VerificationCenterView> createState() => _VerificationCenterViewState();
}

class _VerificationCenterViewState extends State<VerificationCenterView> {
  String _filterStatus = 'all'; // 'all', 'pending', 'verified', 'rejected'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final adminProvider = Provider.of<AdminProvider>(context);

    final filtered = adminProvider.verificationQueue.where((a) {
      if (_filterStatus == 'pending') return a.status == DeedStatus.pending;
      if (_filterStatus == 'verified') return a.status == DeedStatus.verified;
      if (_filterStatus == 'rejected') return a.status == DeedStatus.rejected;
      return true;
    }).toList();

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text('Verification Center', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 18 : 20)),
          const SizedBox(height: 2),
          Text(
            'Multi-tier evidence inspection: Before/After photos, AI screening score & audit review.',
            style: TextStyle(fontSize: isMobile ? 11 : 12, color: isDark ? Colors.white60 : Colors.grey.shade600),
          ),
          const SizedBox(height: 12),

          // Horizontal Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All Actions', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Pending Review', 'pending'),
                const SizedBox(width: 8),
                _buildFilterChip('Verified', 'verified'),
                const SizedBox(width: 8),
                _buildFilterChip('Rejected', 'rejected'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Verification Table
          Expanded(
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
              ),
              child: ListView.separated(
                padding: EdgeInsets.all(isMobile ? 8 : 12),
                itemCount: filtered.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final action = filtered[i];

                  if (isMobile) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: const Color(0xFF00B074).withOpacity(0.12),
                                child: Text(
                                  action.userName.isNotEmpty ? action.userName[0].toUpperCase() : 'U',
                                  style: const TextStyle(color: Color(0xFF00B074), fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  action.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _buildStatusBadge(action.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _buildLevelBadge(action.verificationLevel),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (action.evidenceScore >= 90 ? Colors.green : Colors.orange).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Score: ${action.evidenceScore}/100',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: action.evidenceScore >= 90 ? Colors.green.shade800 : Colors.orange.shade800,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                action.userName,
                                style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.grey.shade600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.compare_arrows_rounded, size: 14),
                              label: const Text('Inspect Evidence', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00B074),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => EvidenceInspectorModal.show(context, action),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF00B074).withOpacity(0.12),
                      child: Text(
                        action.userName.isNotEmpty ? action.userName[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Color(0xFF00B074), fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            action.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                          ),
                        ),
                        _buildLevelBadge(action.verificationLevel),
                        const SizedBox(width: 8),
                        _buildStatusBadge(action.status),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Row(
                        children: [
                          Text('Contributor: ${action.userName}', style: const TextStyle(fontSize: 11.5)),
                          const SizedBox(width: 12),
                          Text('Category: ${action.category.name}', style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (action.evidenceScore >= 90 ? Colors.green : Colors.orange).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'AI Evidence Score: ${action.evidenceScore}/100',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: action.evidenceScore >= 90 ? Colors.green.shade800 : Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: ElevatedButton.icon(
                      icon: const Icon(Icons.compare_arrows_rounded, size: 14),
                      label: const Text('Inspect Evidence', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B074),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => EvidenceInspectorModal.show(context, action),
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

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedColor: const Color(0xFF00B074).withOpacity(0.2),
      onSelected: (_) => setState(() => _filterStatus = value),
    );
  }

  Widget _buildLevelBadge(int level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Level $level',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  Widget _buildStatusBadge(DeedStatus status) {
    Color color = Colors.orange;
    String label = 'PENDING';
    if (status == DeedStatus.verified) {
      color = const Color(0xFF00B074);
      label = 'VERIFIED';
    } else if (status == DeedStatus.rejected) {
      color = Colors.red;
      label = 'REJECTED';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
