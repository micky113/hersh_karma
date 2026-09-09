import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';

class LanguagesView extends StatelessWidget {
  const LanguagesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final supported = AppLocalizations.supportedLanguages;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('22 Indic Scheduled Languages & RTL Coverage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 2),
                  Text(
                    'Full coverage across all 22 Eighth Schedule Indian languages + global RTL (Hebrew, Arabic, Urdu).',
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: supported.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final lang = supported[i];
                  final isRtl = AppLocalizations.isRtlLanguage(lang['code']!);

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B074).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        lang['code']!.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF00B074)),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          '${lang['name']} (${lang['native']})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        if (isRtl)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('RTL LAYOUT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.purple)),
                          ),
                      ],
                    ),
                    subtitle: Text('Script: ${lang['script']} • Coverage: 100% Core Keys', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    trailing: const Icon(Icons.check_circle_rounded, color: Color(0xFF00B074), size: 18),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
