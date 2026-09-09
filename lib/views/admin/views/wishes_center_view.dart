import 'package:flutter/material.dart';

class WishesCenterView extends StatelessWidget {
  const WishesCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final mockWishes = [
      {
        'title': 'Braille Textbooks for Blind Students',
        'creator': 'Ramesh Kumar (Teacher)',
        'category': 'Education 📚',
        'target': '300 KGC',
        'raised': '300 KGC (100%)',
        'status': 'READY FOR RETAILER PAYMENT',
        'retailer': 'National Association for the Blind (Verified Retailer)',
        'risk': 'Basic',
      },
      {
        'title': 'Wheelchair Ramp for Village School Entrance',
        'creator': 'Pooja Hegde (Gram Panchayat)',
        'category': 'Community 🏛️',
        'target': '800 KGC',
        'raised': '550 KGC (68%)',
        'status': 'MILESTONE 1 RELEASED',
        'retailer': 'Local Cement & Hardware Depot',
        'risk': 'Verified',
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
                  const Text('Wish Come True Oversight', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 2),
                  Text(
                    'Review wishes by risk tier: Basic ➔ Verified ➔ Enhanced Review. Funds routed directly to verified retailers.',
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
                itemCount: mockWishes.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final wish = mockWishes[i];

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('✨', style: TextStyle(fontSize: 20)),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            wish['title']!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            wish['status']!,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purple),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Creator: ${wish['creator']} • Category: ${wish['category']} • Target: ${wish['target']} • Retailer: ${wish['retailer']}',
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.grey.shade600),
                      ),
                    ),
                    trailing: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Wish details & direct vendor invoice verified.')),
                        );
                      },
                      child: const Text('Audit Retailer Invoice', style: TextStyle(fontSize: 11)),
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
