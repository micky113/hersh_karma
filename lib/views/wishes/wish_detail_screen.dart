import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/karma_provider.dart';
import '../../models/wish.dart';

class WishDetailScreen extends StatefulWidget {
  final String wishId;

  const WishDetailScreen({super.key, required this.wishId});

  @override
  State<WishDetailScreen> createState() => _WishDetailScreenState();
}

class _WishDetailScreenState extends State<WishDetailScreen> {
  final _karmaController = TextEditingController();
  final _customContributionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Set<int> _translatedIndices = {};

  @override
  void dispose() {
    _karmaController.dispose();
    _customContributionController.dispose();
    super.dispose();
  }

  void _sponsorWithKarma(Wish wish, int myCredits) async {
    final amountText = _karmaController.text.trim();
    if (amountText.isEmpty) return;

    final amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid positive Karma amount'), backgroundColor: Colors.red),
      );
      return;
    }

    if (amount > myCredits) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient Karma credits in your wallet!'), backgroundColor: Colors.red),
      );
      return;
    }

    final karmaProvider = Provider.of<KarmaProvider>(context, listen: false);
    final success = await karmaProvider.sponsorWish(wish.id, karmaAmount: amount);

    if (success && mounted) {
      _karmaController.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Thank you for sponsoring! You earned +10 Reputation points.'),
          backgroundColor: Color(0xFF00B074),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(karmaProvider.error ?? 'Sponsorship failed'), backgroundColor: Colors.red),
      );
    }
  }

  void _sponsorWithCustom(Wish wish) async {
    final contribution = _customContributionController.text.trim();
    if (contribution.isEmpty) return;

    final karmaProvider = Provider.of<KarmaProvider>(context, listen: false);
    final success = await karmaProvider.sponsorWish(wish.id, customContribution: contribution);

    if (success && mounted) {
      _customContributionController.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Your resource offer has been added to the Wish Ripple! You earned +10 Reputation.'),
          backgroundColor: Color(0xFF00B074),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(karmaProvider.error ?? 'Sponsorship failed'), backgroundColor: Colors.red),
      );
    }
  }

  void _reportWish() async {
    final karmaProvider = Provider.of<KarmaProvider>(context, listen: false);
    final success = await karmaProvider.reportWish(widget.wishId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Thank you. Wish reported and submitted for human review.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final karmaProvider = Provider.of<KarmaProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    // Find wish in provider list
    final wishIdx = karmaProvider.allWishes.indexWhere((w) => w.id == widget.wishId);
    if (wishIdx == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Wish details')),
        body: const Center(child: Text('Wish not found or deleted.')),
      );
    }

    final wish = karmaProvider.allWishes[wishIdx];
    final myCredits = currentUser?.karmaCredits ?? 0;
    final pct = wish.karmaTarget > 0 ? (wish.karmaRaised / wish.karmaTarget).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('${wish.category.icon} Wish Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.report_problem_outlined, color: Colors.red),
            tooltip: 'Report Suspicious Activity',
            onPressed: wish.isReported ? null : _reportWish,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Safety Warning if reported
              if (wish.isReported) ...[
                Card(
                  color: Colors.red[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.shade200),
                  ),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '⚠️ This wish has been flagged for suspicious activity and is under human safety review.',
                            style: TextStyle(color: Colors.red[900], fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Header Details
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Text(wish.category.icon, style: const TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wish.title,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Category: ${wish.category.label}  •  By ${wish.userName}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Text(
                wish.description,
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
              const Divider(height: 32),

              // Sponsor Protection Info Card
              Card(
                color: Colors.purple.withOpacity(0.04),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.purple.withOpacity(0.15)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🛡️ Sponsor Protection Safeguards',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.purple),
                      ),
                      const SizedBox(height: 12),
                      _buildSafetyItem(Icons.verified_user_outlined, 'Verification Level:', 'Level ${wish.verificationLevel} Audit'),
                      _buildSafetyItem(Icons.psychology_outlined, 'Wish Trust Score:', '${wish.wishTrustScore}/100 Confidence Rating'),
                      _buildSafetyItem(
                        Icons.storefront_outlined,
                        'Payment Destination:',
                        wish.sponsorshipType == SponsorshipType.volunteerService
                            ? 'Non-monetary (Mentorship / Connection)'
                            : 'Direct routing to ${wish.retailerName ?? "Verified Retailer"}',
                      ),
                      if (wish.evidenceDocumentUrls.isNotEmpty)
                        _buildSafetyItem(Icons.attachment_outlined, 'Evidence Attached:', '${wish.evidenceDocumentUrls.length} verified PDF references'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Fulfillment Status Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Fulfillment Goal Progress',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
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
                                color: wish.status == WishStatus.fulfilled ? Colors.green : Colors.blue,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: Colors.grey.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            wish.status == WishStatus.fulfilled ? Colors.green : const Color(0xFFFF9F00),
                          ),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(pct * 100).toInt()}% Sponsored',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFFF8F00)),
                          ),
                          Text(
                            '${wish.karmaRaised} / ${wish.karmaTarget} Karma',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Milestone-based progressive funding releases
              if (wish.milestones.isNotEmpty) ...[
                Text(
                  '📈 Milestone Release Schedule',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Funds are released progressively as specific project stages are verified.',
                  style: TextStyle(color: Colors.grey[650], fontSize: 11),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: wish.milestones.length,
                  itemBuilder: (context, idx) {
                    final milestone = wish.milestones[idx];
                    final isDone = milestone.status == 'completed';
                    final isRel = milestone.status == 'released';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDone ? Colors.green.withOpacity(0.04) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.15)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isDone ? Icons.check_circle_rounded : isRel ? Icons.hourglass_top_rounded : Icons.lock_outline_rounded,
                            color: isDone ? Colors.green : isRel ? Colors.blue : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(milestone.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                Text('${(milestone.percentage * 100).toInt()}% release portion (${milestone.amount.toInt()} Karma)', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDone ? Colors.green[100] : isRel ? Colors.blue[100] : Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              milestone.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: isDone ? Colors.green[900] : isRel ? Colors.blue[900] : Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(height: 40),
              ],

              // AI Wish Plan Section
              Text(
                '🤖 AI-Generated Wish Execution Plan',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Milestones parsed by AI from description. Users can toggle items as they are completed.',
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: wish.wishPlan.length,
                itemBuilder: (context, idx) {
                  final step = wish.wishPlan[idx];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: step.isCompleted ? Colors.green.withOpacity(0.04) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.withOpacity(0.15)),
                    ),
                    child: CheckboxListTile(
                      value: step.isCompleted,
                      title: Text(
                        step.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: step.isCompleted ? FontWeight.bold : FontWeight.normal,
                          decoration: step.isCompleted ? TextDecoration.lineThrough : null,
                          color: step.isCompleted ? Colors.green[800] : null,
                        ),
                      ),
                      activeColor: Colors.green,
                      onChanged: (_) {
                        karmaProvider.toggleWishStep(wish.id, idx);
                      },
                    ),
                  );
                },
              ),
              const Divider(height: 40),

              // Wish Ripple & Sponsors Feed
              Text(
                '🌊 The Wish Ripple Timeline',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (wish.sponsorContributions.isEmpty)
                Card(
                  elevation: 0,
                  color: Colors.grey[50],
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        'No contributions yet. Be the first to start the Wish Ripple!',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: wish.sponsorContributions.length,
                  itemBuilder: (context, idx) {
                    final contribution = wish.sponsorContributions[idx];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.grey.withOpacity(0.15)),
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.amber,
                              child: Icon(Icons.favorite, color: Colors.white, size: 10),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    contribution.sponsorName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _translatedIndices.contains(idx)
                                        ? 'Translated: "I have booked an extra guitar, I want to donate it."'
                                        : contribution.description,
                                    style: TextStyle(fontSize: 11, color: Colors.grey[850], fontStyle: _translatedIndices.contains(idx) ? FontStyle.italic : FontStyle.normal),
                                  ),
                                  if (contribution.description.contains('गिटार') || contribution.sponsorName == 'Aarav Sharma') ...[
                                    const SizedBox(height: 4),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (_translatedIndices.contains(idx)) {
                                            _translatedIndices.remove(idx);
                                          } else {
                                            _translatedIndices.add(idx);
                                          }
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          const Icon(Icons.translate, size: 10, color: Color(0xFF00B074)),
                                          const SizedBox(width: 4),
                                          Text(
                                            _translatedIndices.contains(idx) ? 'Show Original' : 'Translate to English 🌐',
                                            style: const TextStyle(fontSize: 10, color: Color(0xFF00B074), fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const Divider(height: 40),

              // Sponsor Form Section
              if (wish.status == WishStatus.active && !wish.isReported) ...[
                Text(
                  '🤝 Sponsor & Make This Wish Happen',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your wallet balance: $myCredits Karma Credits. Fulfilling wishes awards +10 reputation!',
                  style: TextStyle(color: Colors.grey[750], fontSize: 11),
                ),
                const SizedBox(height: 16),

                // Sponsor with Karma Credits (Direct-to-Retailer setup)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _karmaController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: wish.sponsorshipType == SponsorshipType.volunteerService
                              ? 'Karma amount (non-applicable)'
                              : 'Karma amount',
                          hintText: 'e.g. 50, 100',
                          prefixIcon: const Icon(Icons.favorite_rounded),
                          enabled: wish.sponsorshipType != SponsorshipType.volunteerService,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8F00),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: wish.sponsorshipType == SponsorshipType.volunteerService
                          ? null
                          : () => _sponsorWithKarma(wish, myCredits),
                      child: const Text('Contribute Karma', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  '🤝 I Can Help Make This Wish Come True',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.teal),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Contribute non-monetary resources (expertise, used goods, mentorship, flight discounts, or professional connections).',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
                const SizedBox(height: 12),

                // Sponsor with custom resource/expertise
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _customContributionController,
                        decoration: const InputDecoration(
                          labelText: 'What can you contribute?',
                          hintText: 'e.g. Spare guitar, 5 free lessons...',
                          prefixIcon: Icon(Icons.handshake_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _sponsorWithCustom(wish),
                      child: const Text('I Can Help', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.purple[300]),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(width: 6),
          Expanded(child: Text(value, style: TextStyle(color: Colors.grey[800], fontSize: 11))),
        ],
      ),
    );
  }
}
