import 'package:flutter/material.dart';

class ActionRegistryView extends StatelessWidget {
  const ActionRegistryView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final registeredActions = [
      {
        'title': 'Plastic Waste Segregation & Drive',
        'category': 'Environment 🌱',
        'credits': '50 - 250 KGC',
        'status': 'OFFICIAL VERIFIED',
        'evidence': 'Before/After Photos + Geo',
        'gamingRisk': 'Low (Firewall duplicate check active)',
      },
      {
        'title': 'Stray Animal Food & Water Bowl',
        'category': 'Animal Welfare 🐾',
        'credits': '40 KGC',
        'status': 'OFFICIAL VERIFIED',
        'evidence': 'Before/After Photos + Witness',
        'gamingRisk': 'Low (Daily Diminishing Returns)',
      },
      {
        'title': 'Community Skill Mentoring Hour',
        'category': 'Human Kindness 🤝',
        'credits': '100 KGC',
        'status': 'COMMUNITY PROPOSED (APPROVED)',
        'evidence': 'Anonymized QR Receipt Code',
        'gamingRisk': 'Medium (Requires Attendee Confirmation)',
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
                  const Text('Action Taxonomy & Registry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 2),
                  Text(
                    'Manage 367+ actions & community proposals: review impact, safety, duplicate potential & gaming risk.',
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
                itemCount: registeredActions.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final item = registeredActions[i];

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF00B074),
                      child: Icon(Icons.eco_rounded, color: Colors.white, size: 20),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['title']!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00B074).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item['status']!,
                            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF00B074)),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Category: ${item['category']} • Reward: ${item['credits']} • Evidence: ${item['evidence']} • Anti-Gaming: ${item['gamingRisk']}',
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
