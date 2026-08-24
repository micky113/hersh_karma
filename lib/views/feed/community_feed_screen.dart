import 'package:flutter/material.dart';

class CommunityFeedScreen extends StatelessWidget {
  const CommunityFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Map<String, String>> mockFeed = [
      {
        'user': 'Alice Green',
        'badge': '🌱 Level 3',
        'deed': 'Organized Beach Cleanup',
        'desc': 'Collected 25kg of microplastics with 5 volunteers. The shore is pristine now!',
        'category': '🌱 Environment',
        'likes': '32',
      },
      {
        'user': 'Bob Shepherd',
        'badge': '🐕 Level 5',
        'deed': 'Rescued Stray Puppy',
        'desc': 'Found an injured puppy near Sector 4. Delivered to shelter and funded medical treatment.',
        'category': '🐕 Animal Welfare',
        'likes': '45',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Community Feed')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: mockFeed.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final post = mockFeed[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            child: Text(post['user']![0]),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(post['user']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(post['badge']!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          post['category']!,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(post['deed']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(post['desc']!, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 18),
                      const SizedBox(width: 4),
                      Text(post['likes']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.shield_outlined, size: 16),
                        label: const Text('Verify/Audit', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
