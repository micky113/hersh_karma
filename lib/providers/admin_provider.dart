import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin/admin_role.dart';
import '../models/admin/admin_user.dart';
import '../models/admin/admin_audit_log.dart';
import '../models/admin/fraud_alert.dart';
import '../models/admin/system_health.dart';
import '../models/karma_action.dart';
import '../models/karma_category.dart';
import '../models/community_problem.dart';
import '../models/wish.dart';
import '../models/user_profile.dart';
import '../models/app_feedback.dart';

class AdminProvider extends ChangeNotifier {
  AdminUser _currentAdmin = AdminUser(
    id: 'admin_master_01',
    email: 'governance@karma.org',
    name: 'Hersh Sharma',
    role: AdminRole.superAdmin,
    department: 'Trust, Ethics & Oversight',
    lastLogin: DateTime.now(),
  );

  final List<AdminAuditLogEntry> _auditLogs = [];
  final List<FraudAlert> _fraudAlerts = [];
  final List<KarmaAction> _verificationQueue = [];
  final List<CommunityProblem> _problemReports = [];
  final List<Wish> _wishesQueue = [];
  final List<UserProfile> _usersList = [];
  final List<AppFeedback> _feedbackList = [];

  AdminUser get currentAdmin => _currentAdmin;
  AdminRole get currentRole => _currentAdmin.role;

  List<AdminAuditLogEntry> get auditLogs => List.unmodifiable(_auditLogs);
  List<FraudAlert> get fraudAlerts => List.unmodifiable(_fraudAlerts);
  List<KarmaAction> get verificationQueue => List.unmodifiable(_verificationQueue);
  List<CommunityProblem> get problemReports => List.unmodifiable(_problemReports);
  List<Wish> get wishesQueue => List.unmodifiable(_wishesQueue);
  List<UserProfile> get usersList => List.unmodifiable(_usersList);
  List<AppFeedback> get feedbackList => List.unmodifiable(_feedbackList);

  AdminProvider() {
    _seedInitialAdminData();
    _loadPersistedAuditLogs();
  }

  // --- Role Switching (for demonstration & RBAC audit testing) ---
  void switchAdminRole(AdminRole newRole) {
    _currentAdmin = _currentAdmin.copyWith(
      role: newRole,
      name: '${_currentAdmin.name.split(' ')[0]} (${newRole.label.split(' ')[0]})',
    );
    _logAudit(
      actionCategory: 'role_change',
      actionDescription: 'Switched active admin role context to ${newRole.name}',
      targetId: _currentAdmin.id,
      targetType: 'admin_user',
      reason: 'Admin workspace role switch for least-privilege verification',
    );
    notifyListeners();
  }

  // --- Command Center Alert Counts ---
  int get highRiskVerificationCount =>
      _fraudAlerts.where((a) => a.status == FraudStatus.pendingReview && (a.severity == FraudSeverity.high || a.severity == FraudSeverity.critical)).length;

  int get pendingReportsCount =>
      _problemReports.where((p) => p.status == ProblemStatus.reported || p.status == ProblemStatus.underReview).length;

  int get pendingOrgApplicationsCount =>
      _usersList.where((u) => (u.role == UserRole.ngo || u.role == UserRole.institution || u.role == UserRole.corporate) && !u.isOrgVerified).length;

  int get autoVerifiedAuditCount =>
      _verificationQueue.where((a) => a.evidenceScore >= 90 && a.status == DeedStatus.verified).length;

  int get newFeedbackCount =>
      _feedbackList.where((f) => f.status == FeedbackStatus.suggested).length;

  // --- 1. VERIFICATION ACTIONS ---
  Future<bool> approveActionVerification(String actionId, {required String reason}) async {
    if (!_currentAdmin.role.canVerifyActions()) {
      throw Exception('Unauthorized: Current role cannot approve verifications.');
    }
    final index = _verificationQueue.indexWhere((a) => a.id == actionId);
    if (index == -1) return false;

    final oldAction = _verificationQueue[index];
    final updated = oldAction.copyWith(
      status: DeedStatus.verified,
      creditsAwarded: oldAction.creditsAwarded > 0 ? oldAction.creditsAwarded : (oldAction.scale * 50),
    );
    _verificationQueue[index] = updated;

    _logAudit(
      actionCategory: 'verification',
      actionDescription: 'Approved Proof of Good deed: "${oldAction.title}"',
      targetId: actionId,
      targetType: 'action',
      reason: reason,
      previousState: {'status': oldAction.status.name, 'credits': oldAction.creditsAwarded},
      newState: {'status': updated.status.name, 'credits': updated.creditsAwarded},
    );

    notifyListeners();
    return true;
  }

  Future<bool> rejectActionVerification(String actionId, {required String reason}) async {
    if (!_currentAdmin.role.canVerifyActions()) {
      throw Exception('Unauthorized: Current role cannot reject verifications.');
    }
    final index = _verificationQueue.indexWhere((a) => a.id == actionId);
    if (index == -1) return false;

    final oldAction = _verificationQueue[index];
    final updated = oldAction.copyWith(status: DeedStatus.rejected);
    _verificationQueue[index] = updated;

    _logAudit(
      actionCategory: 'verification',
      actionDescription: 'Rejected Proof of Good deed: "${oldAction.title}"',
      targetId: actionId,
      targetType: 'action',
      reason: reason,
      previousState: {'status': oldAction.status.name},
      newState: {'status': updated.status.name},
    );

    notifyListeners();
    return true;
  }

  // --- 2. REPORT ACTIONS ---
  Future<bool> updateReportStatus(String reportId, ProblemStatus newStatus, {required String reason, String? assignedResolver}) async {
    if (!_currentAdmin.role.canModerateContent()) {
      throw Exception('Unauthorized: Current role cannot moderate reports.');
    }
    final index = _problemReports.indexWhere((p) => p.id == reportId);
    if (index == -1) return false;

    final oldReport = _problemReports[index];
    final updated = oldReport.copyWith(
      status: newStatus,
      resolverName: assignedResolver ?? oldReport.resolverName,
    );
    _problemReports[index] = updated;

    _logAudit(
      actionCategory: 'problem_report',
      actionDescription: 'Updated status of report "${oldReport.title}" to ${newStatus.name}',
      targetId: reportId,
      targetType: 'problem_report',
      reason: reason,
      previousState: {'status': oldReport.status.name},
      newState: {'status': updated.status.name, 'resolver': updated.resolverName},
    );

    notifyListeners();
    return true;
  }

  // --- 3. ORGANIZATION KYC & USER TRUST ACTIONS ---
  Future<bool> setOrganizationVerification(String userId, bool isVerified, {required String reason}) async {
    if (!_currentAdmin.role.canVerifyOrganizations()) {
      throw Exception('Unauthorized: Current role cannot verify organizations.');
    }
    final index = _usersList.indexWhere((u) => u.id == userId);
    if (index == -1) return false;

    final oldUser = _usersList[index];
    final updated = oldUser.copyWith(isOrgVerified: isVerified);
    _usersList[index] = updated;

    _logAudit(
      actionCategory: 'org_approval',
      actionDescription: '${isVerified ? "Approved & Verified" : "Revoked Verification for"} organization: ${oldUser.name}',
      targetId: userId,
      targetType: 'organization',
      reason: reason,
      previousState: {'isOrgVerified': oldUser.isOrgVerified},
      newState: {'isOrgVerified': isVerified},
    );

    notifyListeners();
    return true;
  }

  Future<bool> adjustUserTrustScore(String userId, double newTrust, {required String reason}) async {
    if (!_currentAdmin.role.canManageFraud()) {
      throw Exception('Unauthorized: Current role cannot adjust trust scores.');
    }
    final index = _usersList.indexWhere((u) => u.id == userId);
    if (index == -1) return false;

    final oldUser = _usersList[index];
    final updated = oldUser.copyWith(trustScore: newTrust.clamp(0.0, 1.0));
    _usersList[index] = updated;

    _logAudit(
      actionCategory: 'trust_adjustment',
      actionDescription: 'Adjusted trust score for ${oldUser.name} from ${(oldUser.trustScore * 100).toInt()}% to ${(newTrust * 100).toInt()}%',
      targetId: userId,
      targetType: 'user',
      reason: reason,
      previousState: {'trustScore': oldUser.trustScore},
      newState: {'trustScore': newTrust},
    );

    notifyListeners();
    return true;
  }

  // --- 4. AUDITABLE MANUAL KARMA ADJUSTMENTS ---
  Future<bool> adjustUserKarma(String userId, int karmaDelta, {required String reason}) async {
    if (!_currentAdmin.role.canAdjustKarma()) {
      throw Exception('Unauthorized: Only Super Admin can adjust Karma balances.');
    }
    if (reason.trim().isEmpty) {
      throw Exception('Audit Constraint: Mandatory justification reason is required for any Karma adjustment.');
    }

    final index = _usersList.indexWhere((u) => u.id == userId);
    if (index == -1) return false;

    final oldUser = _usersList[index];
    final updated = oldUser.copyWith(karmaCredits: (oldUser.karmaCredits + karmaDelta).clamp(0, 999999));
    _usersList[index] = updated;

    _logAudit(
      actionCategory: 'karma_adjustment',
      actionDescription: 'Manual Karma adjustment (${karmaDelta >= 0 ? "+$karmaDelta" : "$karmaDelta"} Credits) for ${oldUser.name}',
      targetId: userId,
      targetType: 'user',
      reason: reason,
      previousState: {'karmaCredits': oldUser.karmaCredits},
      newState: {'karmaCredits': updated.karmaCredits},
    );

    notifyListeners();
    return true;
  }

  // --- 5. FRAUD ALERT RESOLUTION ---
  Future<bool> resolveFraudAlert(String alertId, FraudStatus newStatus, {required String reason}) async {
    if (!_currentAdmin.role.canManageFraud()) {
      throw Exception('Unauthorized: Current role cannot resolve fraud alerts.');
    }
    final index = _fraudAlerts.indexWhere((a) => a.id == alertId);
    if (index == -1) return false;

    final oldAlert = _fraudAlerts[index];
    final updated = oldAlert.copyWith(
      status: newStatus,
      resolutionReason: reason,
      resolvedByAdmin: _currentAdmin.name,
      resolvedAt: DateTime.now(),
    );
    _fraudAlerts[index] = updated;

    _logAudit(
      actionCategory: 'fraud_resolution',
      actionDescription: 'Resolved fraud alert "${oldAlert.title}" as ${newStatus.name}',
      targetId: alertId,
      targetType: 'fraud_alert',
      reason: reason,
      previousState: {'status': oldAlert.status.name},
      newState: {'status': newStatus.name},
    );

    notifyListeners();
    return true;
  }

  // --- 6. FEEDBACK TRIAGE ---
  void convertFeedbackToTask(String feedbackId, String taskCategory, {required String reason}) {
    final index = _feedbackList.indexWhere((f) => f.id == feedbackId);
    if (index != -1) {
      final f = _feedbackList[index];
      _logAudit(
        actionCategory: 'feedback_triage',
        actionDescription: 'Converted user feedback (${f.category.name}) on ${f.screenContext} into $taskCategory task',
        targetId: feedbackId,
        targetType: 'app_feedback',
        reason: reason,
      );
      notifyListeners();
    }
  }

  // --- SYSTEM HEALTH METRICS ---
  List<SystemServiceMetric> get systemMetrics => [
    SystemServiceMetric(
      serviceName: 'Firebase Auth & Identity Bridge',
      category: 'Core',
      status: ServiceStatus.healthy,
      latencyMs: 42,
      uptimePercentage: 99.98,
      details: 'Google OAuth Popup Bridge active & persistent tokens operational',
      lastChecked: DateTime.now(),
    ),
    SystemServiceMetric(
      serviceName: 'AI Evidence Screening Pipeline',
      category: 'AI & Vision',
      status: ServiceStatus.healthy,
      latencyMs: 180,
      uptimePercentage: 99.92,
      details: '100-Point Evidence Scorer, Image Hash & Travel Speed Firewall nominal',
      lastChecked: DateTime.now(),
    ),
    SystemServiceMetric(
      serviceName: 'Proof-of-Good Ledger & Storage',
      category: 'Storage',
      status: ServiceStatus.healthy,
      latencyMs: 58,
      uptimePercentage: 100.0,
      details: 'Firebase Storage & IndexedDB local replica synchronized',
      lastChecked: DateTime.now(),
    ),
    SystemServiceMetric(
      serviceName: 'India-First 22 Regional Languages & RTL Engine',
      category: 'Localization',
      status: ServiceStatus.healthy,
      latencyMs: 8,
      uptimePercentage: 100.0,
      details: '22 Eighth Schedule languages + RTL (Hebrew, Arabic, Urdu) compiled',
      lastChecked: DateTime.now(),
    ),
    SystemServiceMetric(
      serviceName: 'Talk to Karma TTS Speech Engine',
      category: 'Speech',
      status: ServiceStatus.healthy,
      latencyMs: 12,
      uptimePercentage: 99.95,
      details: 'Browser Speech Synthesis API & Voice Intent Router ready',
      lastChecked: DateTime.now(),
    ),
  ];

  // --- INTERNAL AUDIT LOGGING ---
  void _logAudit({
    required String actionCategory,
    required String actionDescription,
    required String targetId,
    required String targetType,
    required String reason,
    Map<String, dynamic> previousState = const {},
    Map<String, dynamic> newState = const {},
  }) async {
    final entry = AdminAuditLogEntry(
      id: 'audit_${DateTime.now().millisecondsSinceEpoch}_${_auditLogs.length + 1}',
      adminId: _currentAdmin.id,
      adminName: _currentAdmin.name,
      adminRole: _currentAdmin.role,
      actionCategory: actionCategory,
      actionDescription: actionDescription,
      targetId: targetId,
      targetType: targetType,
      reason: reason,
      previousState: previousState,
      newState: newState,
      timestamp: DateTime.now(),
    );

    _auditLogs.insert(0, entry);
    _persistAuditLogs();
  }

  Future<void> _persistAuditLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = _auditLogs.take(100).map((l) => l.toJson()).toList();
      await prefs.setString('admin_audit_logs_v1', jsonEncode(logsJson));
    } catch (_) {}
  }

  Future<void> _loadPersistedAuditLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('admin_audit_logs_v1');
      if (saved != null) {
        final List<dynamic> list = jsonDecode(saved);
        for (final item in list) {
          if (!_auditLogs.any((l) => l.id == item['id'])) {
            _auditLogs.add(AdminAuditLogEntry.fromJson(item));
          }
        }
      }
    } catch (_) {}
  }

  void _seedInitialAdminData() {
    // 1. Initial Fraud Alerts
    _fraudAlerts.addAll([
      FraudAlert(
        id: 'fraud_001',
        userId: 'user_rahul99',
        userName: 'Rahul Verma',
        deedId: 'deed_delhi_clean_91',
        alertType: 'duplicate_image_hash',
        title: 'Reused Beach Cleanup Photo',
        description: 'Uploaded image matches previous submission deed_mumbai_04 hash (98.6% match confidence).',
        riskScore: 0.95,
        severity: FraudSeverity.critical,
        status: FraudStatus.pendingReview,
        detectedAt: DateTime.now().subtract(const Duration(minutes: 24)),
        evidenceDetails: {'matchedDeedId': 'deed_mumbai_04', 'similarityScore': 0.986},
      ),
      FraudAlert(
        id: 'fraud_002',
        userId: 'user_fast_travel',
        userName: 'Vikram Singh',
        deedId: 'deed_speed_88',
        alertType: 'impossible_velocity',
        title: 'Impossible Travel Velocity (840 km/h)',
        description: 'Submission in Bengaluru recorded 14 minutes after submission in Kolkata (1,560 km distance).',
        riskScore: 0.88,
        severity: FraudSeverity.high,
        status: FraudStatus.pendingReview,
        detectedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 12)),
        evidenceDetails: {'speedKmH': 840.5, 'distanceKm': 1560},
      ),
      FraudAlert(
        id: 'fraud_003',
        userId: 'user_bot_farm',
        userName: 'Apex Bot Network',
        alertType: 'spam_reports',
        title: 'High Frequency Micro-Reports',
        description: '18 problem reports submitted within 3 minutes from the exact same device ID.',
        riskScore: 0.72,
        severity: FraudSeverity.medium,
        status: FraudStatus.investigating,
        detectedAt: DateTime.now().subtract(const Duration(hours: 3)),
        evidenceDetails: {'reportsCount': 18, 'timespanSec': 180},
      ),
    ]);

    // 2. Initial Verification Queue
    _verificationQueue.addAll([
      KarmaAction(
        id: 'verif_high_01',
        userId: 'user_priya',
        userName: 'Priya Patel',
        title: 'Riverbank Plastic Interception Drive',
        description: 'Extracted and sorted 45 kg of floating plastics from Sabarmati river edge with community team.',
        category: KarmaCategory.environment,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        latitude: 23.0225,
        longitude: 72.5714,
        scale: 15,
        verificationLevel: 3,
        evidenceScore: 88,
        beforeImageUrl: 'https://images.unsplash.com/photo-1618477461853-cf6ed80faba5',
        imageUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09',
        status: DeedStatus.pending,
        creditsAwarded: 450,
      ),
      KarmaAction(
        id: 'verif_high_02',
        userId: 'user_ananya',
        userName: 'Ananya Roy',
        title: 'Stray Animal Winter Shelter Construction',
        description: 'Constructed 4 weatherproof insulated dog houses using recycled wooden crates in North Kolkata.',
        category: KarmaCategory.animalWelfare,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        latitude: 22.5726,
        longitude: 88.3639,
        scale: 8,
        verificationLevel: 2,
        evidenceScore: 84,
        beforeImageUrl: 'https://images.unsplash.com/photo-1548767797-d8c844163c4c',
        imageUrl: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e',
        status: DeedStatus.pending,
        creditsAwarded: 300,
      ),
      KarmaAction(
        id: 'verif_auto_03',
        userId: 'user_rohit',
        userName: 'Rohit Gupta',
        title: 'Tree Sapling Planted (Neem Tree)',
        description: 'Planted native neem sapling in neighborhood community garden with tree guard.',
        category: KarmaCategory.environment,
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        latitude: 28.7041,
        longitude: 77.1025,
        scale: 1,
        verificationLevel: 1,
        evidenceScore: 94,
        beforeImageUrl: 'https://images.unsplash.com/photo-1513836279014-a89f7a76ae86',
        imageUrl: 'https://images.unsplash.com/photo-1448375240586-882707db888b',
        status: DeedStatus.verified,
        creditsAwarded: 75,
      ),
    ]);

    // 3. Problem Reports Queue
    _problemReports.addAll([
      CommunityProblem(
        id: 'prob_admin_01',
        reporterId: 'user_deepak',
        reporterName: 'Deepak Nair',
        title: 'Broken Streetlights on Ring Road Crossing',
        description: 'Dark junction causing severe safety hazard for pedestrians and two-wheelers at night.',
        category: KarmaCategory.humanKindness,
        latitude: 12.9716,
        longitude: 77.5946,
        beforeImageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23',
        status: ProblemStatus.reported,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      CommunityProblem(
        id: 'prob_admin_02',
        reporterId: 'user_neha',
        reporterName: 'Neha Deshmukh',
        title: 'Open Construction Waste Blocking Storm Drain',
        description: 'Concrete rubble and plastic bags clogging rainwater drain before monsoon.',
        category: KarmaCategory.environment,
        latitude: 19.0760,
        longitude: 72.8777,
        beforeImageUrl: 'https://images.unsplash.com/photo-1530587191325-3db32d826c18',
        status: ProblemStatus.underReview,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ]);

    // 4. Users & Orgs Registry
    _usersList.addAll([
      UserProfile(
        id: 'user_john',
        name: 'John Doe',
        email: 'john@karma.com',
        role: UserRole.individual,
        karmaCredits: 120,
        reputationScore: 65,
        trustScore: 0.92,
        verifiedSubmissions: 118,
      ),
      UserProfile(
        id: 'user_jane',
        name: 'Green Earth Foundation (NGO)',
        email: 'jane@karma.com',
        role: UserRole.ngo,
        karmaCredits: 450,
        reputationScore: 90,
        trustScore: 0.98,
        verifiedSubmissions: 62,
        isOrgVerified: true,
        peopleReached: 28400,
      ),
      UserProfile(
        id: 'user_school',
        name: 'Apex Academy (School)',
        email: 'school@karma.com',
        role: UserRole.institution,
        karmaCredits: 500,
        reputationScore: 85,
        trustScore: 0.95,
        verifiedSubmissions: 3800,
        isOrgVerified: false, // Pending KYC Application
        studentsCount: 640,
      ),
      UserProfile(
        id: 'user_corp',
        name: 'CSR TechCorp (Business)',
        email: 'corp@karma.com',
        role: UserRole.corporate,
        karmaCredits: 2500,
        reputationScore: 95,
        trustScore: 0.99,
        verifiedSubmissions: 37,
        isOrgVerified: false, // Pending KYC Application
        employeesCount: 2450,
      ),
    ]);

    // 5. Initial Audit Logs
    _auditLogs.addAll([
      AdminAuditLogEntry(
        id: 'audit_init_01',
        adminId: 'admin_master_01',
        adminName: 'Hersh Sharma',
        adminRole: AdminRole.superAdmin,
        actionCategory: 'system_init',
        actionDescription: 'Admin & Trust Center initialized with strict RBAC',
        targetId: 'system',
        targetType: 'governance_core',
        reason: 'Bootstrap system trust parameters and audit subsystem',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
  }
}
