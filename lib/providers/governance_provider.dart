import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/proposed_action.dart';
import '../models/karma_category.dart';

class GovernanceProvider extends ChangeNotifier {
  List<ProposedAction> _proposals = [];
  bool _isLoading = false;

  List<ProposedAction> get proposals => _proposals;
  bool get isLoading => _isLoading;

  GovernanceProvider() {
    _loadProposals();
  }

  Future<void> _loadProposals() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('governance_proposals');

    if (jsonStr != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        _proposals = decoded.map((e) => ProposedAction.fromJson(e)).toList();
      } catch (e) {
        _seedDefaultProposals();
      }
    } else {
      _seedDefaultProposals();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _seedDefaultProposals() {
    _proposals = [
      ProposedAction(
        id: 'prop_001',
        proposerId: 'user_john',
        proposerName: 'John Doe',
        title: 'Install a water-saving system in a government school',
        problemDescription: 'Government schools experience severe water leakage and high usage, leading to waste and utility bills.',
        category: KarmaCategory.environment,
        location: 'Bengaluru, India',
        expectedImpact: 'Reduces school water consumption by up to 35% and teaches kids eco-habits.',
        evidenceRequired: 'Geotagged photos of installed flow-restrictors and 1 monthly water bill comparison.',
        estimatedResources: '₹12,000 for materials and 3 hours of plumber/volunteer time.',
        whoBenefits: '250+ school children and the school board admin.',
        suggestedKarma: 90,
        status: ProposalStatus.community,
        approvals: 1,
        rejections: 0,
        votedUserIds: {'user_jane'},
      ),
      ProposedAction(
        id: 'prop_002',
        proposerId: 'user_jane',
        proposerName: 'Jane Smith',
        title: 'Conduct street dog vaccination & feeding drive',
        problemDescription: 'Stray dogs are vulnerable to rabies and hunger, causing community safety friction.',
        category: KarmaCategory.animalWelfare,
        location: 'Delhi NCR, India',
        expectedImpact: 'Vaccinates stray dogs in a 2 sq km sector and reduces conflict with residents.',
        evidenceRequired: 'Vet vaccination certificates, tag collar photos, and live video feeds.',
        estimatedResources: '₹8,000 for vaccines/feeds and 4 hours of volunteer helper shifts.',
        whoBenefits: 'Dogs and residents in the local colony.',
        suggestedKarma: 75,
        status: ProposalStatus.community,
        approvals: 0,
        rejections: 0,
        votedUserIds: {},
      ),
      ProposedAction(
        id: 'prop_003',
        proposerId: 'user_admin',
        proposerName: 'Global Board',
        title: 'Publish open-source textbook translating scientific papers',
        problemDescription: 'Valuable research is hidden behind paywalls and academic jargon, inaccessible to grassroots students.',
        category: KarmaCategory.innovation,
        location: 'Global / Online',
        expectedImpact: 'Allows anyone to access simplified summaries of climate and energy research.',
        evidenceRequired: 'Public GitHub repository link containing markdown files and pdf compiler scripts.',
        estimatedResources: '15 hours of science translation and editing labor.',
        whoBenefits: 'Thousands of global students and clean energy startups.',
        suggestedKarma: 120,
        status: ProposalStatus.verified, // Already upgraded!
        approvals: 3,
        rejections: 0,
        votedUserIds: {'user_john', 'user_jane', 'user_validator'},
      ),
    ];
    _saveProposals();
  }

  Future<void> _saveProposals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'governance_proposals',
      jsonEncode(_proposals.map((e) => e.toJson()).toList()),
    );
  }

  Future<bool> proposeAction({
    required String title,
    required String problemDescription,
    required KarmaCategory category,
    required String location,
    required String expectedImpact,
    required String evidenceRequired,
    required String estimatedResources,
    required String whoBenefits,
    required int suggestedKarma,
    required String proposerId,
    required String proposerName,
  }) async {
    final newProposal = ProposedAction(
      id: 'prop_${const Uuid().v4()}',
      proposerId: proposerId,
      proposerName: proposerName,
      title: title,
      problemDescription: problemDescription,
      category: category,
      location: location,
      expectedImpact: expectedImpact,
      evidenceRequired: evidenceRequired,
      estimatedResources: estimatedResources,
      whoBenefits: whoBenefits,
      suggestedKarma: suggestedKarma,
      status: ProposalStatus.community,
      approvals: 0,
      rejections: 0,
      votedUserIds: {},
    );

    _proposals.insert(0, newProposal);
    await _saveProposals();
    notifyListeners();
    return true;
  }

  Future<void> voteOnProposal(String proposalId, String userId, bool approve) async {
    final idx = _proposals.indexWhere((e) => e.id == proposalId);
    if (idx == -1) return;

    final proposal = _proposals[idx];
    if (proposal.votedUserIds.contains(userId)) return; // already voted

    final newVotedIds = Set<String>.from(proposal.votedUserIds)..add(userId);
    int newApprovals = proposal.approvals;
    int newRejections = proposal.rejections;

    if (approve) {
      newApprovals += 1;
    } else {
      newRejections += 1;
    }

    ProposalStatus newStatus = proposal.status;
    
    // Check level upgrade thresholds:
    // Community -> Verified at net 2 approvals (approvals - rejections >= 2)
    // Verified -> Global at net 5 approvals (approvals - rejections >= 5)
    final netVotes = newApprovals - newRejections;
    if (proposal.status == ProposalStatus.community && netVotes >= 2) {
      newStatus = ProposalStatus.verified;
    } else if (proposal.status == ProposalStatus.verified && netVotes >= 5) {
      newStatus = ProposalStatus.global;
    }

    _proposals[idx] = proposal.copyWith(
      approvals: newApprovals,
      rejections: newRejections,
      votedUserIds: newVotedIds,
      status: newStatus,
    );

    await _saveProposals();
    notifyListeners();
  }
}
