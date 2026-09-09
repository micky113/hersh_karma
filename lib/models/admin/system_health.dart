enum ServiceStatus {
  healthy,
  degraded,
  offline
}

class SystemServiceMetric {
  final String serviceName;
  final String category; // 'Core', 'AI & Vision', 'Storage', 'Localization', 'Speech'
  final ServiceStatus status;
  final int latencyMs;
  final double uptimePercentage;
  final String details;
  final DateTime lastChecked;

  const SystemServiceMetric({
    required this.serviceName,
    required this.category,
    required this.status,
    required this.latencyMs,
    required this.uptimePercentage,
    required this.details,
    required this.lastChecked,
  });
}
