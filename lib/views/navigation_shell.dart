import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/routes/app_routes.dart';
import 'dashboard/dashboard_screen.dart';
import 'discover/discover_screen.dart';
import 'create/create_screen.dart';
import 'wishes/wish_board_screen.dart';
import 'profile/me_screen.dart';
import '../services/voice_service.dart';
import 'support/quick_feedback_modal.dart';
import 'support/language_hub_modal.dart';
import '../core/localization/app_localizations.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _currentIndex = 0;
  bool _firstLoad = true;

  final List<Widget> _screens = const [
    DashboardScreen(),
    DiscoverScreen(),
    CreateScreen(),
    WishBoardScreen(),
    MeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    if (_firstLoad) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        _currentIndex = args >= 0 && args < 5 ? args : 0;
      }
      _firstLoad = false;
    }

    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (!authProvider.isAuthenticated || user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final lang = authProvider.currentLanguage;
    final isRtl = AppLocalizations.isRtlLanguage(lang);

    if (user != null) {
      KarmaVoice.currentLanguage = user.preferredLanguage;
    }

    String getTitle(int index) {
      switch (index) {
        case 0:
          return AppLocalizations.translateWithContext(context, 'nav_home', defaultValue: 'Home');
        case 1:
          return AppLocalizations.translateWithContext(context, 'nav_discover', defaultValue: 'Discover');
        case 2:
          return AppLocalizations.translateWithContext(context, 'nav_create', defaultValue: 'Create');
        case 3:
          return AppLocalizations.translateWithContext(context, 'nav_wishes', defaultValue: 'Wishes');
        default:
          return AppLocalizations.translateWithContext(context, 'nav_me', defaultValue: 'Me');
      }
    }

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
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
          title: Text(getTitle(_currentIndex)),
          actions: [
            // Quick 10-second feedback action
            IconButton(
              icon: const Icon(Icons.rate_review_outlined, color: Color(0xFF00B074)),
              tooltip: AppLocalizations.translateWithContext(context, 'fb_button', defaultValue: 'Feedback (10s)'),
              onPressed: () => QuickFeedbackModal.show(context),
            ),
            // Language selector action
            IconButton(
              icon: const Icon(Icons.translate_rounded),
              tooltip: 'Change Language / भाषा',
              onPressed: () => LanguageHubModal.show(context),
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
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home, color: Color(0xFF00B074)),
              label: AppLocalizations.translateWithContext(context, 'nav_home', defaultValue: 'Home'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.explore_outlined),
              selectedIcon: const Icon(Icons.explore, color: Color(0xFF00B074)),
              label: AppLocalizations.translateWithContext(context, 'nav_discover', defaultValue: 'Discover'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.add_circle_outline),
              selectedIcon: const Icon(Icons.add_circle, color: Color(0xFF00B074)),
              label: AppLocalizations.translateWithContext(context, 'nav_create', defaultValue: 'Create'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.auto_awesome_outlined),
              selectedIcon: const Icon(Icons.auto_awesome, color: Color(0xFF00B074)),
              label: AppLocalizations.translateWithContext(context, 'nav_wishes', defaultValue: 'Wishes'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person, color: Color(0xFF00B074)),
              label: AppLocalizations.translateWithContext(context, 'nav_me', defaultValue: 'Me'),
            ),
          ],
        ),
      ),
    );
  }
}
