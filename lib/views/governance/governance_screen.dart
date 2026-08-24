import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/governance_provider.dart';
import '../../models/proposed_action.dart';
import '../../core/routes/app_routes.dart';

class GovernanceScreen extends StatefulWidget {
  const GovernanceScreen({super.key});

  @override
  State<GovernanceScreen> createState() => _GovernanceScreenState();
}

class _GovernanceScreenState extends State<GovernanceScreen> {
  ProposalStatus _selectedFilter = ProposalStatus.community;
  ProposedAction? _selectedProposalDetail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final govProvider = Provider.of<GovernanceProvider>(context);

    final currentUser = authProvider.currentUser;
    final proposals = govProvider.proposals.where((e) => e.status == _selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Governance'),
      ),
      body: govProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title Header Banner
                  Card(
                    color: Colors.purple.withOpacity(0.08),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Colors.purple, width: 1.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            '🏛️ DEMOCRATIC IMPACT EVOLUTION',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.purple),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Review and vote on new action registry presets proposed by the community. Watch community actions upgrade from User Proposals to Verified Actions and eventually Global Standards.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Segment Filter Chips
                  Row(
                    children: [
                      const Text(
                        'Registry Tier:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ProposalStatus.values.map((status) {
                              final isSelected = _selectedFilter == status;
                              String label = 'User Community';
                              if (status == ProposalStatus.verified) label = 'Verified Registry';
                              if (status == ProposalStatus.global) label = 'Global Protocol';

                              return Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: ChoiceChip(
                                  label: Text(label),
                                  selected: isSelected,
                                  selectedColor: Colors.purple.withOpacity(0.2),
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedFilter = status;
                                      _selectedProposalDetail = null;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (proposals.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            'No proposals found in this tier.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: proposals.length,
                      itemBuilder: (context, idx) {
                        final prop = proposals[idx];
                        final isSelected = _selectedProposalDetail?.id == prop.id;
                        final netVotes = prop.approvals - prop.rejections;
                        
                        // Progress bar calculations
                        double threshold = 2.0; // Community -> Verified
                        if (prop.status == ProposalStatus.verified) threshold = 5.0; // Verified -> Global
                        double progress = (netVotes >= 0 ? netVotes : 0) / threshold;
                        progress = progress.clamp(0.0, 1.0);

                        return Card(
                          elevation: isSelected ? 4 : 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? Colors.purple : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: prop.category.color.withOpacity(0.15),
                                  child: Text(prop.category.icon),
                                ),
                                title: Text(
                                  prop.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                subtitle: Text(
                                  'Proposed by ${prop.proposerName} • ${prop.location}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                                onTap: () {
                                  setState(() {
                                    _selectedProposalDetail = prop;
                                  });
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Net Approvals: $netVotes (${prop.approvals} Yes / ${prop.rejections} No)',
                                          style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                                        ),
                                        Text(
                                          '${(progress * 100).toInt()}% towards Registry upgrade',
                                          style: const TextStyle(fontSize: 10, color: Colors.blueGrey, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.grey.withOpacity(0.2),
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  // Detail View Overlay Card
                  if (_selectedProposalDetail != null) ...[
                    const SizedBox(height: 20),
                    Card(
                      color: Colors.purple.withOpacity(0.04),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Colors.purple, width: 1.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Proposal Details',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.purple),
                            ),
                            const Divider(),
                            _buildDetailRow('Action Name', _selectedProposalDetail!.title),
                            _buildDetailRow('Addresses Problem', _selectedProposalDetail!.problemDescription),
                            _buildDetailRow('Category', _selectedProposalDetail!.category.label),
                            _buildDetailRow('Target Location', _selectedProposalDetail!.location),
                            _buildDetailRow('Expected Impact', _selectedProposalDetail!.expectedImpact),
                            _buildDetailRow('Required Evidence', _selectedProposalDetail!.evidenceRequired),
                            _buildDetailRow('Estimated Resources', _selectedProposalDetail!.estimatedResources),
                            _buildDetailRow('Who Benefits', _selectedProposalDetail!.whoBenefits),
                            _buildDetailRow('Suggested Karma Value', '${_selectedProposalDetail!.suggestedKarma} Credits'),
                            const SizedBox(height: 16),

                            // Voting Buttons
                            if (currentUser != null) ...[
                              if (_selectedProposalDetail!.votedUserIds.contains(currentUser.id))
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      '✅ You have cast your vote on this proposal.',
                                      style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                )
                              else ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(color: Colors.red),
                                        ),
                                        onPressed: () {
                                          govProvider.voteOnProposal(_selectedProposalDetail!.id, currentUser.id, false);
                                          setState(() {
                                            _selectedProposalDetail = govProvider.proposals.firstWhere((e) => e.id == _selectedProposalDetail!.id);
                                          });
                                        },
                                        icon: const Icon(Icons.thumb_down_outlined, size: 16),
                                        label: const Text('Reject Proposal'),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.purple,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () {
                                          govProvider.voteOnProposal(_selectedProposalDetail!.id, currentUser.id, true);
                                          setState(() {
                                            _selectedProposalDetail = govProvider.proposals.firstWhere((e) => e.id == _selectedProposalDetail!.id);
                                          });
                                        },
                                        icon: const Icon(Icons.thumb_up_outlined, size: 16),
                                        label: const Text('Approve Action'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.proposeAction),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Propose Action'),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blueGrey),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
