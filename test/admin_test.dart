import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hersh_karma/models/admin/admin_role.dart';
import 'package:hersh_karma/models/admin/fraud_alert.dart';
import 'package:hersh_karma/models/karma_action.dart';
import 'package:hersh_karma/models/community_problem.dart';
import 'package:hersh_karma/providers/admin_provider.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Karma Grid — Admin & Trust Center Tests', () {
    late AdminProvider adminProvider;

    setUp(() {
      adminProvider = AdminProvider();
    });

    test('Should initialize with Super Admin role and populated command center queues', () {
      expect(adminProvider.currentAdmin.role, equals(AdminRole.superAdmin));
      expect(adminProvider.highRiskVerificationCount, greaterThan(0));
      expect(adminProvider.pendingReportsCount, greaterThan(0));
      expect(adminProvider.pendingOrgApplicationsCount, greaterThan(0));
      expect(adminProvider.systemMetrics.length, equals(5));
    });

    test('Should enforce mandatory justification reason for approving deed verification', () async {
      final pendingAction = adminProvider.verificationQueue.firstWhere((a) => a.status == DeedStatus.pending);
      
      final success = await adminProvider.approveActionVerification(
        pendingAction.id,
        reason: 'Geotag matched Sabarmati bank and 45kg plastics cleared.',
      );

      expect(success, isTrue);

      final updated = adminProvider.verificationQueue.firstWhere((a) => a.id == pendingAction.id);
      expect(updated.status, equals(DeedStatus.verified));

      // Verify audit log generated
      final latestLog = adminProvider.auditLogs.first;
      expect(latestLog.actionCategory, equals('verification'));
      expect(latestLog.targetId, equals(pendingAction.id));
      expect(latestLog.reason, contains('Sabarmati bank'));
      expect(latestLog.adminRole, equals(AdminRole.superAdmin));
    });

    test('Should block unauthorized role from approving verifications (Least Privilege)', () async {
      adminProvider.switchAdminRole(AdminRole.analytics);
      expect(adminProvider.currentRole.canVerifyActions(), isFalse);

      final pendingAction = adminProvider.verificationQueue.firstWhere((a) => a.status == DeedStatus.pending);

      expect(
        () => adminProvider.approveActionVerification(pendingAction.id, reason: 'Test unauthorized'),
        throwsA(isA<Exception>()),
      );
    });

    test('Should resolve fraud alert with penalty and record in immutable audit log', () async {
      final alert = adminProvider.fraudAlerts.firstWhere((a) => a.status == FraudStatus.pendingReview);

      final success = await adminProvider.resolveFraudAlert(
        alert.id,
        FraudStatus.penalized,
        reason: 'Confirmed duplicate image hash matching deed_mumbai_04.',
      );

      expect(success, isTrue);

      final resolvedAlert = adminProvider.fraudAlerts.firstWhere((a) => a.id == alert.id);
      expect(resolvedAlert.status, equals(FraudStatus.penalized));
      expect(resolvedAlert.resolutionReason, contains('duplicate image hash'));

      final latestLog = adminProvider.auditLogs.first;
      expect(latestLog.actionCategory, equals('fraud_resolution'));
      expect(latestLog.targetId, equals(alert.id));
    });

    test('Should enforce mandatory justification and Super Admin authorization for Karma adjustments', () async {
      final user = adminProvider.usersList.first;
      final initialKarma = user.karmaCredits;

      // 1. Empty reason should throw
      expect(
        () => adminProvider.adjustUserKarma(user.id, 50, reason: '   '),
        throwsA(isA<Exception>()),
      );

      // 2. Valid adjustment with mandatory reason
      final success = await adminProvider.adjustUserKarma(
        user.id,
        50,
        reason: 'Granted retroactive community cleanup bonus for city-wide drive.',
      );

      expect(success, isTrue);
      final updatedUser = adminProvider.usersList.firstWhere((u) => u.id == user.id);
      expect(updatedUser.karmaCredits, equals(initialKarma + 50));

      final log = adminProvider.auditLogs.first;
      expect(log.actionCategory, equals('karma_adjustment'));
      expect(log.reason, contains('retroactive community cleanup bonus'));
    });

    test('Should transition community problem report status with logged reason', () async {
      final report = adminProvider.problemReports.first;

      final success = await adminProvider.updateReportStatus(
        report.id,
        ProblemStatus.assigned,
        assignedResolver: 'Bengaluru Municipal Corporation (Ward 4)',
        reason: 'Dispatched civic repair crew to restore streetlights.',
      );

      expect(success, isTrue);
      final updated = adminProvider.problemReports.firstWhere((p) => p.id == report.id);
      expect(updated.status, equals(ProblemStatus.assigned));
      expect(updated.resolverName, contains('Bengaluru Municipal Corporation'));
    });

    test('Should verify Organization KYC with audit logging', () async {
      final schoolOrg = adminProvider.usersList.firstWhere((u) => u.id == 'user_school');
      expect(schoolOrg.isOrgVerified, isFalse);

      final success = await adminProvider.setOrganizationVerification(
        schoolOrg.id,
        true,
        reason: 'Verified educational institution registration certificate & tax compliance.',
      );

      expect(success, isTrue);
      final updated = adminProvider.usersList.firstWhere((u) => u.id == schoolOrg.id);
      expect(updated.isOrgVerified, isTrue);

      final log = adminProvider.auditLogs.first;
      expect(log.actionCategory, equals('org_approval'));
      expect(log.reason, contains('educational institution registration certificate'));
    });
  });
}
