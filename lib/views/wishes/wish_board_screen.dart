import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/karma_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../models/wish.dart';

class WishBoardScreen extends StatefulWidget {
  const WishBoardScreen({super.key});

  @override
  State<WishBoardScreen> createState() => _WishBoardScreenState();
}

class _WishBoardScreenState extends State<WishBoardScreen> {
  String _selectedCategoryFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final karmaProvider = Provider.of<KarmaProvider>(context);
    final wishes = karmaProvider.allWishes;

    // Filter wishes
    final filteredWishes = _selectedCategoryFilter == 'All'
        ? wishes
        : wishes.where((w) => w.category.name == _selectedCategoryFilter).toList();

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🌟 Wish Board'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner for Wishes waiting
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFFFB300).withOpacity(0.08),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFF8F00)),
                const SizedBox(width: 8),
                Text(
                  '${wishes.length + 1237} wishes waiting for sponsors',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[900],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Category filter bar
          Container(
            height: 48,
            margin: const EdgeInsets.only(top: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildFilterChip('All', theme),
                ...WishCategory.values.map((cat) => _buildFilterChip(cat.name, theme)),
              ],
            ),
          ),

          // Wishes list
          Expanded(
            child: filteredWishes.isEmpty
                ? const Center(
                    child: Text('No wishes found in this category.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredWishes.length,
                    itemBuilder: (context, idx) {
                      final wish = filteredWishes[idx];
                      final pct = wish.karmaTarget > 0
                          ? (wish.karmaRaised / wish.karmaTarget).clamp(0.0, 1.0)
                          : 0.0;

                      return Card(
                        key: Key('wish_card_${wish.id}'),
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.wishDetail,
                            arguments: wish.id,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      wish.category.icon,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      wish.category.label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber[800],
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: wish.status == WishStatus.fulfilled
                                            ? Colors.green.withOpacity(0.12)
                                            : Colors.blue.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        wish.status.label,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: wish.status == WishStatus.fulfilled
                                              ? Colors.green
                                              : Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  wish.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  wish.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.grey[650], fontSize: 12),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Submitted by ${wish.userName}',
                                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                    Text(
                                      'Goal: ${wish.karmaTarget} Karma',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    backgroundColor: Colors.grey.withOpacity(0.15),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      wish.status == WishStatus.fulfilled
                                          ? Colors.green
                                          : const Color(0xFFFF9F00),
                                    ),
                                    minHeight: 6,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${(pct * 100).toInt()}% Sponsored',
                                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${wish.karmaRaised} / ${wish.karmaTarget} Karma',
                                      style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createWish),
        backgroundColor: const Color(0xFFFF8F00),
        icon: const Icon(Icons.star_rounded, color: Colors.white),
        label: const Text('Make My Wish', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildFilterChip(String catName, ThemeData theme) {
    final isSelected = _selectedCategoryFilter == catName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryFilter = catName;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF8F00) : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF8F00) : Colors.grey.withOpacity(0.2),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          catName,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}
