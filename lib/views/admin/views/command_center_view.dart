import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';
import '../widgets/stat_card.dart';

class CommandCenterView extends StatelessWidget {
  final ValueChanged<int> onNavigateTab;

  const CommandCenterView({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final admin = Provider.of<AdminProvider>(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner
          Container(
            padding: EdgeInsets.all(isMobile ? 14 : 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00B074).withOpacity(0.12),
                  const Color(0xFF00B074).withOpacity(0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00B074).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 10 : 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B074),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.bolt_rounded, color: Colors.white, size: isMobile ? 22 : 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Governance & Trust Command Center',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 15 : 18),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Action-first oversight: surface and resolve critical ecosystem items requiring decision today.',
                        style: TextStyle(fontSize: isMobile ? 11 : 12, color: isDark ? Colors.white70 : Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Actionable Attention Cards Grid
          Text(
            '⚠️ Action Required Today',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 12),

          if (isMobile) ...[
            _buildAttentionCard(
              context,
              badge: '🔴 URGENT',
              badgeColor: Colors.red,
              title: '${admin.highRiskVerificationCount} High-Risk Fraud Alerts',
              subtitle: 'Duplicate photo hashes & velocity anomalies flagged by Proof Firewall.',
              actionLabel: 'Investigate Fraud (Tab 7)',
              onTap: () => onNavigateTab(7),
            ),
            const SizedBox(height: 12),
            _buildAttentionCard(
              context,
              badge: '🟠 ACTIVE',
              badgeColor: Colors.deepOrange,
              title: '${admin.pendingReportsCount} Civic Problem Reports',
              subtitle: 'Unresolved community garbage, hazard, or civic problem submissions.',
              actionLabel: 'Review Reports (Tab 2)',
              onTap: () => onNavigateTab(2),
            ),
            const SizedBox(height: 12),
            _buildAttentionCard(
              context,
              badge: '🟡 KYC REVIEW',
              badgeColor: Colors.amber.shade800,
              title: '${admin.pendingOrgApplicationsCount} Org Verification Applications',
              subtitle: 'NGOs, Schools & CSR entities pending identity / document checks.',
              actionLabel: 'Verify Orgs (Tab 5)',
              onTap: () => onNavigateTab(5),
            ),
            const SizedBox(height: 12),
            _buildAttentionCard(
              context,
              badge: '🟢 AUDIT',
              badgeColor: Colors.green.shade700,
              title: '${admin.autoVerifiedAuditCount} Auto-Verified Actions',
              subtitle: 'Sample spot-check queue for Level 1 deeds (score ≥ 90).',
              actionLabel: 'Inspect Queue (Tab 1)',
              onTap: () => onNavigateTab(1),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _buildAttentionCard(
                    context,
                    badge: '🔴 URGENT',
                    badgeColor: Colors.red,
                    title: '${admin.highRiskVerificationCount} High-Risk Fraud Alerts',
                    subtitle: 'Duplicate photo hashes & velocity anomalies flagged by Proof Firewall.',
                    actionLabel: 'Investigate Fraud (Tab 7)',
                    onTap: () => onNavigateTab(7),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAttentionCard(
                    context,
                    badge: '🟠 ACTIVE',
                    badgeColor: Colors.deepOrange,
                    title: '${admin.pendingReportsCount} Civic Problem Reports',
                    subtitle: 'Unresolved community garbage, hazard, or civic problem submissions.',
                    actionLabel: 'Review Reports (Tab 2)',
                    onTap: () => onNavigateTab(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAttentionCard(
                    context,
                    badge: '🟡 KYC REVIEW',
                    badgeColor: Colors.amber.shade800,
                    title: '${admin.pendingOrgApplicationsCount} Org Verification Applications',
                    subtitle: 'NGOs, Schools & CSR entities pending identity / document checks.',
                    actionLabel: 'Verify Orgs (Tab 5)',
                    onTap: () => onNavigateTab(5),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAttentionCard(
                    context,
                    badge: '🟢 AUDIT',
                    badgeColor: Colors.green.shade700,
                    title: '${admin.autoVerifiedAuditCount} Auto-Verified Actions',
                    subtitle: 'Sample spot-check queue for Level 1 deeds (score ≥ 90).',
                    actionLabel: 'Inspect Queue (Tab 1)',
                    onTap: () => onNavigateTab(1),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),

          // High Level System Metric Tiles
          Text(
            '📊 Ecosystem Metrics & Volume',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 12),

          if (isMobile) ...[
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Verified',
                    value: '4,180',
                    subtitle: '98.2% Accuracy',
                    delta: '+14%',
                    icon: Icons.verified_rounded,
                    color: const Color(0xFF00B074),
                    onTap: () => onNavigateTab(1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    title: 'Karma Issued',
                    value: '84.5K',
                    subtitle: '0 Reversals',
                    delta: '+1.2K',
                    icon: Icons.toll_rounded,
                    color: Colors.purple,
                    onTap: () => onNavigateTab(6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Trust Score',
                    value: '94.8%',
                    subtitle: '1,240 Users',
                    delta: '+0.4%',
                    icon: Icons.shield_rounded,
                    color: Colors.blue,
                    onTap: () => onNavigateTab(5),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    title: 'Wishes Met',
                    value: '48 / 62',
                    subtitle: 'Retailer Paid',
                    delta: '77.4%',
                    icon: Icons.auto_awesome_rounded,
                    color: Colors.amber.shade800,
                    onTap: () => onNavigateTab(3),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Actions Verified',
                    value: '4,180',
                    subtitle: '98.2% Auto-screen accuracy',
                    delta: '+14% this week',
                    icon: Icons.verified_rounded,
                    color: const Color(0xFF00B074),
                    onTap: () => onNavigateTab(1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Karma Issued',
                    value: '84,500',
                    subtitle: '0 Reversals today',
                    delta: '+1,250 KGC',
                    icon: Icons.toll_rounded,
                    color: Colors.purple,
                    onTap: () => onNavigateTab(6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Average Trust Rating',
                    value: '94.8%',
                    subtitle: 'Across 1,240 contributors',
                    delta: '+0.4%',
                    icon: Icons.shield_rounded,
                    color: Colors.blue,
                    onTap: () => onNavigateTab(5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Wishes Fulfilled',
                    value: '48 / 62',
                    subtitle: 'Routed to verified retailers',
                    delta: '77.4% Rate',
                    icon: Icons.auto_awesome_rounded,
                    color: Colors.amber.shade800,
                    onTap: () => onNavigateTab(3),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttentionCard(
    BuildContext context, {
    required String badge,
    required Color badgeColor,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: badgeColor.withOpacity(0.3), width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: badgeColor,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_rounded, size: 16, color: badgeColor),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.grey.shade600, height: 1.3),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: badgeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: onTap,
                child: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
