import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hersh_karma/main.dart';
import 'package:hersh_karma/services/mock/mock_auth_service.dart';
import 'package:hersh_karma/services/mock/mock_karma_service.dart';
import 'package:hersh_karma/services/mock/mock_wallet_service.dart';
import 'package:hersh_karma/views/ecosystem/ecosystem_hub_screen.dart';

void main() {
  SharedPreferences.setMockInitialValues({});

  testWidgets('Ecosystem Hub UI & Interaction Test', (WidgetTester tester) async {
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

    // Settle Splash Screen and navigate to login
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Log in via Google / Gmail
    final googleLoginBtn = find.text('Continue with Google / Gmail');
    expect(googleLoginBtn, findsOneWidget);
    await tester.ensureVisible(googleLoginBtn);
    await tester.tap(googleLoginBtn);
    await tester.pumpAndSettle(const Duration(milliseconds: 1000));

    // Verify we are on DashboardScreen, find the Flywheel card launcher
    final flywheelLauncher = find.text('Unified Flywheel Hub');
    expect(flywheelLauncher, findsOneWidget);

    // Tap on the Flywheel card launcher
    await tester.ensureVisible(flywheelLauncher);
    await tester.tap(flywheelLauncher);
    await tester.pumpAndSettle();

    // Verify EcosystemHubScreen loaded
    expect(find.byType(EcosystemHubScreen), findsOneWidget);
    expect(find.text('THE 4-STEP ACTION LOOP'), findsOneWidget);
    expect(find.text('THE FLYWHEEL SYSTEM'), findsOneWidget);
    expect(find.text('🕸️ THE KARMA GRAPH'), findsOneWidget);
    expect(find.text('Permanent Community Waste Station'), findsOneWidget);
    expect(find.text('Area 100% Waste-Free for 90 Days'), findsOneWidget);
    expect(find.text('🧠 ASK THE COLLECTIVE INTELLIGENCE'), findsOneWidget);

    // Switch Query chip to "💧 Village Water Table"
    final waterTableChip = find.text('💧 Village Water Table');
    expect(waterTableChip, findsOneWidget);
    await tester.ensureVisible(waterTableChip);
    await tester.tap(waterTableChip);
    await tester.pumpAndSettle();

    // Check that the empirical dataset results updated
    expect(find.textContaining('3,120 rainwater harvesting'), findsOneWidget);

    // Find the Execute Verified Playbook button
    final executeBtn = find.text('Execute Verified Playbook');
    expect(executeBtn, findsOneWidget);
    await tester.ensureVisible(executeBtn);
    await tester.tap(executeBtn);
    await tester.pumpAndSettle();

    // Verify that we are navigated to the SubmitDeedScreen with prefilled preset
    expect(find.text('Attach Proof of Change (Required)'), findsOneWidget);
  });
}
