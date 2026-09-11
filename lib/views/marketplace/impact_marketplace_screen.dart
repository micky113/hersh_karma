import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';

class ImpactMarketplaceScreen extends StatefulWidget {
  const ImpactMarketplaceScreen({super.key});

  @override
  State<ImpactMarketplaceScreen> createState() => _ImpactMarketplaceScreenState();
}

class _ImpactMarketplaceScreenState extends State<ImpactMarketplaceScreen> {
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _marketplaceItems = [
    {
      'title': 'Solar Study Lamp for Rural Students',
      'category': 'Products',
      'emoji': '💡',
      'provider': 'SELCO Solar Social Enterprise',
      'price': '₹450 / unit',
      'impact': 'Provides 6 hours of clean lighting for evening study',
      'karmaReward': '+45 Karma',
      'color': Colors.amber,
      'badge': 'Verified Product',
    },
    {
      'title': 'Community Organic Composting Bin (100L)',
      'category': 'Products',
      'emoji': '🌱',
      'provider': 'Daily Dump Eco Solutions',
      'price': '₹1,200 / unit',
      'impact': 'Diverts 15 kg organic waste/week from city landfills',
      'karmaReward': '+120 Karma',
      'color': Colors.green,
      'badge': 'Zero Waste',
    },
    {
      'title': 'High School STEM & Coding Mentorship',
      'category': 'Mentoring',
      'emoji': '🧑‍🏫',
      'provider': 'Karma Mentorship Guild',
      'price': 'Free (Volunteer / 2 hrs/wk)',
      'impact': '1-on-1 career guidance for Tier-2/3 college aspirants',
      'karmaReward': '+80 Karma / session',
      'color': Colors.blue,
      'badge': 'Skill Share',
    },
    {
      'title': 'Environmental Legal & RTI Guidance',
      'category': 'Mentoring',
      'emoji': '⚖️',
      'provider': 'Civic Rights Action Forum',
      'price': 'Pro Bono Legal Aid',
      'impact': 'Empowers residents to report illegal industrial waste discharge',
      'karmaReward': '+150 Karma',
      'color': Colors.indigo,
      'badge': 'Civic Aid',
    },
    {
      'title': 'Urban Forestry & Rewilding Fellowship 2026',
      'category': 'Opportunities',
      'emoji': '🌳',
      'provider': 'SayTrees Environmental Trust',
      'price': 'Stipend ₹25,000 / mo',
      'impact': '6-month full-time immersion planting 50,000 native trees',
      'karmaReward': 'Level 4 Passport Badge',
      'color': Colors.teal,
      'badge': 'Fellowship',
    },
    {
      'title': 'Climate Tech & Data Analytics Internship',
      'category': 'Opportunities',
      'emoji': '📊',
      'provider': 'CleanAir Asia Initiative',
      'price': 'Stipend ₹18,000 / mo',
      'impact': 'Analyze real-time AQI sensors and public transport efficiency',
      'karmaReward': 'Level 4 Passport Badge',
      'color': Colors.purple,
      'badge': 'Internship',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredItems = _selectedCategory == 'All'
        ? _marketplaceItems
        : _marketplaceItems.where((e) => e['category'] == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🛍️ ', style: TextStyle(fontSize: 20)),
            Text(
              'Impact Marketplace & Opportunities',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Informative Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF00B074).withOpacity(isDark ? 0.2 : 0.08),
                border: Border.all(color: const Color(0xFF00B074).withOpacity(0.35)),
              ),
              child: Row(
                children: [
                  const Text('🛍️', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Impact Goods, Mentoring & Fellowships',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF00B074)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Empowering verified social innovators, students, and NGOs with real resources.',
                          style: TextStyle(fontSize: 10.5, color: isDark ? Colors.white70 : Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Category Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Products', 'Mentoring', 'Opportunities'].map((cat) {
                  final isSel = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat, style: const TextStyle(fontSize: 11.5)),
                      selected: isSel,
                      selectedColor: const Color(0xFF00B074).withOpacity(0.2),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Marketplace Items List
            ...filteredItems.map((item) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (item['color'] as Color).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(item['emoji'] as String, style: const TextStyle(fontSize: 24)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['title'] as String,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: (item['color'] as Color).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item['badge'] as String,
                                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: item['color'] as Color),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'By ${item['provider']}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item['impact'] as String,
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.grey.shade800),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['price'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              Text(item['karmaReward'] as String, style: const TextStyle(fontSize: 10, color: Color(0xFF00B074), fontWeight: FontWeight.w600)),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('🎉 Interested in "${item['title']}"! Connecting with provider...'),
                                  backgroundColor: const Color(0xFF00B074),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00B074),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Connect / Apply', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
