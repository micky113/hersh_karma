import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';

class SignatureActivitiesScreen extends StatefulWidget {
  const SignatureActivitiesScreen({super.key});

  @override
  State<SignatureActivitiesScreen> createState() => _SignatureActivitiesScreenState();
}

class _SignatureActivitiesScreenState extends State<SignatureActivitiesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Timer _timer;
  int _secondsRemaining = 2700; // 45 minutes

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    
    // Countdown timer for Karma Quest
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌈 Signature Quests & Hub'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.hub_outlined), text: 'Karma Ripple'),
            Tab(icon: Icon(Icons.emoji_events_outlined), text: 'Karma Olympics'),
            Tab(icon: Icon(Icons.explore_outlined), text: 'Karma Quest'),
            Tab(icon: Icon(Icons.school_outlined), text: 'Skill-Swap'),
            Tab(icon: Icon(Icons.videogame_asset_outlined), text: 'Game Night'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRippleTab(),
          _buildOlympicsTab(),
          _buildQuestTab(),
          _buildSkillSwapTab(),
          _buildGameNightTab(),
        ],
      ),
    );
  }

  // 1. KARMA RIPPLE TAB
  Widget _buildRippleTab() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.blue.withOpacity(0.08),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.blue, width: 1.0),
            ),
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                '🔄 THE RIPPLE PRINCIPLE\nOne positive deed inspires three people, who each inspire three more. Watch your kindness expand exponentially through your chain.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Your Chain: 13 Inspired Members (Tier 3 Ripple)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),

          // Graphical Ripple Tree Node Representation
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  // Root: You
                  _buildNodeChip('Root: You (John Doe)', Colors.green, true),
                  _buildConnectorLine(),

                  // Level 1: 3 People
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          _buildNodeChip('Jane Smith 👭', Colors.blue, false),
                          _buildConnectorLine(),
                          _buildMiniLeafs(['David 🧑', 'Eve 👩', 'Frank 👨']),
                        ],
                      ),
                      Column(
                        children: [
                          _buildNodeChip('Bob Miller 🚴', Colors.amber, false),
                          _buildConnectorLine(),
                          _buildMiniLeafs(['Grace 👩', 'Heidi 👩', 'Ivan 🧑']),
                        ],
                      ),
                      Column(
                        children: [
                          _buildNodeChip('Charlie Brown 🎨', Colors.purple, false),
                          _buildConnectorLine(),
                          _buildMiniLeafs(['Judy 👩', 'Karl 🧑', 'Leo 🧑']),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeChip(String name, Color color, bool isRoot) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isRoot ? 16 : 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color, width: isRoot ? 2.0 : 1.0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        name,
        style: TextStyle(fontSize: isRoot ? 12 : 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildConnectorLine() {
    return Container(
      width: 2,
      height: 16,
      color: Colors.grey[400],
    );
  }

  Widget _buildMiniLeafs(List<String> names) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: names.map((name) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Text(
              name,
              style: const TextStyle(fontSize: 8, color: Colors.blueGrey),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 2. KARMA OLYMPICS TAB
  Widget _buildOlympicsTab() {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: const TabBar(
          isScrollable: false,
          tabs: [
            Tab(text: '🏫 Schools'),
            Tab(text: '🎓 Colleges'),
            Tab(text: '🏢 Corporates'),
            Tab(text: '🏙️ Cities'),
          ],
        ),
        body: TabBarView(
          children: [
            _buildOlympicsList([
              {'name': 'Delhi Public School, Dwarka', 'score': '14,250 KGC', 'rank': '1'},
              {'name': 'Greenwood High, Bengaluru', 'score': '12,900 KGC', 'rank': '2'},
              {'name': 'St. Xavier\'s Collegiate School, Kolkata', 'score': '11,100 KGC', 'rank': '3'},
            ]),
            _buildOlympicsList([
              {'name': 'IIT Delhi', 'score': '32,450 KGC', 'rank': '1'},
              {'name': 'BITS Pilani', 'score': '29,800 KGC', 'rank': '2'},
              {'name': 'St. Stephen\'s College, Delhi', 'score': '24,150 KGC', 'rank': '3'},
            ]),
            _buildOlympicsList([
              {'name': 'Tata Consultancy Services', 'score': '75,000 KGC', 'rank': '1'},
              {'name': 'Infosys Eco-Group', 'score': '68,250 KGC', 'rank': '2'},
              {'name': 'Wipro Green Council', 'score': '59,900 KGC', 'rank': '3'},
            ]),
            _buildOlympicsList([
              {'name': 'Bengaluru', 'score': '485,000 KGC', 'rank': '1'},
              {'name': 'Mumbai', 'score': '432,100 KGC', 'rank': '2'},
              {'name': 'New Delhi', 'score': '395,000 KGC', 'rank': '3'},
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildOlympicsList(List<Map<String, String>> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, idx) {
        final item = items[idx];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFFFB300).withOpacity(0.15),
              child: Text(
                '#${item['rank']}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFB300)),
              ),
            ),
            title: Text(
              item['name']!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            trailing: Text(
              item['score']!,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00B074)),
            ),
          ),
        );
      },
    );
  }

  // 3. KARMA QUEST TAB
  Widget _buildQuestTab() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.amber.withOpacity(0.08),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.amber, width: 1.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'QUEST TIMEOUT: ${_formatTime(_secondsRemaining)} remaining\nSelect and complete one mission within 2 km of your location.',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Quests Active Near You (GPS Verified)',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                _buildQuestCard(
                  '📚 Donate Books to Pop-Up Library',
                  '0.4 km away • 15 Karma Credits reward',
                  'Drop off 3 readable books at the community bookshelf in Central Sector.',
                ),
                _buildQuestCard(
                  '🧹 Clean-up Neighborhood Park Pavements',
                  '1.2 km away • 25 Karma Credits reward',
                  'Collect litter at Sector 5 park. Bring gloves and take before/after pictures.',
                ),
                _buildQuestCard(
                  '🐦 Setup a Bird Feeder Station',
                  '1.8 km away • 20 Karma Credits reward',
                  'Create a watering layout for local birds and secure it in a shaded garden.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestCard(String title, String subtitle, String desc) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              style: TextStyle(fontSize: 11, color: Colors.grey[750]),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B074),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Accept Quest: $title pre-filled!'),
                      backgroundColor: const Color(0xFF00B074),
                    ),
                  );
                },
                child: const Text('Accept & Navigate'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. SKILL-SWAP HUB TAB
  Widget _buildSkillSwapTab() {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '🤝 KNOWLEDGE EXCHANGE CIRCLE\nNo money needed. Swap your skills and help build community knowledge.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[800]),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildSkillSwapCard(
                'Amit Sharma',
                'Teaching Python Programming 🐍',
                'Wants to learn Guitar basics 🎸',
              ),
              _buildSkillSwapCard(
                'Priya Patel',
                'Teaching organic soil composting 🌱',
                'Wants to learn basic accounting 📊',
              ),
              _buildSkillSwapCard(
                'John Doe',
                'Teaching Digital Literacy 📱',
                'Wants to learn French conversation 🗣️',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkillSwapCard(String name, String teach, String learn) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const Divider(height: 16),
            Row(
              children: [
                const Icon(Icons.arrow_upward_rounded, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Teaches: $teach', style: const TextStyle(fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.arrow_downward_rounded, color: Colors.blue, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Wants to learn: $learn', style: const TextStyle(fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Offer sent! Match pending chat settlement.')),
                  );
                },
                child: const Text('Offer to Swap'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. GAME NIGHT TAB
  Widget _buildGameNightTab() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.purple.withOpacity(0.08),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.purple, width: 1.0),
            ),
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                '🎲 SOCIAL IMPACT PLAY\nGather friends and family to compete in collaborative real-world challenges.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ongoing Challenge Matches',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                _buildGameCard(
                  'Zero-Waste Dinner Prep',
                  '5 participants registered • Active',
                  'Host a dinner where no disposable plastics are used and leftovers are composted.',
                ),
                _buildGameCard(
                  'Elder Tech Training Night',
                  '3 participants registered • Open Enrolment',
                  'Gather 3 senior citizens and teach them online banking or messaging app features.',
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create Game Night session lobby!')),
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Host a Game Night'),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(String title, String status, String desc) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(fontSize: 9, color: Colors.purple, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              style: TextStyle(fontSize: 11, color: Colors.grey[750]),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Successfully joined the Game Night Lobby!')),
                );
              },
              child: const Text('Join Lobby'),
            ),
          ],
        ),
      ),
    );
  }
}
