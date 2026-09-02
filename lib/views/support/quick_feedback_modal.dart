import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';

class QuickFeedbackModal extends StatefulWidget {
  const QuickFeedbackModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const QuickFeedbackModal(),
    );
  }

  @override
  State<QuickFeedbackModal> createState() => _QuickFeedbackModalState();
}

class _QuickFeedbackModalState extends State<QuickFeedbackModal> {
  String? _selectedRating;
  final _commentController = TextEditingController();
  bool _submitted = false;

  final List<Map<String, String>> _options = [
    {'key': 'fb_good', 'emoji': '👍', 'label': 'Good'},
    {'key': 'fb_difficult', 'emoji': '👎', 'label': 'Difficult'},
    {'key': 'fb_bug', 'emoji': '🐛', 'label': 'Problem'},
    {'key': 'fb_idea', 'emoji': '💡', 'label': 'Idea'},
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (_selectedRating == null) return;
    setState(() {
      _submitted = true;
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.translateWithContext(context, 'fb_thank_you', defaultValue: 'Thank you! Your feedback helps everyone.')),
            backgroundColor: const Color(0xFF00B074),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (_submitted) ...[
            const Icon(Icons.check_circle_rounded, color: Color(0xFF00B074), size: 54),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.translateWithContext(context, 'fb_thank_you', defaultValue: 'Thank you! Your feedback helps everyone.'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 16),
          ] else ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B074).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('💬', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.translateWithContext(context, 'fb_title', defaultValue: 'Help Us Improve Karma Grid'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        AppLocalizations.translateWithContext(context, 'fb_subtitle', defaultValue: 'Share feedback in under 10 seconds'),
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 4 One-tap categories
            Row(
              children: _options.map((opt) {
                final isSelected = _selectedRating == opt['label'];
                final localizedLabel = AppLocalizations.translateWithContext(context, opt['key']!, defaultValue: opt['label']!);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        setState(() {
                          _selectedRating = opt['label'];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF00B074).withOpacity(0.16)
                              : (isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF00B074) : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(opt['emoji']!, style: const TextStyle(fontSize: 22)),
                            const SizedBox(height: 4),
                            Text(
                              localizedLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? const Color(0xFF00B074) : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _commentController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: AppLocalizations.translateWithContext(context, 'fb_text_hint', defaultValue: 'Optional: tell us what happened...'),
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00B074))),
              ),
            ),
            const SizedBox(height: 18),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B074),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _selectedRating != null ? _submitFeedback : null,
              child: Text(
                AppLocalizations.translateWithContext(context, 'fb_submit', defaultValue: 'Submit Feedback (10s)'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
