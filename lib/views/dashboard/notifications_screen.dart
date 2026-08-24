import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> mockNotifications = [
      {
        'title': 'Saplings Verified! 🌱',
        'body': 'Your environment deed "Planted 5 Saplings" was approved by Jane Smith. +50 Karma credits awarded.',
        'time': '2 hours ago',
      },
      {
        'title': 'Reputation Upgraded! 🛡️',
        'body': 'Congratulations! Your community validator trust score rose to 67%. You now have higher vote weight.',
        'time': '1 day ago',
      },
      {
        'title': 'New Challenge Available 🏆',
        'body': 'A new campaign "Keep it Clean" is accepting validator and volunteer registrations.',
        'time': '3 days ago',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: mockNotifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = mockNotifications[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(item['time']!, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(item['body']!, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
