import 'package:flutter/material.dart';

class NGOsScreen extends StatelessWidget {
  const NGOsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Map<String, String>> ngos = [
      {
        'name': 'Clean Oceans Fund',
        'desc': 'Organizes localized marine plastic extractions and coral planting drives globally.',
        'impact': '450 tonnes extracted',
        'address': '0xOCEAN32...849'
      },
      {
        'name': 'Wild Animal Shelter',
        'desc': 'Provides veterinary care, feed, and sanctuary shelter for injured street dogs and birds.',
        'impact': '1,200 animals fed',
        'address': '0xANIMAL74...329'
      },
      {
        'name': 'Global Literacy Initiative',
        'desc': 'Builds libraries and open-source flutter bootcamps for community schools.',
        'impact': '85 bootcamps complete',
        'address': '0xSCHOOL92...112'
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Partner NGO Registry')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: ngos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = ngos[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['impact']!,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: theme.colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(item['desc']!, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'EVM Addr: ${item['address']}',
                        style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.blueGrey),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Address copied: ${item['address']}'),
                              backgroundColor: const Color(0xFF00B074),
                            ),
                          );
                        },
                        child: const Text('Copy Address', style: TextStyle(fontSize: 11)),
                      ),
                    ],
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
