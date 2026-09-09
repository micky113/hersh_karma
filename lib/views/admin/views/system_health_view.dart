import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/admin/system_health.dart';
import '../../../providers/admin_provider.dart';

class SystemHealthView extends StatelessWidget {
  const SystemHealthView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final admin = Provider.of<AdminProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('System Service Health & Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 2),
                  Text(
                    'Real-time health status for Firebase Auth, AI screening, Storage, 22-language translation engine & TTS.',
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: admin.systemMetrics.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final s = admin.systemMetrics[i];

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 20),
                    ),
                    title: Row(
                      children: [
                        Text(s.serviceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('HEALTHY', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.green)),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Category: ${s.category} • Latency: ${s.latencyMs}ms • Uptime: ${s.uptimePercentage}% • Details: ${s.details}',
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.grey.shade600),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
