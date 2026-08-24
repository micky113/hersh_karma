import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hersh_karma/main.dart';
import 'package:hersh_karma/services/mock/mock_auth_service.dart';
import 'package:hersh_karma/services/mock/mock_karma_service.dart';
import 'package:hersh_karma/services/mock/mock_wallet_service.dart';

void main() {
  SharedPreferences.setMockInitialValues({});

  testWidgets('App boots smoke test', (WidgetTester tester) async {
    final mockAuth = MockAuthService();
    final mockKarma = MockKarmaService(mockAuth);
    final mockWallet = MockWalletService(mockAuth);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      HershKarmaApp(
        authRepository: mockAuth,
        karmaRepository: mockKarma,
        walletRepository: mockWallet,
      ),
    );

    // Wait for the splash screen timer to complete and settle transitions
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byType(HershKarmaApp), findsOneWidget);
  });

  testWidgets('Navigation route flow smoke test', (WidgetTester tester) async {
    final mockAuth = MockAuthService();
    final mockKarma = MockKarmaService(mockAuth);
    final mockWallet = MockWalletService(mockAuth);

    await tester.pumpWidget(
      HershKarmaApp(
        authRepository: mockAuth,
        karmaRepository: mockKarma,
        walletRepository: mockWallet,
      ),
    );

    // 1. Splash Screen boots, waits 2s, transitions to LoginScreen
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Access Passport'), findsOneWidget);

    // 2. Perform Quick Login (John Doe)
    final johnLoginBtn = find.text('John Doe (User)');
    expect(johnLoginBtn, findsOneWidget);
    await tester.ensureVisible(johnLoginBtn);
    await tester.tap(johnLoginBtn);
    await tester.pumpAndSettle(const Duration(milliseconds: 1000)); // wait for mock auth login lag

    // Should transition to NavigationShell
    expect(find.text('Karma Passport'), findsOneWidget);

    // 3. Click Profile Detail Icon in AppBar leading
    final leadingProfile = find.byKey(const Key('appbar_profile_avatar'));
    expect(leadingProfile, findsOneWidget);
    await tester.tap(leadingProfile);
    await tester.pumpAndSettle();

    // Verify Profile Detail screen loaded
    expect(find.text('Karma Legacy Profile'), findsOneWidget);

    // Go back
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Karma Passport'), findsOneWidget);

    // 4. Click Settings Icon in AppBar actions
    final settingsIcon = find.byIcon(Icons.settings_outlined);
    expect(settingsIcon, findsOneWidget);
    await tester.tap(settingsIcon);
    await tester.pumpAndSettle();

    // Verify Settings screen loaded
    expect(find.text('Settings'), findsOneWidget);

    // 5. Perform Logout
    final logoutTile = find.text('Logout Passport');
    expect(logoutTile, findsOneWidget);
    await tester.ensureVisible(logoutTile);
    await tester.tap(logoutTile);
    await tester.pumpAndSettle();

    // Should return to LoginScreen
    expect(find.text('Access Passport'), findsOneWidget);
  });
}
