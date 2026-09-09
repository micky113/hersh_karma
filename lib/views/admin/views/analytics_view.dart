import 'package:flutter/material.dart';
import '../widgets/stat_card.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final regionalData = [
      {'region': 'Maharashtra (Mumbai & Pune)', 'actions': '1,420', 'karma': '28,400 KGC', 'topCategory': 'Environment 🌱'},
      {'region': 'Karnataka (Bengaluru & Mysuru)', 'actions': '980', 'karma': '19,600 KGC', 'topCategory': 'Human Kindness 🤝'},
      {'region': 'Delhi NCR', 'actions': '840', 'karma': '16,800 KGC', 'topCategory': 'Animal Welfare 🐾'},
      {'region': 'Gujarat (Ahmedabad & Surat)', 'actions': '560', 'karma': '11,200 KGC', 'topCategory': 'Environment 🌱'},
      {'region': 'West Bengal (Kolkata)', 'actions': '380', 'karma': '7,600 KGC', 'topCategory': 'Education 📚'},
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
                  const Text('India-First Regional Impact Analytics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 2),
                  Text(
                    'State and city breakdown with privacy-preserving geographic aggregation.',
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Regional Table
          Expanded(
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: regionalData.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final reg = regionalData[i];

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B074).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('🇮🇳', style: TextStyle(fontSize: 20)),
                    ),
                    title: Text(reg['region']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    subtitle: Text('Top Category: ${reg['topCategory']}', style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.grey.shade600)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${reg['actions']} Deeds', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(width: 14),
                        Text(reg['karma']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF00B074))),
                      ],
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
