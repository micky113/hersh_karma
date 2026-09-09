import 'package:flutter/material.dart';

class FeedbackView extends StatelessWidget {
  const FeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final feedbacks = [
      {
        'rating': '👍 Good',
        'screen': 'DashboardScreen',
        'language': 'Hindi',
        'comment': 'बहुत आसान है। फोटो अपलोड करने में कोई दिक्कत नहीं हुई।',
        'time': '12m ago',
      },
      {
        'rating': '💡 Idea',
        'screen': 'UploadProofScreen',
        'language': 'English',
        'comment': 'Can we have an auto-detect button for nearby garbage spots?',
        'time': '1h ago',
      },
      {
        'rating': '🐛 Problem',
        'screen': 'UniversalSearchScreen',
        'language': 'Tamil',
        'comment': 'Keyboard covering search suggestions on small screens.',
        'time': '3h ago',
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
                  const Text('10-Second Feedback & Improvement Triage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 2),
                  Text(
                    'Categorize user feedback by screen, language, user type and convert useful ideas into improvement tasks.',
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
                itemCount: feedbacks.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final f = feedbacks[i];

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('💬', style: TextStyle(fontSize: 20)),
                    ),
                    title: Row(
                      children: [
                        Text(f['rating']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                        const SizedBox(width: 8),
                        Text('• ${f['screen']}', style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                        const Spacer(),
                        Text(f['time']!, style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '"${f['comment']}" (Language: ${f['language']})',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey.shade800),
                      ),
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B074),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Feedback converted to improvement task for ${f['screen']}')),
                        );
                      },
                      child: const Text('Convert to Task', style: TextStyle(fontSize: 11)),
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
