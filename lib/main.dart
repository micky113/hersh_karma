import 'package:flutter/material.dart';
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
import 'services/mock/mock_auth_service.dart';
import 'services/mock/mock_karma_service.dart';
import 'services/mock/mock_wallet_service.dart';
import 'views/auth/login_screen.dart';
import 'views/navigation_shell.dart';
import 'services/voice_service.dart';
import 'core/routes/app_routes.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }

  // Create singletons of mock services for offline persistence
  final mockAuthService = MockAuthService();
  final mockKarmaService = MockKarmaService(mockAuthService);
  final mockWalletService = MockWalletService(mockAuthService);

  runApp(
    HershKarmaApp(
      authRepository: mockAuthService,
      karmaRepository: mockKarmaService,
      walletRepository: mockWalletService,
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
