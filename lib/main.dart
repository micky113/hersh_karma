import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/karma_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/governance_provider.dart';
import 'providers/admin_provider.dart';
import 'repositories/auth_repo.dart';
import 'repositories/karma_repo.dart';
import 'repositories/wallet_repo.dart';
import 'services/firebase/firebase_auth_service.dart';
import 'services/firebase/firebase_karma_service.dart';
import 'services/firebase/firebase_wallet_service.dart';
import 'services/mock/mock_auth_service.dart';
import 'services/mock/mock_karma_service.dart';
import 'services/mock/mock_wallet_service.dart';
import 'views/auth/login_screen.dart';
import 'views/navigation_shell.dart';
import 'services/voice_service.dart';
import 'core/routes/app_routes.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/config/ai_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AiConfig.initialize();

  bool firebaseReady = false;
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    firebaseReady = true;
    debugPrint('🔥 Firebase successfully initialized with project: ${DefaultFirebaseOptions.currentPlatform.projectId}');
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
    if (Firebase.apps.isNotEmpty || e.toString().contains('duplicate-app') || e.toString().contains('already exists')) {
      firebaseReady = true;
    }
  }

  // Always use Live Firebase services on Web and in production
  final AuthRepository authRepository;
  final KarmaRepository karmaRepository;
  final WalletRepository walletRepository;

  if (firebaseReady || kIsWeb) {
    authRepository = FirebaseAuthService();
    karmaRepository = FirebaseKarmaService();
    walletRepository = FirebaseWalletService();
    debugPrint('🚀 Running with LIVE Firebase Services (Firestore & Auth & Storage)');
  } else {
    final mockAuth = MockAuthService();
    authRepository = mockAuth;
    karmaRepository = MockKarmaService(mockAuth);
    walletRepository = MockWalletService(mockAuth);
    debugPrint('⚠️ Running with Mock Offline Services');
  }

  runApp(
    HershKarmaApp(
      authRepository: authRepository,
      karmaRepository: karmaRepository,
      walletRepository: walletRepository,
    ),
  );
}

class HershKarmaApp extends StatelessWidget {
  final AuthRepository authRepository;
  final KarmaRepository karmaRepository;
  final WalletRepository walletRepository;

  const HershKarmaApp({
    super.key,
    required this.authRepository,
    required this.karmaRepository,
    required this.walletRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authRepository),
        ),
        ChangeNotifierProxyProvider<AuthProvider, KarmaProvider>(
          create: (_) => KarmaProvider(karmaRepository),
          update: (_, auth, karma) => karma!..update(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, WalletProvider>(
          create: (_) => WalletProvider(walletRepository),
          update: (_, auth, wallet) => wallet!..updateUserId(auth.currentUser?.id),
        ),
        ChangeNotifierProvider<GovernanceProvider>(
          create: (_) => GovernanceProvider(),
        ),
        ChangeNotifierProvider<AdminProvider>(
          create: (_) => AdminProvider(),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final lang = auth.currentLanguage;
          final isRtl = AppLocalizations.isRtlLanguage(lang);
          final localeStr = AppLocalizations.getLocaleCode(lang);

          return MaterialApp(
            title: 'Proof of Good - Karma Credits',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            locale: Locale(localeStr),
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
            builder: (context, child) {
              return Directionality(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
