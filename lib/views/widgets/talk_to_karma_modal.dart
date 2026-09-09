import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/routes/app_routes.dart';
import '../../services/voice_service.dart';

class TalkToKarmaModal extends StatefulWidget {
  const TalkToKarmaModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const TalkToKarmaModal(),
    );
  }

  @override
  State<TalkToKarmaModal> createState() => _TalkToKarmaModalState();
}

class _TalkToKarmaModalState extends State<TalkToKarmaModal> with SingleTickerProviderStateMixin {
  bool _isListening = false;
  String _spokenText = '';
  String _agentResponse = '';
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _startVoiceSession();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _startVoiceSession() {
    setState(() {
      _isListening = true;
      _spokenText = 'Listening... Speak in Hindi, English, or any Indian language';
      _agentResponse = '';
    });
    KarmaVoice.speak('dash_talk_desc', directText: 'Listening. How can I help you do good today?', context: context);
  }

  void _processVoiceIntent(String phrase) {
    setState(() {
      _isListening = false;
      _spokenText = phrase;
    });

    final lower = phrase.toLowerCase();
    if (lower.contains('garbage') || lower.contains('कचरा') || lower.contains('report') || lower.contains('problem') || lower.contains('समस्या')) {
      _agentResponse = 'Routing to Report a Local Problem...';
      KarmaVoice.speak('dash_action_report', directText: 'Opening report screen', context: context);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) {
          Navigator.pop(context);
          Navigator.pushNamed(context, AppRoutes.reportAbuse);
        }
      });
    } else if (lower.contains('wish') || lower.contains('इच्छा') || lower.contains('help') || lower.contains('मदद')) {
      _agentResponse = 'Opening Community Wishes...';
      KarmaVoice.speak('dash_action_wish', directText: 'Opening wishes', context: context);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) {
          Navigator.pop(context);
          Navigator.pushNamed(context, AppRoutes.wishes);
        }
      });
    } else if (lower.contains('karma') || lower.contains('passport') || lower.contains('कर्म') || lower.contains('balance') || lower.contains('score')) {
      _agentResponse = 'Opening your Karma Passport...';
      KarmaVoice.speak('dash_karma', directText: 'Opening your profile passport', context: context);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) {
          Navigator.pop(context);
          Navigator.pushNamed(context, AppRoutes.profileDetail);
        }
      });
    } else {
      _agentResponse = 'Searching for "$phrase"...';
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) {
          Navigator.pop(context);
          Navigator.pushNamed(context, AppRoutes.search, arguments: phrase);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Voice Avatar Animation
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              final scale = _isListening ? 1.0 + (_animController.value * 0.15) : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B074).withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00B074).withOpacity(0.6),
                      width: 2.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.mic_rounded, size: 36, color: Color(0xFF00B074)),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          Text(
            AppLocalizations.translateWithContext(context, 'dash_talk_mic', defaultValue: '🎙️ Talk to Karma'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            _isListening
                ? AppLocalizations.translateWithContext(context, 'dash_talk_desc', defaultValue: 'Speak in Hindi, English, or any Indian language')
                : _spokenText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.grey.shade600,
            ),
          ),

          if (_agentResponse.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF00B074).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _agentResponse,
                style: const TextStyle(color: Color(0xFF00B074), fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),

          // Quick Voice Suggestion Chips (accessible for all literacy levels)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildVoiceChip(AppLocalizations.translateWithContext(context, 'talk_where_can_do', defaultValue: '🌱 Where can I do good?'), 'Find deeds nearby'),
              _buildVoiceChip(AppLocalizations.translateWithContext(context, 'talk_report_garbage', defaultValue: '🔎 Report garbage / कचरा'), 'Report problem'),
              _buildVoiceChip(AppLocalizations.translateWithContext(context, 'talk_how_wish', defaultValue: '✨ How to make a wish?'), 'Make a wish'),
              _buildVoiceChip(AppLocalizations.translateWithContext(context, 'talk_my_karma', defaultValue: '📊 What is my Karma?'), 'Check passport'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceChip(String text, String intent) {
    return ActionChip(
      label: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      backgroundColor: const Color(0xFF00B074).withOpacity(0.08),
      side: BorderSide(color: const Color(0xFF00B074).withOpacity(0.2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () => _processVoiceIntent(intent),
    );
  }
}
