import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/karma_provider.dart';
import '../../models/app_feedback.dart';
import '../../core/localization/app_localizations.dart';
import '../../services/voice_service.dart';

class FeedbackModal {
  static void show(BuildContext context, String screenName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            expand: false,
            builder: (context, scrollController) {
              return DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(height: 12),
                    TabBar(
                      labelColor: const Color(0xFF00B074),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: const Color(0xFF00B074),
                      tabs: [
                        Tab(icon: const Icon(Icons.lightbulb_outline), text: AppLocalizations.translateWithContext(context, 'fb_tab_give', defaultValue: 'Give Feedback 💡')),
                        Tab(icon: const Icon(Icons.people_outline), text: AppLocalizations.translateWithContext(context, 'fb_tab_ideas', defaultValue: 'Community Ideas 👥')),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _FeedbackInputTab(screenName: screenName),
                          _CommunityIdeasTab(scrollController: scrollController),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _FeedbackInputTab extends StatefulWidget {
  final String screenName;
  const _FeedbackInputTab({required this.screenName});

  @override
  State<_FeedbackInputTab> createState() => _FeedbackInputTabState();
}

class _FeedbackInputTabState extends State<_FeedbackInputTab> {
  int _step = 0; // 0: Select category, 1: Tell us more
  FeedbackCategory? _selectedCategory;
  
  // Context-aware variables
  bool _isContextAware = false;
  String? _contextAwareDifficulty; // Easy, Okay, Difficult

  final TextEditingController _detailsController = TextEditingController();
  bool _hasVoiceNote = false;
  bool _hasScreenshot = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    // Enable context-aware difficulty check for capture/submissions
    if (widget.screenName.contains('ProofCapture') || widget.screenName.contains('Deed')) {
      _isContextAware = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isContextAware) {
      return _buildContextAwareView();
    }

    if (_step == 0) {
      return _buildCategorySelectionView();
    }

    return _buildDetailsInputView();
  }

  // Context-Aware View (Before Proof, Capture pages)
  Widget _buildContextAwareView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Was this step easy?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Feedback for: ${widget.screenName}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _submitContextDifficulty('Easy'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green)),
                    child: const Column(
                      children: [
                        Text('👍', style: TextStyle(fontSize: 32)),
                        SizedBox(height: 8),
                        Text('Easy', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => _submitContextDifficulty('Okay'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.amber)),
                    child: const Column(
                      children: [
                        Text('😐', style: TextStyle(fontSize: 32)),
                        SizedBox(height: 8),
                        Text('Okay', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isContextAware = false; // transit to standard ideas view to capture detailed complaint
                      _selectedCategory = FeedbackCategory.dontUnderstand;
                      _step = 1;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.red)),
                    child: const Column(
                      children: [
                        Text('👎', style: TextStyle(fontSize: 32)),
                        SizedBox(height: 8),
                        Text('Difficult', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _submitContextDifficulty(String level) {
    final karmaProv = Provider.of<KarmaProvider>(context, listen: false);
    karmaProv.submitFeedback(
      AppFeedback(
        id: const Uuid().v4(),
        screenContext: widget.screenName,
        category: FeedbackCategory.like,
        details: 'User rated process difficulty as: $level',
        timestamp: DateTime.now(),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Thank you for your feedback!'), backgroundColor: Color(0xFF00B074)),
    );
    Navigator.pop(context);
  }

  // Step 1: Select 1-tap category
  Widget _buildCategorySelectionView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Improve Karma Grid 💡',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'On: ${widget.screenName}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Category buttons
          _buildCategoryBtn(FeedbackCategory.like, Colors.green[50]!, Colors.green),
          const SizedBox(height: 12),
          _buildCategoryBtn(FeedbackCategory.dontUnderstand, Colors.orange[50]!, Colors.orange),
          const SizedBox(height: 12),
          _buildCategoryBtn(FeedbackCategory.broken, Colors.red[50]!, Colors.red),
          const SizedBox(height: 12),
          _buildCategoryBtn(FeedbackCategory.idea, Colors.purple[50]!, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildCategoryBtn(FeedbackCategory cat, Color bg, Color border) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = cat;
          _step = 1;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border.withOpacity(0.3), width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              cat.label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: border),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: border),
          ],
        ),
      ),
    );
  }

  // Step 2: Details / Voice input screen
  Widget _buildDetailsInputView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _step = 0;
                  });
                },
              ),
              Expanded(
                child: Text(
                  'Tell us more...',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Speech simulator target
          InkWell(
            onTap: _toggleVoiceRecordSim,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: _isRecording ? Colors.red[50] : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _isRecording ? Colors.red : Colors.grey[300]!, width: 2),
              ),
              child: Column(
                children: [
                  Icon(
                    _isRecording ? Icons.fiber_manual_record : Icons.mic_none_outlined,
                    size: 48,
                    color: _isRecording ? Colors.red : Colors.grey[600],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isRecording ? '🎙️ Tap to Stop Speaking...' : '🎙️ Tap to Speak Feedback',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isRecording ? Colors.red : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Simulate natural speech feedback note', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Text Field
          TextField(
            controller: _detailsController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Write details (optional)',
              hintText: 'e.g. "This button was confusing to navigate."',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          ),
          const SizedBox(height: 16),

          // Attach Screenshot mock
          CheckboxListTile(
            title: const Text('📸 Attach Screenshot of current screen'),
            value: _hasScreenshot,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (val) {
              setState(() {
                _hasScreenshot = val ?? false;
              });
            },
          ),
          const SizedBox(height: 24),

          // Submit
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B074),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _submitFeedback,
            child: const Text('SEND 🚀', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _toggleVoiceRecordSim() {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
        _hasVoiceNote = true;
        _detailsController.text = 'This page has too much text, please make it simpler.';
      });
      KarmaVoice.speak('', directText: 'Recording processed: ${_detailsController.text}', context: context);
    } else {
      setState(() {
        _isRecording = true;
      });
    }
  }

  void _submitFeedback() {
    final karmaProv = Provider.of<KarmaProvider>(context, listen: false);
    final text = _detailsController.text.trim();

    // AI parses natural suggestions
    AppFeedback fb;
    if (_selectedCategory == FeedbackCategory.idea && text.isNotEmpty) {
      fb = karmaProv.parseSpeechImprovement(text, widget.screenName);
    } else {
      fb = AppFeedback(
        id: const Uuid().v4(),
        screenContext: widget.screenName,
        category: _selectedCategory ?? FeedbackCategory.idea,
        details: text.isNotEmpty ? text : 'User submitted quick feedback note.',
        hasVoiceNote: _hasVoiceNote,
        hasScreenshot: _hasScreenshot,
        timestamp: DateTime.now(),
      );
    }

    karmaProv.submitFeedback(fb);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Feedback submitted! Thank you for co-designing Karma Grid!'), backgroundColor: Color(0xFF00B074)),
    );
    Navigator.pop(context);
  }
}

class _CommunityIdeasTab extends StatelessWidget {
  final ScrollController scrollController;
  const _CommunityIdeasTab({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final karmaProv = Provider.of<KarmaProvider>(context);
    final feedbacks = karmaProv.feedbacks.where((e) => e.category == FeedbackCategory.idea).toList();

    if (feedbacks.isEmpty) {
      return const Center(child: Text('No community suggestions yet.'));
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: feedbacks.length,
      itemBuilder: (context, index) {
        final fb = feedbacks[index];
        
        Color statusColor = Colors.grey;
        if (fb.status == FeedbackStatus.reviewing) statusColor = Colors.orange;
        if (fb.status == FeedbackStatus.testing) statusColor = Colors.blue;
        if (fb.status == FeedbackStatus.implemented) statusColor = Colors.green;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        fb.status.name.toUpperCase(),
                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      fb.aiClassification,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  fb.details,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Suggested on: ${fb.screenContext}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Was this idea useful?', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => karmaProv.voteFeedback(fb.id, true),
                          icon: const Icon(Icons.thumb_up_alt_outlined, size: 14, color: Colors.green),
                          label: Text('${fb.usefulVotes}', style: const TextStyle(color: Colors.green, fontSize: 12)),
                        ),
                        TextButton.icon(
                          onPressed: () => karmaProv.voteFeedback(fb.id, false),
                          icon: const Icon(Icons.thumb_down_alt_outlined, size: 14, color: Colors.red),
                          label: Text('${fb.notUsefulVotes}', style: const TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
