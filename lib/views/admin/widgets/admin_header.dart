import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/admin/admin_role.dart';
import '../../../providers/admin_provider.dart';

class AdminHeader extends StatelessWidget {
  final bool isMobile;
  final VoidCallback? onOpenDrawer;

  const AdminHeader({
    super.key,
    this.isMobile = false,
    this.onOpenDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final adminProvider = Provider.of<AdminProvider>(context);
    final admin = adminProvider.currentAdmin;

    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          bottom: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // Drawer Hamburger (Mobile Only)
          if (isMobile) ...[
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: Color(0xFF00B074)),
              tooltip: 'Open Governance Menu',
              onPressed: onOpenDrawer,
            ),
            const SizedBox(width: 4),
          ],

          // Search in Admin
          if (!isMobile) ...[
            Container(
              width: 240,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade300),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search audit, user, deed...',
                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Brand Title on Mobile Header
            const Row(
              children: [
                Text('🛡️', style: TextStyle(fontSize: 18)),
                SizedBox(width: 6),
                Text(
                  'TRUST CENTER',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: Color(0xFF00B074),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ],
          const Spacer(),

          // Role Switcher for Least-Privilege Verification & Demo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF00B074).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF00B074).withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_outlined, size: 13, color: Color(0xFF00B074)),
                const SizedBox(width: 4),
                DropdownButtonHideUnderline(
                  child: DropdownButton<AdminRole>(
                    value: admin.role,
                    isDense: true,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    items: AdminRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(
                          isMobile ? role.label.split(' ')[0] : role.label,
                          style: const TextStyle(fontSize: 11),
                        ),
                      );
                    }).toList(),
                    onChanged: (newRole) {
                      if (newRole != null) {
                        adminProvider.switchAdminRole(newRole);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Admin Profile Avatar
          CircleAvatar(
            radius: isMobile ? 14 : 16,
            backgroundColor: const Color(0xFF00B074),
            child: Text(
              admin.name.isNotEmpty ? admin.name[0].toUpperCase() : 'A',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 13),
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  admin.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  admin.department,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
