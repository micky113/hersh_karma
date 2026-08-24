import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/routes/app_routes.dart';
import 'dashboard/dashboard_screen.dart';
import 'challenges/challenges_screen.dart';
import 'submissions/submit_deed_screen.dart';
import 'map/impact_map_screen.dart';
import 'verification/validator_screen.dart';
import 'wallet/wallet_screen.dart';

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
    const ChallengesScreen(),
    const SubmitDeedScreen(),
    const ImpactMapScreen(),
    const ValidatorScreen(),
    const WalletScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    if (_firstLoad) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        _currentIndex = args;
      }
      _firstLoad = false;
    }

    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentIndex == 0
                  ? 'Karma Passport'
                  : _currentIndex == 1
                      ? 'Karma Challenges'
                      : _currentIndex == 2
                          ? 'Submit Proof of Good'
                          : _currentIndex == 3
                              ? 'Impact Network Map'
                              : _currentIndex == 4
                                  ? 'Community Validator'
                                  : 'Decentralized Wallet',
            ),
          ],
        ),
        actions: [
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
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00B074),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 9,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.badge_outlined),
            activeIcon: Icon(Icons.badge_rounded),
            label: 'Passport',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stars_outlined),
            activeIcon: Icon(Icons.stars_rounded),
            label: 'Missions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline_rounded),
            activeIcon: Icon(Icons.add_circle_rounded),
            label: 'Submit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map_rounded),
            label: 'Impact Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user_outlined),
            activeIcon: Icon(Icons.verified_user_rounded),
            label: 'Validate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Wallet',
          ),
        ],
      ),
    );
  }
}
