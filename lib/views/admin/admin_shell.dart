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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;

    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    final isAdmin = user != null &&
        (user.role == UserRole.ngo ||
            user.role == UserRole.institution ||
            user.role == UserRole.government ||
            user.email == 'governance@karma.org' ||
            user.email.contains('admin'));

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
        appBar: AppBar(title: const Text('Access Restricted')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_outlined, size: 64, color: Colors.orange),
                const SizedBox(height: 16),
                const Text(
                  'Admin Authorization Required',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your account does not have verified administrative or governance authority to view the Trust Center.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Return to Home'),
                  onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
                ),
              ],
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
