import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../models/user_profile.dart';
import '../../services/voice_service.dart';
import 'language_hub_modal.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          _buildCategoryHeader('ACCESSIBILITY & VOICE'),
          if (user != null) ...[
            ListTile(
              leading: const Icon(Icons.accessibility_new_rounded),
              title: const Text('App Interface Mode'),
              subtitle: Text(user.interfaceMode.name.toUpperCase()),
              trailing: DropdownButton<AppInterfaceMode>(
                value: user.interfaceMode,
                underline: const SizedBox(),
                items: AppInterfaceMode.values.map((mode) {
                  return DropdownMenuItem(
                    value: mode,
                    child: Text(mode == AppInterfaceMode.simple
                        ? 'Simple Mode 👵'
                        : mode == AppInterfaceMode.standard
                            ? 'Standard Mode ⚡'
                            : 'Professional 🧑‍💼'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    final updated = user.copyWith(interfaceMode: val);
                    authProvider.updateLocalUserProfile(updated);
                    KarmaVoice.speak('do_good', directText: 'Interface changed to ${val.name} mode', context: context);
                  }
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.translate_rounded),
              title: const Text('Voice Language'),
              subtitle: Text(user.preferredLanguage),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => LanguageHubModal.show(context),
            ),
          ],
          ListTile(
            leading: const Icon(Icons.volume_up_rounded),
            title: const Text('Voice Guidance'),
            subtitle: const Text('Hear button descriptions and cues on tap'),
            trailing: Switch(
              value: !KarmaVoice.isMuted,
              onChanged: (val) {
                KarmaVoice.isMuted = !val;
                if (user != null) {
                  authProvider.updateLocalUserProfile(user.copyWith());
                }
              },
            ),
          ),
          const Divider(),
          _buildCategoryHeader('GENERAL SETTINGS'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme Selection'),
            subtitle: const Text('Light Mode / Dark Mode / System'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint_rounded),
            title: const Text('Biometric Security'),
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_none_rounded),
            title: const Text('Push Notifications'),
            trailing: Switch(value: false, onChanged: (_) {}),
          ),
          const Divider(),
          _buildCategoryHeader('SUPPORT & COMPLIANCE'),
          ListTile(
            leading: const Icon(Icons.report_problem_outlined),
            title: const Text('Report Abuse / Fake Submission'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.pushNamed(context, AppRoutes.reportAbuse),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline_rounded),
            title: const Text('Help & FAQ Center'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.pushNamed(context, AppRoutes.help),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('About Proof of Good'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.pushNamed(context, AppRoutes.about),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text('Logout Passport', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () async {
              final navigator = Navigator.of(context);
              await Provider.of<AuthProvider>(context, listen: false).logout();
              navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 1.2),
      ),
    );
  }
}
