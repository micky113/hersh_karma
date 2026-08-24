import 'package:flutter/material.dart';
import '../../views/auth/splash_screen.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/create_profile_screen.dart';
import '../../views/navigation_shell.dart';
import '../../views/dashboard/notifications_screen.dart';
import '../../views/feed/community_feed_screen.dart';
import '../../views/leaderboard/leaderboard_screen.dart';
import '../../views/profile/profile_detail_screen.dart';
import '../../views/submissions/upload_proof_screen.dart';
import '../../views/submissions/ai_status_screen.dart';
import '../../views/wallet/rewards_screen.dart';
import '../../views/wallet/ngos_screen.dart';
import '../../views/support/settings_screen.dart';
import '../../views/support/report_abuse_screen.dart';
import '../../views/support/help_screen.dart';
import '../../views/support/about_screen.dart';
import '../../views/missions/india_mission_screen.dart';
import '../../views/missions/signature_activities_screen.dart';
import '../../views/governance/propose_action_screen.dart';
import '../../views/governance/governance_screen.dart';
import '../../views/exchange/impact_exchange_screen.dart';
import '../../views/submissions/karma_firewall_screen.dart';
import '../../views/submissions/proof_capture_screen.dart';
import '../../views/wishes/wish_board_screen.dart';
import '../../views/wishes/make_wish_screen.dart';
import '../../views/wishes/wish_detail_screen.dart';
import '../../models/karma_category.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String createProfile = '/create-profile';
  static const String home = '/home';
  static const String notifications = '/notifications';
  static const String feed = '/feed';
  static const String leaderboard = '/leaderboard';
  static const String profileDetail = '/profile-detail';
  static const String uploadProof = '/upload-proof';
  static const String aiStatus = '/ai-status';
  static const String rewards = '/rewards';
  static const String ngos = '/ngos';
  static const String settings = '/settings';
  static const String reportAbuse = '/report-abuse';
  static const String help = '/help';
  static const String about = '/about';
  static const String indiaMission = '/india-mission';
  static const String signatureActivities = '/signature-activities';
  static const String proposeAction = '/propose-action';
  static const String governance = '/governance';
  static const String impactExchange = '/impact-exchange';
  static const String karmaFirewall = '/karma-firewall';
  static const String proofCapture = '/proof-capture';
  static const String wishes = '/wishes';
  static const String createWish = '/create-wish';
  static const String wishDetail = '/wish-detail';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (_) => const SplashScreen(),
      login: (_) => const LoginScreen(),
      createProfile: (_) => const CreateProfileScreen(),
      home: (_) => const NavigationShell(),
      notifications: (_) => const NotificationsScreen(),
      feed: (_) => const CommunityFeedScreen(),
      leaderboard: (_) => const LeaderboardScreen(),
      profileDetail: (_) => const ProfileDetailScreen(),
      uploadProof: (_) => const UploadProofScreen(),
      aiStatus: (_) => const AiStatusScreen(),
      rewards: (_) => const RewardsScreen(),
      ngos: (_) => const NGOsScreen(),
      settings: (_) => const SettingsScreen(),
      reportAbuse: (_) => const ReportAbuseScreen(),
      help: (_) => const HelpScreen(),
      about: (_) => const AboutScreen(),
      indiaMission: (_) => const IndiaMissionScreen(),
      signatureActivities: (_) => const SignatureActivitiesScreen(),
      proposeAction: (_) => const ProposeActionScreen(),
      governance: (_) => const GovernanceScreen(),
      impactExchange: (_) => const ImpactExchangeScreen(),
      karmaFirewall: (_) => const KarmaFirewallScreen(),
      proofCapture: (context) {
        final category = ModalRoute.of(context)!.settings.arguments as KarmaCategory? ?? KarmaCategory.environment;
        return ProofCaptureScreen(category: category);
      },
      wishes: (_) => const WishBoardScreen(),
      createWish: (_) => const MakeWishScreen(),
      wishDetail: (context) {
        final wishId = ModalRoute.of(context)!.settings.arguments as String;
        return WishDetailScreen(wishId: wishId);
      },
    };
  }
}
