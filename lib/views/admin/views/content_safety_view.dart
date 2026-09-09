import 'package:flutter/material.dart';

class ContentSafetyView extends StatelessWidget {
  const ContentSafetyView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final moderationItems = [
      {
        'title': 'Community Problem Photo #901',
        'type': 'Image Evidence',
        'flagReason': 'Contains blurred facial imagery without consent',
        'status': 'PENDING REVIEW',
      },
      {
        'title': 'Wish Description #124',
        'type': 'Wish Text',
        'flagReason': 'Automated keyword safety filter triggered (Cash request blocked)',
        'status': 'AUTO-BLOCKED',
      },
    ];

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
                  const Text('Content & Community Safety', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 2),
                  Text(
                    'Moderate posts, comments, images, reports, and wishes with audit logs & appeals.',
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
                itemCount: moderationItems.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final item = moderationItems[i];

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('⚖️', style: TextStyle(fontSize: 20)),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(item['status']!, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Type: ${item['type']} • Trigger: ${item['flagReason']}',
                        style: TextStyle(fontSize: 11.5, color: isDark ? Colors.white60 : Colors.grey.shade600),
                      ),
                    ),
                    trailing: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Content flagged for review with audit note.')),
                        );
                      },
                      child: const Text('Review', style: TextStyle(fontSize: 11)),
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
