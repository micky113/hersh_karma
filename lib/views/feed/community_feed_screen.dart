import 'package:flutter/material.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final List<Map<String, dynamic>> _posts = [
    {
      'id': 'post_01',
      'user': 'Alice Green',
      'badge': '🌱 Level 3 Validator',
      'deed': 'Organized Beach Cleanup Drive',
      'desc': 'Collected 25kg of microplastics with 5 volunteers. The shore is pristine and verified now!',
      'category': '🌱 Environment',
      'likes': 32,
      'isLiked': false,
      'hash': '0x7a8f...92d1',
      'score': '96/100',
    },
    {
      'id': 'post_02',
      'user': 'Bob Shepherd',
      'badge': '🐕 Level 5 Contributor',
      'deed': 'Rescued Injured Stray Puppy',
      'desc': 'Found an injured puppy near Sector 4. Delivered to shelter and funded initial medical treatment.',
      'category': '🐕 Animal Welfare',
      'likes': 45,
      'isLiked': false,
      'hash': '0x3c2e...88b4',
      'score': '92/100',
    },
    {
      'id': 'post_03',
      'user': 'Priya Sharma',
      'badge': '📚 Level 4 Educator',
      'deed': 'Free Coding Literacy Session for 12 Girls',
      'desc': 'Taught basic computer literacy and Python fundamentals to students from rural community school.',
      'category': '📚 Education',
      'likes': 58,
      'isLiked': false,
      'hash': '0x99a1...44f2',
      'score': '98/100',
    },
  ];

  void _toggleLike(int index) {
    setState(() {
      final isLiked = _posts[index]['isLiked'] as bool;
      _posts[index]['isLiked'] = !isLiked;
      _posts[index]['likes'] = (_posts[index]['likes'] as int) + (isLiked ? -1 : 1);
    });
  }

  void _showAuditDetails(Map<String, dynamic> post) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.verified_rounded, color: Color(0xFF00B074)),
            const SizedBox(width: 8),
            Text('Proof Verification Audit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Action: ${post['deed']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text('Contributor: ${post['user']} (${post['badge']})', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00B074).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF00B074).withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Evidence Score: ${post['score']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF00B074))),
                  const SizedBox(height: 4),
                  const Text('Duplicate Image Hash: PASSED (Unique)', style: TextStyle(fontSize: 11)),
                  const SizedBox(height: 2),
                  const Text('Geotag & Time: PASSED (On-Site Capture)', style: TextStyle(fontSize: 11)),
                  const SizedBox(height: 4),
                  Text('Ledger Block: ${post['hash']}', style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.blueGrey)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Community Feed')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final post = _posts[index];
          final isLiked = post['isLiked'] as bool;

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                            backgroundColor: const Color(0xFF00B074).withOpacity(0.12),
                            child: Text(
                              (post['user'] as String)[0],
                              style: const TextStyle(color: Color(0xFF00B074), fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(post['user'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(post['badge'] as String, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B074).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          post['category'] as String,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF00B074)),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(post['deed'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(post['desc'] as String, style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.3)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => _toggleLike(index),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: isLiked ? Colors.redAccent : Colors.grey,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${post['likes']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isLiked ? FontWeight.bold : FontWeight.normal,
                                  color: isLiked ? Colors.redAccent : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _showAuditDetails(post),
                        icon: const Icon(Icons.shield_outlined, size: 16, color: Color(0xFF00B074)),
                        label: const Text('Verify / Audit', style: TextStyle(fontSize: 11, color: Color(0xFF00B074), fontWeight: FontWeight.bold)),
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
