import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/voice_service.dart';

class LanguageHubModal {
  static const List<Map<String, String>> globalLanguages = [
    {'name': 'English', 'native': 'English'},
    {'name': 'Mandarin', 'native': '中文 — Mandarin Chinese'},
    {'name': 'Hindi', 'native': 'हिन्दी — Hindi'},
    {'name': 'Spanish', 'native': 'Español — Spanish'},
    {'name': 'Arabic', 'native': 'العربية — Arabic'},
    {'name': 'French', 'native': 'Français — French'},
    {'name': 'Bengali', 'native': 'বাংলা — Bengali'},
    {'name': 'Portuguese', 'native': 'Português — Portuguese'},
    {'name': 'Russian', 'native': 'Русский — Russian'},
    {'name': 'Urdu', 'native': 'اردו — Urdu'},
    {'name': 'Indonesian', 'native': 'Bahasa Indonesia — Indonesian'},
    {'name': 'German', 'native': 'Deutsch — German'},
    {'name': 'Hebrew', 'native': 'עברית — Hebrew'},
  ];

  static const List<Map<String, String>> indianLanguages = [
    {'name': 'Assamese', 'native': 'অসমীয়া — Assamese'},
    {'name': 'Bengali', 'native': 'বাংলা — Bengali'},
    {'name': 'Gujarati', 'native': 'ગુજરાતી — Gujarati'},
    {'name': 'Hindi', 'native': 'हिन्दी — Hindi'},
    {'name': 'Kannada', 'native': 'ಕನ್ನಡ — Kannada'},
    {'name': 'Kashmiri', 'native': 'कश्मीरी — Kashmiri'},
    {'name': 'Malayalam', 'native': 'മലയാളം — Malayalam'},
    {'name': 'Marathi', 'native': 'मराठी — Marathi'},
    {'name': 'Nepali', 'native': 'नेपाली — Nepali'},
    {'name': 'Odia', 'native': 'ଓଡ଼ିଆ — Odia'},
    {'name': 'Punjabi', 'native': 'ਪੰਜਾਬੀ — Punjabi'},
    {'name': 'Sanskrit', 'native': 'संस्कृतם — Sanskrit'},
    {'name': 'Sindhi', 'native': 'سنڌי — Sindhi'},
    {'name': 'Tamil', 'native': 'தமிழ் — Tamil'},
    {'name': 'Telugu', 'native': 'తెలుగు — Telugu'},
    {'name': 'Urdu', 'native': 'اردו — Urdu'},
    {'name': 'Maithili', 'native': 'मैथिली — Maithili'},
    {'name': 'Konkani', 'native': 'कोंकणी — Konkani'},
    {'name': 'Bodo', 'native': 'बोडो — Bodo'},
    {'name': 'Dogri', 'native': 'डोगरी — Dogri'},
    {'name': 'Santali', 'native': 'संथाली — Santali'},
    {'name': 'Manipuri', 'native': 'মৈতৈলোন — Manipuri/Meitei'},
  ];

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final authProvider = Provider.of<AuthProvider>(context);
        final user = authProvider.currentUser;

        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.6,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    '🌐 Choose Your Language / Choose language',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildHeader('🌍 GLOBAL LANGUAGES'),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.4,
                        ),
                        itemCount: globalLanguages.length,
                        itemBuilder: (context, idx) {
                          final lang = globalLanguages[idx];
                          return _buildLangBtn(context, lang['name']!, lang['native']!, user, authProvider);
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildHeader('🇮🇳 INDIAN LANGUAGES (8TH SCHEDULE)'),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.4,
                        ),
                        itemCount: indianLanguages.length,
                        itemBuilder: (context, idx) {
                          final lang = indianLanguages[idx];
                          return _buildLangBtn(context, lang['name']!, lang['native']!, user, authProvider);
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey, letterSpacing: 1.1),
      ),
    );
  }

  static Widget _buildLangBtn(
    BuildContext context,
    String name,
    String nativeText,
    dynamic user,
    AuthProvider authProvider,
  ) {
    final isSelected = KarmaVoice.currentLanguage.toLowerCase() == name.toLowerCase();

    return InkWell(
      onTap: () {
        KarmaVoice.currentLanguage = name;
        if (user != null) {
          final updated = user.copyWith(preferredLanguage: name);
          authProvider.updateLocalUserProfile(updated);
        }
        KarmaVoice.speak('do_good', context: context);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00B074).withOpacity(0.08) : Colors.grey[50],
          border: Border.all(
            color: isSelected ? const Color(0xFF00B074) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                nativeText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF00B074) : Colors.black87,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.volume_up, size: 18, color: isSelected ? const Color(0xFF00B074) : Colors.grey[600]),
              onPressed: () {
                KarmaVoice.speak('', directText: nativeText.split('—').first.trim(), context: context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
