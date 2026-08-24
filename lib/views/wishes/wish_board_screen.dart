import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/karma_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../models/wish.dart';

class WishBoardScreen extends StatefulWidget {
  const WishBoardScreen({super.key});

  @override
  State<WishBoardScreen> createState() => _WishBoardScreenState();
}

class _WishBoardScreenState extends State<WishBoardScreen> with SingleTickerProviderStateMixin {
  String _selectedCategoryFilter = 'All';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final karmaProvider = Provider.of<KarmaProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final wishes = karmaProvider.allWishes;

    // Filter out reported wishes
    final safeWishes = wishes.where((w) => !w.isReported).toList();

    // Filter by category first
    final catFilteredWishes = _selectedCategoryFilter == 'All'
        ? safeWishes
        : safeWishes.where((w) => w.category.name == _selectedCategoryFilter).toList();

    // Grouping by sections
    final myWishes = catFilteredWishes.where((w) => w.userId == authProvider.currentUser?.id).toList();
    
    // Wishes I can help: active wishes not owned by me
    final helpWishes = catFilteredWishes.where((w) => w.userId != authProvider.currentUser?.id && w.status == WishStatus.active).toList();
    
    // Wishes being fulfilled: active wishes with progress > 0
    final activeFulfillmentWishes = catFilteredWishes.where((w) => w.status == WishStatus.active && w.karmaRaised > 0).toList();
    
    // Wishes made possible: fulfilled status
    final madePossibleWishes = catFilteredWishes.where((w) => w.status == WishStatus.fulfilled).toList();

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🌟 Wish Come True Hub'),
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

          // ➕ Make a Wish action row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
              label: const Text('Make a Wish 💫', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8F00),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
              ),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.createWish),
            ),
          ),

          // Category filter bar
          Container(
            height: 48,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildFilterChip('All', theme),
                ...WishCategory.values.map((cat) => _buildFilterChip(cat.name, theme)),
              ],
            ),
          ),

          // Tab Bar for Sections
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: const Color(0xFFFF8F00),
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: const Color(0xFFFF8F00),
            tabs: [
              Tab(text: '✨ My Wishes (${myWishes.length})'),
              Tab(text: '🌟 I Can Help (${helpWishes.length})'),
              Tab(text: '❤️ Being Fulfilled (${activeFulfillmentWishes.length})'),
              Tab(text: '✅ Made Possible (${madePossibleWishes.length})'),
            ],
          ),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildWishList(myWishes, 'You haven\'t submitted any wishes yet.'),
                _buildWishList(helpWishes, 'No wishes matching this category need help right now.'),
                _buildWishList(activeFulfillmentWishes, 'No wishes are currently receiving active sponsorship.'),
                _buildWishList(madePossibleWishes, 'No wishes have been fully completed in this category yet.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishList(List<Wish> list, String emptyMessage) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, idx) {
        final wish = list[idx];
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
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Trust: ${wish.wishTrustScore}%',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[950],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.purple[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Level ${wish.verificationLevel}',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
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
                        wish.sponsorshipType == SponsorshipType.volunteerService
                            ? 'Non-monetary Focus'
                            : 'Goal: ${wish.karmaTarget} Karma',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (wish.sponsorshipType != SponsorshipType.volunteerService) ...[
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
                ],
              ),
            ),
          ),
        );
      },
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
