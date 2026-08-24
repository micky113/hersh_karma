import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Map<String, String>> leaders = [
      {'rank': '1', 'name': 'Sarah Jenkins', 'credits': '1240 CR', 'badge': '👑 Top Tree Planter'},
      {'rank': '2', 'name': 'Alex Rivera', 'credits': '980 CR', 'badge': '🐕 Animal Savior'},
      {'rank': '3', 'name': 'John Doe (You)', 'credits': '200 CR', 'badge': '🌱 Green Citizen'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Global Leaderboards')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.primary.withOpacity(0.08),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPodium('Sarah J.', '1st', '1.2k', theme),
                _buildPodium('Alex R.', '2nd', '980', theme, scale: 0.9),
                _buildPodium('You', '3rd', '200', theme, scale: 0.8),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: leaders.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = leaders[index];
                return ListTile(
                  leading: Text(
                    '#${item['rank']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  title: Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item['badge']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  trailing: Text(
                    item['credits']!,
                    style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(String name, String rank, String score, ThemeData theme, {double scale = 1.0}) {
    return Transform.scale(
      scale: scale,
      child: Column(
        children: [
          CircleAvatar(radius: 28, child: Text(name[0])),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$rank • $score',
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
