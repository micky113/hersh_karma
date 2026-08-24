import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/karma_provider.dart';
import '../../models/karma_action.dart';

class ValidatorScreen extends StatelessWidget {
  const ValidatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AuthProvider>(context).currentUser;
    final karmaProvider = Provider.of<KarmaProvider>(context);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final pendingList = karmaProvider.pendingValidationActions;

    return Column(
      children: [
        // Validator Info Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: theme.colorScheme.primary.withOpacity(0.08),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.gavel_rounded, color: theme.colorScheme.primary, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Validator Node Active',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              Text(
                'Reputation Weight: ${user.reputationScore >= 80 ? "HIGH (1.5x)" : "NORMAL (1.0x)"}',
                style: TextStyle(
                  color: user.reputationScore >= 80 ? Colors.purple : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: pendingList.isEmpty
              ? _buildEmptyQueue(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pendingList.length,
                  itemBuilder: (context, index) {
                    final deed = pendingList[index];
                    return _buildValidationCard(context, deed, user.id);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyQueue(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.done_all_rounded,
              size: 64,
              color: Color(0xFF00B074),
            ),
            const SizedBox(height: 16),
            const Text(
              'Validation Queue Empty',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'All community submissions have been validated. Thank you for securing the Proof of Good ecosystem!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationCard(BuildContext context, KarmaAction deed, String currentUserId) {
    final theme = Theme.of(context);
    final karmaProvider = Provider.of<KarmaProvider>(context, listen: false);

    final totalVotes = deed.validatorVotes.length;
    final approvals = deed.validatorVotes.values.where((v) => v).length;
    final rejections = deed.validatorVotes.values.where((v) => !v).length;
    final hasVoted = deed.validatorVotes.containsKey(currentUserId);
    final myVote = deed.validatorVotes[currentUserId];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        deed.userName.isNotEmpty ? deed.userName[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      deed.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: deed.category.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${deed.category.icon} ${deed.category.label}',
                    style: TextStyle(
                      color: deed.category.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Deed Title & Description
            Text(
              deed.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              deed.description,
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Proof Checklist
            const Text(
              'Cryptographic Proofs Submitted:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 8),
            _buildProofCheckRow('AI Image Analysis', deed.imageUrl != null, Colors.orange),
            _buildProofCheckRow(
              'GPS Secure Hardware Coords',
              deed.latitude != null && deed.longitude != null,
              Colors.blue,
              detail: deed.latitude != null ? '(${deed.latitude!.toStringAsFixed(4)}, ${deed.longitude!.toStringAsFixed(4)})' : null,
            ),
            _buildProofCheckRow(
              'Third-Party Witness Email',
              deed.witnessEmail != null && deed.witnessEmail!.isNotEmpty,
              Colors.teal,
              detail: deed.witnessEmail,
            ),
            const SizedBox(height: 16),

            // Confidence Index
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Proof Confidence Score:',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  '${(deed.confidenceScore * 100).toInt()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: deed.confidenceScore >= 0.8
                        ? const Color(0xFF00B074)
                        : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Voting action or results
            if (hasVoted)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      myVote == true ? Icons.thumb_up_rounded : Icons.thumb_down_rounded,
                      color: myVote == true ? const Color(0xFF00B074) : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'You voted to ${myVote == true ? "APPROVE" : "REJECT"}.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: myVote == true ? const Color(0xFF00B074) : Colors.red,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _vote(context, karmaProvider, deed.id, false),
                      icon: const Icon(Icons.thumb_down_outlined, color: Colors.red),
                      label: const Text('Reject', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _vote(context, karmaProvider, deed.id, true),
                      icon: const Icon(Icons.thumb_up_rounded),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B074),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 8),
            Center(
              child: Text(
                'Consensus Progress: Approvals ($approvals) • Rejections ($rejections)',
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProofCheckRow(String label, bool isAttached, Color accent, {String? detail}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isAttached ? Icons.check_circle_outline_rounded : Icons.highlight_off_rounded,
            color: isAttached ? const Color(0xFF00B074) : Colors.grey[400],
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isAttached ? Colors.grey[800] : Colors.grey[400],
              decoration: isAttached ? null : TextDecoration.lineThrough,
            ),
          ),
          if (detail != null && isAttached) ...[
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                detail,
                style: TextStyle(fontSize: 11, color: accent, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]
        ],
      ),
    );
  }

  void _vote(BuildContext context, KarmaProvider provider, String deedId, bool approve) async {
    final success = await provider.voteOnDeed(deedId, approve);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approve
              ? '👍 Vote approved submitted. Consensus updated!'
              : '👎 Vote reject submitted. Consensus updated!'),
          backgroundColor: approve ? const Color(0xFF00B074) : Colors.red,
        ),
      );
    }
  }
}
