import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/karma_provider.dart';
import '../../models/karma_activity.dart';
import '../../models/community_problem.dart';
import '../../models/wish.dart';
import '../../models/challenge.dart';
import '../../models/user_profile.dart';
import '../../services/search_service.dart';
import '../../core/routes/app_routes.dart';
import '../../services/voice_service.dart';
import '../../core/localization/app_localizations.dart';

class UniversalSearchScreen extends StatefulWidget {
  const UniversalSearchScreen({super.key});

  @override
  State<UniversalSearchScreen> createState() => _UniversalSearchScreenState();
}

class _UniversalSearchScreenState extends State<UniversalSearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<UserProfile> _allUsers = [];
  SearchResult _searchResult = SearchResult(
    activities: [],
    problems: [],
    wishes: [],
    challenges: [],
    profiles: [],
  );

  bool _isLoadingUsers = false;
  bool _useProximity = false;

  @override
  void initState() {
    super.initState();
    _loadUsersDirectory();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadUsersDirectory() async {
    setState(() {
      _isLoadingUsers = true;
    });
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final users = await auth.getAllUsers();
      setState(() {
        _allUsers = users;
      });
    } catch (_) {}
    setState(() {
      _isLoadingUsers = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    final karmaProvider = Provider.of<KarmaProvider>(context, listen: false);

    final results = SearchService.search(
      query: query,
      problems: karmaProvider.problems,
      wishes: karmaProvider.allWishes,
      challenges: karmaProvider.challenges,
      profiles: _allUsers,
      userLat: _useProximity ? 12.9716 : null,
      userLon: _useProximity ? 77.5946 : null,
    );

    setState(() {
      _searchResult = results;
    });
  }

  void _showVoiceSearchDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            String status = '🎙️ Listening... Speak naturally';
            String simulatedText = '';

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('🎙️ Voice Search'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    status,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      labelText: 'Simulate speech input query',
                      hintText: 'e.g. "find an animal rescue" or "पेड़ लगाने का काम"',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final query = textController.text.trim();
                    if (query.isNotEmpty) {
                      Navigator.pop(context);
                      setState(() {
                        _searchController.text = query;
                      });
                      _onSearchChanged();
                      KarmaVoice.speak('', directText: 'Searching for: $query', context: context);
                    }
                  },
                  child: const Text('Simulate speech'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.translateWithContext(context, 'nav_home', defaultValue: 'Home') + ' / Search'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Header Panel
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '🔎 What are you looking for?',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.mic, color: Colors.red),
                        onPressed: _showVoiceSearchDialog,
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Location Proximity Toggle Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Location-Aware (Proximity Search)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  Switch(
                    value: _useProximity,
                    activeColor: const Color(0xFF00B074),
                    onChanged: (val) {
                      setState(() {
                        _useProximity = val;
                      });
                      _onSearchChanged();
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoadingUsers
                  ? const Center(child: CircularProgressIndicator())
                  : (_searchController.text.trim().isEmpty
                      ? _buildEmptyState(theme)
                      : _buildSearchResultsList(theme)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 72, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'Search Karma Grid',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Search universally for presets, reports, organizations, companies, wishes, and friends.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsList(ThemeData theme) {
    if (_searchResult.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text('No results match your query.', style: TextStyle(color: Colors.grey[600])),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        if (_searchResult.activities.isNotEmpty) ...[
          _buildCategoryHeader('🌱 curations / Presets'),
          ..._searchResult.activities.map((act) => _buildActivityTile(act, theme)),
          const SizedBox(height: 16),
        ],
        if (_searchResult.problems.isNotEmpty) ...[
          _buildCategoryHeader('🔎 Community Problems / Reports'),
          ..._searchResult.problems.map((prob) => _buildProblemTile(prob, theme)),
          const SizedBox(height: 16),
        ],
        if (_searchResult.wishes.isNotEmpty) ...[
          _buildCategoryHeader('✨ Wishes Hub'),
          ..._searchResult.wishes.map((wish) => _buildWishTile(wish, theme)),
          const SizedBox(height: 16),
        ],
        if (_searchResult.challenges.isNotEmpty) ...[
          _buildCategoryHeader('🏆 Active Challenges'),
          ..._searchResult.challenges.map((ch) => _buildChallengeTile(ch, theme)),
          const SizedBox(height: 16),
        ],
        if (_searchResult.profiles.isNotEmpty) ...[
          _buildCategoryHeader('👤 People & Organizations Directory'),
          ..._searchResult.profiles.map((prof) => _buildProfileTile(prof, theme)),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 1),
      ),
    );
  }

  Widget _buildActivityTile(KarmaActivity act, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(act.category.icon, style: const TextStyle(fontSize: 24)),
        title: Text(act.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text('Base impact: ${act.baseImpact} points • ${act.effortRating} Effort', style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
        onTap: () {
          // Prefill preset and go to submit screen!
          final provider = Provider.of<KarmaProvider>(context, listen: false);
          provider.prefilledPreset = act;
          Navigator.pushNamed(context, AppRoutes.uploadProof);
        },
      ),
    );
  }

  Widget _buildProblemTile(CommunityProblem prob, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.report_problem_outlined, color: Colors.orange),
        title: Text(prob.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text('Reported by: ${prob.reporterName} • Status: ${prob.status.name.toUpperCase()}', style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.home); // return to dashboard
        },
      ),
    );
  }

  Widget _buildWishTile(Wish wish, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.auto_awesome, color: Colors.purple),
        title: Text(wish.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text('Target: ${wish.karmaTarget} credits • Raised: ${wish.karmaRaised}', style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.wishDetail, arguments: wish.id);
        },
      ),
    );
  }

  Widget _buildChallengeTile(KarmaChallenge ch, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.emoji_events_outlined, color: Colors.amber),
        title: Text(ch.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(ch.description, style: const TextStyle(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.home); // return home discover
        },
      ),
    );
  }

  Widget _buildProfileTile(UserProfile prof, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
          child: Text(prof.name.isNotEmpty ? prof.name[0].toUpperCase() : 'U'),
        ),
        title: Text(prof.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text('${prof.role.label} • Reputation: ${prof.reputationScore}', style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.profileDetail);
        },
      ),
    );
  }
}
