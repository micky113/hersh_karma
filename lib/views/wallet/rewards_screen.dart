import 'package:flutter/material.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Map<String, String>> rewardItems = [
      {'title': 'Public Transit Credit 🚌', 'cost': '1.0 PoG', 'desc': 'Redeem for 10 rides on metropolitan buses/trains.'},
      {'title': 'Eco Soap Package 🧼', 'cost': '1.5 PoG', 'desc': 'Organic zero-waste soap delivered to your address.'},
      {'title': 'Permaculture Course 📚', 'cost': '2.0 PoG', 'desc': 'Unlock a 5-hour video tutorial on home garden design.'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Karma Marketplace')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: rewardItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = rewardItems[index];
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB300).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['cost']!,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFFFB300)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item['desc']!, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Voucher minted! Show QR code to redeem "${item['title']}".'),
                          backgroundColor: const Color(0xFF00B074),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 36),
                      backgroundColor: theme.colorScheme.secondary,
                    ),
                    child: const Text('Redeem Voucher', style: TextStyle(fontSize: 12, color: Colors.black87)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
