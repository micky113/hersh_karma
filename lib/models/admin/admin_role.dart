enum AdminRole {
  superAdmin,
  verificationAdmin,
  trustAndSafety,
  organizationReviewer,
  contentModerator,
  support,
  analytics
}

extension AdminRoleExtension on AdminRole {
  String get label {
    switch (this) {
      case AdminRole.superAdmin:
        return 'Super Admin 👑';
      case AdminRole.verificationAdmin:
        return 'Verification Admin 🛡️';
      case AdminRole.trustAndSafety:
        return 'Trust & Safety 🚨';
      case AdminRole.organizationReviewer:
        return 'Org Reviewer 🤝';
      case AdminRole.contentModerator:
        return 'Content Moderator ⚖️';
      case AdminRole.support:
        return 'Support Agent 💬';
      case AdminRole.analytics:
        return 'Analytics / Observer 📊';
    }
  }

  String get description {
    switch (this) {
      case AdminRole.superAdmin:
        return 'Full governance oversight, permission management & methodology changes.';
      case AdminRole.verificationAdmin:
        return 'Reviews before/after evidence, high-impact claims & verification appeals.';
      case AdminRole.trustAndSafety:
        return 'Anti-gaming firewall oversight, fraud detection & user restriction management.';
      case AdminRole.organizationReviewer:
        return 'Reviews and approves KYC and credentials for NGOs, Schools & Corporates.';
      case AdminRole.contentModerator:
        return 'Moderates wishes, community problem reports, comments & user images.';
      case AdminRole.support:
        return 'Handles contributor inquiries, dispute resolution & feedback triage.';
      case AdminRole.analytics:
        return 'Read-only access to ecosystem metrics, geographic impact & performance.';
    }
  }

  bool canVerifyActions() {
    return this == AdminRole.superAdmin || this == AdminRole.verificationAdmin;
  }

  bool canManageFraud() {
    return this == AdminRole.superAdmin || this == AdminRole.trustAndSafety;
  }

  bool canVerifyOrganizations() {
    return this == AdminRole.superAdmin || this == AdminRole.organizationReviewer;
  }

  bool canModerateContent() {
    return this == AdminRole.superAdmin || this == AdminRole.contentModerator || this == AdminRole.support;
  }

  bool canAdjustKarma() {
    return this == AdminRole.superAdmin; // Only Super Admin with mandatory audit reason
  }

  bool canManageRoles() {
    return this == AdminRole.superAdmin;
  }

  bool canEditLanguages() {
    return this == AdminRole.superAdmin || this == AdminRole.contentModerator || this == AdminRole.support;
  }

  bool isReadOnly() {
    return this == AdminRole.analytics;
  }
}
