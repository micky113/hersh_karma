import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../models/user_profile.dart';
import '../../services/voice_service.dart';
import '../../services/gemini_vision_service.dart';
import '../../core/config/ai_config.dart';
import 'language_hub_modal.dart';
import '../../core/localization/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricEnabled = true;
  bool _pushNotificationsEnabled = true;
  String _selectedTheme = 'System';

  void _showThemeSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Theme Selection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 12),
              RadioListTile<String>(
                title: const Text('Light Mode ☀️'),
                value: 'Light',
                groupValue: _selectedTheme,
                onChanged: (val) {
                  setState(() => _selectedTheme = val!);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Theme set to Light Mode')),
                  );
                },
              ),
              RadioListTile<String>(
                title: const Text('Dark Mode 🌙'),
                value: 'Dark',
                groupValue: _selectedTheme,
                onChanged: (val) {
                  setState(() => _selectedTheme = val!);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Theme set to Dark Mode')),
                  );
                },
              ),
              RadioListTile<String>(
                title: const Text('System Default ⚙️'),
                value: 'System',
                groupValue: _selectedTheme,
                onChanged: (val) {
                  setState(() => _selectedTheme = val!);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Theme set to System Default')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGeminiConfigDialog(BuildContext context) {
    final keyController = TextEditingController(text: AiConfig.apiKey);
    String selectedModel = AiConfig.modelName;
    bool isTesting = false;
    String? testResult;
    bool? testSuccess;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.purple),
              SizedBox(width: 8),
              Text('Gemini Vision AI Engine', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configure your Google Gemini Multimodal API key for real-time Before/After evidence analysis and scoring.',
                  style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.3),
                ),
                const SizedBox(height: 14),
                const Text('Gemini API Key', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: keyController,
                  obscureText: false,
                  decoration: InputDecoration(
                    hintText: 'Enter API Key (AQ.Ab8R... / AIza...)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => keyController.clear(),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Multimodal Vision Model', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedModel,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'gemini-1.5-flash', child: Text('gemini-1.5-flash (Fast & Low Cost)')),
                    DropdownMenuItem(value: 'gemini-2.0-flash', child: Text('gemini-2.0-flash (Next Gen Flash)')),
                    DropdownMenuItem(value: 'gemini-1.5-pro', child: Text('gemini-1.5-pro (Deep Reasoning)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedModel = val);
                    }
                  },
                ),
                const SizedBox(height: 14),
                if (testResult != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (testSuccess == true ? Colors.green : Colors.red).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: (testSuccess == true ? Colors.green : Colors.red).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          testSuccess == true ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                          color: testSuccess == true ? Colors.green : Colors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            testResult!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: testSuccess == true ? Colors.green.shade800 : Colors.red.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await AiConfig.resetToDefault();
                keyController.text = AiConfig.defaultApiKey;
                setDialogState(() {
                  selectedModel = AiConfig.defaultModel;
                  testResult = 'Reset to platform default API key.';
                  testSuccess = true;
                });
                setState(() {});
              },
              child: const Text('Reset Default', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            OutlinedButton(
              onPressed: isTesting
                  ? null
                  : () async {
                      setDialogState(() {
                        isTesting = true;
                        testResult = 'Testing API key connection...';
                        testSuccess = null;
                      });

                      final success = await GeminiVisionService.testApiKey(keyController.text);

                      setDialogState(() {
                        isTesting = false;
                        testSuccess = success;
                        testResult = success
                            ? '✅ Connected! Gemini API key is valid and responsive.'
                            : '⚠️ Connection check failed. Check key format or network.';
                      });
                    },
              child: isTesting
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Test Connection', style: TextStyle(fontSize: 12)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B074),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await AiConfig.setApiKey(keyController.text);
                await AiConfig.setModelName(selectedModel);
                if (mounted) {
                  setState(() {});
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✨ Gemini Vision AI settings saved successfully!'),
                      backgroundColor: Color(0xFF00B074),
                    ),
                  );
                }
              },
              child: const Text('Save Settings', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAdminAccess(UserProfile? user) {
    // Check if user has admin/governance permissions
    final isAdminUser = user != null &&
        (user.role == UserRole.ngo ||
            user.role == UserRole.institution ||
            user.role == UserRole.government ||
            user.email == 'governance@karma.org' ||
            user.email.contains('admin'));

    if (isAdminUser) {
      Navigator.pushNamed(context, AppRoutes.admin);
      return;
    }

    // Passcode gate for developer / authorized staff access
    final passController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF00B074)),
            SizedBox(width: 8),
            Text('Admin Center Authorization', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter administrator access code or governance key to enter the Trust Center:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passController,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Passcode (e.g. 1234 or admin key)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B074),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (passController.text.trim() == '1234' || passController.text.trim() == 'admin' || passController.text.trim() == 'karma') {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRoutes.admin);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid access code. Authorization required.'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Verify & Enter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.translateWithContext(context, 'settings_title', defaultValue: 'Settings'))),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          _buildCategoryHeader(AppLocalizations.translateWithContext(context, 'settings_acc_voice', defaultValue: 'ACCESSIBILITY & VOICE')),
          if (user != null) ...[
            ListTile(
              leading: const Icon(Icons.accessibility_new_rounded),
              title: Text(AppLocalizations.translateWithContext(context, 'settings_app_mode', defaultValue: 'App Interface Mode')),
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
              title: Text(AppLocalizations.translateWithContext(context, 'settings_voice_lang', defaultValue: 'Voice Language')),
              subtitle: Text(user.preferredLanguage),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => LanguageHubModal.show(context),
            ),
          ],
          ListTile(
            leading: const Icon(Icons.volume_up_rounded),
            title: Text(AppLocalizations.translateWithContext(context, 'settings_voice_guidance', defaultValue: 'Voice Guidance')),
            subtitle: Text(AppLocalizations.translateWithContext(context, 'settings_voice_guidance_sub', defaultValue: 'Hear button descriptions and cues on tap')),
            trailing: Switch(
              value: !KarmaVoice.isMuted,
              onChanged: (val) {
                setState(() {
                  KarmaVoice.isMuted = !val;
                });
                if (user != null) {
                  authProvider.updateLocalUserProfile(user.copyWith());
                }
              },
            ),
          ),
          const Divider(),
          _buildCategoryHeader(AppLocalizations.translateWithContext(context, 'settings_general', defaultValue: 'GENERAL SETTINGS')),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(AppLocalizations.translateWithContext(context, 'settings_theme', defaultValue: 'Theme Selection')),
            subtitle: Text('Current: $_selectedTheme'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: _showThemeSelector,
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint_rounded),
            title: Text(AppLocalizations.translateWithContext(context, 'settings_biometric', defaultValue: 'Biometric Security')),
            subtitle: Text(_biometricEnabled ? 'Enabled (Instant Unlock)' : 'Disabled'),
            trailing: Switch(
              value: _biometricEnabled,
              onChanged: (val) {
                setState(() => _biometricEnabled = val);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Biometric security ${val ? "enabled" : "disabled"}.')),
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_none_rounded),
            title: Text(AppLocalizations.translateWithContext(context, 'settings_push_notif', defaultValue: 'Push Notifications')),
            subtitle: Text(_pushNotificationsEnabled ? 'Active' : 'Muted'),
            trailing: Switch(
              value: _pushNotificationsEnabled,
              onChanged: (val) {
                setState(() => _pushNotificationsEnabled = val);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Push notifications ${val ? "enabled" : "disabled"}.')),
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF00B074)),
            title: Text(AppLocalizations.translateWithContext(context, 'settings_admin', defaultValue: 'Admin & Trust Center'), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00B074))),
            subtitle: Text(AppLocalizations.translateWithContext(context, 'settings_admin_sub', defaultValue: 'Ecosystem oversight, verification queue & audit log')),
            trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF00B074)),
            onTap: () => _handleAdminAccess(user),
          ),
          const Divider(),
          _buildCategoryHeader('AI & MULTIMODAL VERIFICATION'),
          ListTile(
            leading: const Icon(Icons.auto_awesome, color: Colors.purple),
            title: const Text('Gemini Vision AI Engine', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Model: ${AiConfig.modelName} • Key: ${AiConfig.maskedApiKey}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Configure', style: TextStyle(color: Colors.purple, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            onTap: () => _showGeminiConfigDialog(context),
          ),
          const Divider(),
          _buildCategoryHeader(AppLocalizations.translateWithContext(context, 'settings_support', defaultValue: 'SUPPORT & COMPLIANCE')),
          ListTile(
            leading: const Icon(Icons.report_problem_outlined),
            title: Text(AppLocalizations.translateWithContext(context, 'settings_report_abuse', defaultValue: 'Report Abuse / Fake Submission')),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.pushNamed(context, AppRoutes.reportAbuse),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline_rounded),
            title: Text(AppLocalizations.translateWithContext(context, 'settings_help_faq', defaultValue: 'Help & FAQ Center')),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.pushNamed(context, AppRoutes.help),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(AppLocalizations.translateWithContext(context, 'settings_about', defaultValue: 'About Proof of Good')),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.pushNamed(context, AppRoutes.about),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: Text(AppLocalizations.translateWithContext(context, 'settings_logout', defaultValue: 'Logout Passport'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
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
