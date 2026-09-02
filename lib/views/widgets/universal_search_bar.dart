import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/routes/app_routes.dart';
import 'talk_to_karma_modal.dart';

class UniversalSearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  final bool autofocus;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const UniversalSearchBar({
    super.key,
    this.onTap,
    this.autofocus = false,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hint = AppLocalizations.translateWithContext(
      context,
      'dash_search_placeholder',
      defaultValue: '🔎 Search actions, problems, NGOs, schools, wishes...',
    );

    return GestureDetector(
      onTap: onTap ?? () => Navigator.pushNamed(context, AppRoutes.search),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: isDark ? Colors.white60 : Colors.grey.shade600, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hint,
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey.shade500,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => TalkToKarmaModal.show(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B074).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic_rounded, color: Color(0xFF00B074), size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
