import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/routes/app_routes.dart';
import 'dashboard/dashboard_screen.dart';
import 'challenges/challenges_screen.dart';
import 'wishes/wish_board_screen.dart';
import 'wallet/wallet_screen.dart';
import '../services/voice_service.dart';
import 'support/feedback_modal.dart';
import '../core/localization/app_localizations.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _currentIndex = 0;
  bool _firstLoad = true;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const SizedBox.shrink(), // Dummy index placeholder for Create sheet
    const WishBoardScreen(),
    const WalletScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    if (_firstLoad) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        // Adjust for index bounds in the new 4-tab scheme
        _currentIndex = args >= 0 && args < 4 ? args : 0;
      }
      _firstLoad = false;
    }

    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    if (user != null) {
      KarmaVoice.currentLanguage = user.preferredLanguage;
    }

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          key: const Key('appbar_profile_avatar'),
          onTap: () => Navigator.pushNamed(context, AppRoutes.profileDetail),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF00B074).withOpacity(0.12),
              child: Text(
                user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF00B074)),
              ),
            ),
          ),
        ),
        title: Text(
          _currentIndex == 0
              ? AppLocalizations.translateWithContext(context, 'nav_home', defaultValue: 'Home')
              : _currentIndex == 2
                  ? AppLocalizations.translateWithContext(context, 'nav_wishes', defaultValue: 'Wishes')
                  : AppLocalizations.translateWithContext(context, 'nav_me', defaultValue: 'Me'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline_rounded, color: Colors.amber),
            tooltip: 'Improve Karma Grid',
            onPressed: () {
              final screenNames = ['DashboardScreen', 'SizedBox', 'WishBoardScreen', 'WalletScreen'];
              FeedbackModal.show(context, screenNames[_currentIndex]);
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notifications',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            _showCreateBottomSheet(context);
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00B074),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 9,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: AppLocalizations.translateWithContext(context, 'nav_home', defaultValue: 'Home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_circle_outline_rounded),
            activeIcon: const Icon(Icons.add_circle_rounded),
            label: AppLocalizations.translateWithContext(context, 'nav_create', defaultValue: 'Create'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.auto_awesome_outlined),
            activeIcon: const Icon(Icons.auto_awesome),
            label: AppLocalizations.translateWithContext(context, 'nav_wishes', defaultValue: 'Wishes'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: AppLocalizations.translateWithContext(context, 'nav_me', defaultValue: 'Me'),
          ),
        ],
      ),
    );
  }

  void _showCreateBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLocalizations.translateWithContext(context, 'nav_create', defaultValue: 'Create & Contribute'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF00B074),
                    child: Icon(Icons.volunteer_activism, color: Colors.white),
                  ),
                  title: Text('🌱 ' + AppLocalizations.translateWithContext(context, 'nav_do_good', defaultValue: 'Do an Action'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Complete a verified Proof of Good activity'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.uploadProof);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.amber,
                    child: Icon(Icons.report_problem_outlined, color: Colors.white),
                  ),
                  title: Text('🔎 ' + AppLocalizations.translateWithContext(context, 'rep_title', defaultValue: 'Report a Problem'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Flag visible community, animal or environmental issues'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.reportAbuse);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: Icon(Icons.lightbulb_outline, color: Colors.white),
                  ),
                  title: const Text('💡 Add an Action Proposal', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Propose a new global leap-year action to the community'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.proposeAction);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
