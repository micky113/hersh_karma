import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final adminProvider = Provider.of<AdminProvider>(context);

    final navItems = [
      {'icon': Icons.bolt_rounded, 'title': 'Command Center', 'badge': null, 'badgeColor': null},
      {
        'icon': Icons.verified_user_outlined,
        'title': 'Verification Center',
        'badge': adminProvider.verificationQueue.where((a) => a.status.name == 'pending').length.toString(),
        'badgeColor': Colors.orange
      },
      {
        'icon': Icons.report_problem_outlined,
        'title': 'Problem Reports',
        'badge': adminProvider.pendingReportsCount > 0 ? adminProvider.pendingReportsCount.toString() : null,
        'badgeColor': Colors.deepOrange
      },
      {'icon': Icons.auto_awesome_outlined, 'title': 'Wish Center', 'badge': null, 'badgeColor': null},
      {'icon': Icons.local_florist_outlined, 'title': 'Action Registry', 'badge': null, 'badgeColor': null},
      {
        'icon': Icons.business_outlined,
        'title': 'Users & Organizations',
        'badge': adminProvider.pendingOrgApplicationsCount > 0 ? '${adminProvider.pendingOrgApplicationsCount} KYC' : null,
        'badgeColor': Colors.amber.shade800
      },
      {'icon': Icons.account_balance_wallet_outlined, 'title': 'Karma & Impact Audit', 'badge': null, 'badgeColor': null},
      {
        'icon': Icons.shield_outlined,
        'title': 'Anti-Gaming & Fraud',
        'badge': adminProvider.highRiskVerificationCount > 0 ? '${adminProvider.highRiskVerificationCount} ALERTS' : null,
        'badgeColor': Colors.red
      },
      {
        'icon': Icons.rate_review_outlined,
        'title': 'Feedback & Triage',
        'badge': adminProvider.newFeedbackCount > 0 ? adminProvider.newFeedbackCount.toString() : null,
        'badgeColor': Colors.blue
      },
      {'icon': Icons.translate_rounded, 'title': '22 Languages & RTL', 'badge': null, 'badgeColor': null},
      {'icon': Icons.gavel_outlined, 'title': 'Content & Safety', 'badge': null, 'badgeColor': null},
      {'icon': Icons.admin_panel_settings_outlined, 'title': 'Roles & Permissions', 'badge': null, 'badgeColor': null},
      {'icon': Icons.history_edu_outlined, 'title': 'Immutable Audit Log', 'badge': null, 'badgeColor': null},
      {'icon': Icons.map_outlined, 'title': 'India-First Geographic', 'badge': null, 'badgeColor': null},
      {'icon': Icons.health_and_safety_outlined, 'title': 'System Health', 'badge': null, 'badgeColor': null},
    ];

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          right: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Branding Header
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B074).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('🛡️', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TRUST CENTER',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1.1,
                          color: Color(0xFF00B074),
                        ),
                      ),
                      Text(
                        'Governance & Oversight',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Nav Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isSelected = selectedIndex == index;
                final badge = item['badge'] as String?;
                final badgeColor = (item['badgeColor'] as Color?) ?? Colors.red;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Material(
                    color: isSelected
                        ? const Color(0xFF00B074).withOpacity(isDark ? 0.2 : 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onItemSelected(index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Icon(
                              item['icon'] as IconData,
                              size: 18,
                              color: isSelected
                                  ? const Color(0xFF00B074)
                                  : (isDark ? Colors.white70 : Colors.grey.shade700),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item['title'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFF00B074)
                                      : (isDark ? Colors.white : Colors.black87),
                                ),
                              ),
                            ),
                            if (badge != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badgeColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  badge,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Return to Public App
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.arrow_back_rounded, size: 14),
              label: const Text('Back to Public App', style: TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            ),
          ),
        ],
      ),
    );
  }
}
