import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import 'widgets/admin_sidebar.dart';
import 'widgets/admin_header.dart';
import 'views/command_center_view.dart';
import 'views/verification_center_view.dart';
import 'views/reports_center_view.dart';
import 'views/wishes_center_view.dart';
import 'views/action_registry_view.dart';
import 'views/users_orgs_view.dart';
import 'views/karma_audit_view.dart';
import 'views/anti_gaming_view.dart';
import 'views/feedback_view.dart';
import 'views/languages_view.dart';
import 'views/content_safety_view.dart';
import 'views/roles_permissions_view.dart';
import 'views/audit_log_view.dart';
import 'views/analytics_view.dart';
import '../../providers/auth_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../models/user_profile.dart';
import 'views/system_health_view.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedTabIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isUnlocked = false;

  void _showPasscodeDialog(BuildContext context) {
    final passController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF00B074)),
            SizedBox(width: 8),
            Text('Admin Passcode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter administrator access code (e.g. 1234, admin, karma):',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passController,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Passcode (e.g. 1234)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B074),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final val = passController.text.trim().toLowerCase();
              if (val == '1234' || val == 'admin' || val == 'karma') {
                Navigator.pop(ctx);
                setState(() => _isUnlocked = true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid passcode. Use 1234, admin, or karma.'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;

    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    final isAdmin = _isUnlocked || (user != null &&
        (user.role == UserRole.ngo ||
            user.role == UserRole.institution ||
            user.role == UserRole.government ||
            user.email == 'governance@karma.org' ||
            user.email.contains('admin')));

    if (!auth.isAuthenticated || user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin & Trust Center')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_outlined, size: 60, color: Color(0xFF00B074)),
                      const SizedBox(height: 16),
                      const Text(
                        'Admin Authorization Required',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Logged in as ${user.email} (${user.role.label}).\nTo access the Trust & Governance Center, enter the admin passcode or switch to an authorized organization account.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.key_rounded, size: 18),
                          label: const Text('Unlock with Passcode (1234)', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00B074),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _showPasscodeDialog(context),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                          label: const Text('Switch to Admin (Jane NGO)'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            await auth.login('jane@karma.com', 'password123');
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        icon: const Icon(Icons.arrow_back_rounded, size: 16),
                        label: const Text('Return to Home'),
                        onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final views = [
      CommandCenterView(onNavigateTab: (idx) => setState(() => _selectedTabIndex = idx)),
      const VerificationCenterView(),
      const ReportsCenterView(),
      const WishesCenterView(),
      const ActionRegistryView(),
      const UsersOrgsView(),
      const KarmaAuditView(),
      const AntiGamingView(),
      const FeedbackView(),
      const LanguagesView(),
      const ContentSafetyView(),
      const RolesPermissionsView(),
      const AuditLogView(),
      const AnalyticsView(),
      const SystemHealthView(),
    ];

    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC),
        drawer: Drawer(
          child: AdminSidebar(
            selectedIndex: _selectedTabIndex,
            onItemSelected: (idx) {
              setState(() => _selectedTabIndex = idx);
              Navigator.pop(context); // Close mobile drawer
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              AdminHeader(
                isMobile: true,
                onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              Expanded(
                child: views[_selectedTabIndex],
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Sidebar
          AdminSidebar(
            selectedIndex: _selectedTabIndex,
            onItemSelected: (idx) => setState(() => _selectedTabIndex = idx),
          ),

          // Main Workspace
          Expanded(
            child: Column(
              children: [
                const AdminHeader(isMobile: false),
                Expanded(
                  child: views[_selectedTabIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
