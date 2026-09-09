import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/karma_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/wish.dart';
import '../../core/localization/app_localizations.dart';

class MakeWishScreen extends StatefulWidget {
  const MakeWishScreen({super.key});

  @override
  State<MakeWishScreen> createState() => _MakeWishScreenState();
}

class _MakeWishScreenState extends State<MakeWishScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _targetController = TextEditingController(text: '1000');
  final _retailerController = TextEditingController();
  final _evidenceController = TextEditingController();
  
  WishCategory _selectedCategory = WishCategory.experience;
  int _verificationLevel = 1;
  PrivacyLevel _privacyLevel = PrivacyLevel.public;
  SponsorshipType _sponsorshipType = SponsorshipType.volunteerService;
  
  bool _isMinor = false;
  bool _isIdentityVerified = false;
  bool _ageConsentVerified = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _targetController.dispose();
    _retailerController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final karmaProvider = Provider.of<KarmaProvider>(context, listen: false);
    final target = int.tryParse(_targetController.text.trim()) ?? 1000;

    final List<String> docs = _evidenceController.text.trim().isNotEmpty
        ? _evidenceController.text.split(',').map((s) => s.trim()).toList()
        : [];

    final success = await karmaProvider.submitWish(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory,
      karmaTarget: _sponsorshipType == SponsorshipType.volunteerService ? 0 : target,
      verificationLevel: _verificationLevel,
      privacyLevel: _privacyLevel,
      evidenceDocumentUrls: docs,
      isIdentityVerified: _isIdentityVerified,
      ageConsentVerified: _ageConsentVerified,
      sponsorshipType: _sponsorshipType,
      retailerName: _retailerController.text.trim().isNotEmpty ? _retailerController.text.trim() : null,
      isMinor: _isMinor,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Wish submitted successfully! AI generated your Wish Plan.'),
          backgroundColor: Color(0xFF00B074),
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(karmaProvider.error ?? 'Submission failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final karmaProvider = Provider.of<KarmaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.translateWithContext(context, 'Make a Wish 💫', defaultValue: '💫 Make a Wish')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLocalizations.translateWithContext(context, 'Describe Your Wish', defaultValue: 'Describe Your Wish'),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.translateWithContext(context, 'Wishes should be meaningful achievements. Direct cash transfers are disabled; funds are routed to verified providers.', defaultValue: 'Wishes should be meaningful achievements. Direct cash transfers are disabled; funds are routed to verified providers.'),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.translateWithContext(context, 'Wish Title', defaultValue: 'Wish Title'),
                  hintText: AppLocalizations.translateWithContext(context, 'e.g. Learn guitar, Get clean drinking water...', defaultValue: 'e.g. Learn guitar, Get clean drinking water...'),
                  prefixIcon: const Icon(Icons.star_outline_rounded),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? AppLocalizations.translateWithContext(context, 'Enter a title for your wish', defaultValue: 'Enter a title for your wish') : null,
              ),
              const SizedBox(height: 20),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: AppLocalizations.translateWithContext(context, 'Why is this wish important to you?', defaultValue: 'Why is this wish important to you?'),
                  hintText: AppLocalizations.translateWithContext(context, 'Provide details. What do you need? Who will it help?', defaultValue: 'Provide details. What do you need? Who will it help?'),
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 56.0),
                    child: Icon(Icons.description_outlined),
                  ),
                ),
                validator: (val) => val == null || val.trim().length < 15
                    ? AppLocalizations.translateWithContext(context, 'Provide a detailed description (min 15 characters)', defaultValue: 'Provide a detailed description (min 15 characters)')
                    : null,
              ),
              const SizedBox(height: 20),

              // Category dropdown
              DropdownButtonFormField<WishCategory>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: AppLocalizations.translateWithContext(context, 'Category', defaultValue: 'Category'),
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
                items: WishCategory.values.map((cat) {
                  return DropdownMenuItem<WishCategory>(
                    value: cat,
                    child: Row(
                      children: [
                        Text(cat.icon),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.translateWithContext(context, cat.label, defaultValue: cat.label)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCategory = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Verification Level dropdown
              DropdownButtonFormField<int>(
                value: _verificationLevel,
                decoration: InputDecoration(
                  labelText: AppLocalizations.translateWithContext(context, 'Wish Verification Level', defaultValue: 'Wish Verification Level'),
                  prefixIcon: const Icon(Icons.verified_user_outlined),
                ),
                items: [
                  DropdownMenuItem(value: 1, child: Text(AppLocalizations.translateWithContext(context, '🟢 Level 1 — Personal/Experience', defaultValue: '🟢 Level 1 — Personal/Experience'))),
                  DropdownMenuItem(value: 2, child: Text(AppLocalizations.translateWithContext(context, '🔵 Level 2 — Material (needs proof)', defaultValue: '🔵 Level 2 — Material (needs proof)'))),
                  DropdownMenuItem(value: 3, child: Text(AppLocalizations.translateWithContext(context, '🟠 Level 3 — High-Value (KYC required)', defaultValue: '🟠 Level 3 — High-Value (KYC required)'))),
                  DropdownMenuItem(value: 4, child: Text(AppLocalizations.translateWithContext(context, '🔴 Level 4 — Sensitive/High-Risk', defaultValue: '🔴 Level 4 — Sensitive/High-Risk'))),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _verificationLevel = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Privacy Level dropdown
              DropdownButtonFormField<PrivacyLevel>(
                value: _privacyLevel,
                decoration: InputDecoration(
                  labelText: AppLocalizations.translateWithContext(context, 'Privacy Setting', defaultValue: 'Privacy Setting'),
                  prefixIcon: const Icon(Icons.visibility_outlined),
                ),
                items: PrivacyLevel.values.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(AppLocalizations.translateWithContext(context, level.label, defaultValue: level.label)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _privacyLevel = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Sponsorship Type dropdown
              DropdownButtonFormField<SponsorshipType>(
                value: _sponsorshipType,
                decoration: InputDecoration(
                  labelText: AppLocalizations.translateWithContext(context, 'Fulfillment / Routing Type', defaultValue: 'Fulfillment / Routing Type'),
                  prefixIcon: const Icon(Icons.payment_outlined),
                ),
                items: SponsorshipType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(AppLocalizations.translateWithContext(context, type.label, defaultValue: type.label)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _sponsorshipType = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Retailer name field (shown if monetary)
              if (_sponsorshipType != SponsorshipType.volunteerService) ...[
                TextFormField(
                  controller: _retailerController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.translateWithContext(context, 'Verified Retailer / Provider Name', defaultValue: 'Verified Retailer / Provider Name'),
                    hintText: AppLocalizations.translateWithContext(context, 'e.g. Croma Music Store, Apex Academy, WaterAid NGO', defaultValue: 'e.g. Croma Music Store, Apex Academy, WaterAid NGO'),
                    prefixIcon: const Icon(Icons.storefront_outlined),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? AppLocalizations.translateWithContext(context, 'Enter a verified provider to receive funds', defaultValue: 'Enter a verified provider to receive funds')
                      : null,
                ),
                const SizedBox(height: 20),

                // Karma target goal
                TextFormField(
                  controller: _targetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.translateWithContext(context, 'Desired Karma Crowdfund Target', defaultValue: 'Desired Karma Crowdfund Target'),
                    hintText: AppLocalizations.translateWithContext(context, 'e.g. 500, 1000, 2000', defaultValue: 'e.g. 500, 1000, 2000'),
                    prefixIcon: const Icon(Icons.favorite_border_rounded),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return AppLocalizations.translateWithContext(context, 'Enter a Karma goal', defaultValue: 'Enter a Karma goal');
                    final parsed = int.tryParse(val.trim());
                    if (parsed == null || parsed <= 0) return AppLocalizations.translateWithContext(context, 'Enter a valid positive number', defaultValue: 'Enter a valid positive number');
                    return null;
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Evidence documents input
              TextFormField(
                controller: _evidenceController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.translateWithContext(context, 'Evidence / Reference Documents (Optional URLs)', defaultValue: 'Evidence / Reference Documents (Optional URLs)'),
                  hintText: AppLocalizations.translateWithContext(context, 'Comma separated links: e.g. admission_receipt.pdf', defaultValue: 'Comma separated links: e.g. admission_receipt.pdf'),
                  prefixIcon: const Icon(Icons.attachment_outlined),
                ),
              ),
              const SizedBox(height: 20),

              // Trust & Safety Toggle simulations
              Text(
                AppLocalizations.translateWithContext(context, '🛡️ Safety Controls Verification', defaultValue: '🛡️ Safety Controls Verification'),
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              SwitchListTile(
                title: Text(AppLocalizations.translateWithContext(context, 'Simulate KYC Identity Verified Account', defaultValue: 'Simulate KYC Identity Verified Account'), style: const TextStyle(fontSize: 12)),
                subtitle: Text(AppLocalizations.translateWithContext(context, 'Required for Level 3 and 4 wishes', defaultValue: 'Required for Level 3 and 4 wishes'), style: const TextStyle(fontSize: 10)),
                value: _isIdentityVerified,
                onChanged: (val) {
                  setState(() {
                    _isIdentityVerified = val;
                  });
                },
              ),

              SwitchListTile(
                title: Text(AppLocalizations.translateWithContext(context, 'Underage minor account holder (under 18)', defaultValue: 'Underage minor account holder (under 18)'), style: const TextStyle(fontSize: 12)),
                value: _isMinor,
                onChanged: (val) {
                  setState(() {
                    _isMinor = val;
                    if (!val) _ageConsentVerified = false;
                  });
                },
              ),

              if (_isMinor)
                SwitchListTile(
                  title: Text(AppLocalizations.translateWithContext(context, 'Verified Parent/Guardian consent document attached', defaultValue: 'Verified Parent/Guardian consent document attached'), style: const TextStyle(fontSize: 12)),
                  value: _ageConsentVerified,
                  onChanged: (val) {
                    setState(() {
                      _ageConsentVerified = val;
                    });
                  },
                ),
              const SizedBox(height: 24),

              // AI plan card preview
              Card(
                color: theme.colorScheme.primary.withOpacity(0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.psychology_rounded, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.translateWithContext(context, '🤖 AI Safety Verification Engine', defaultValue: '🤖 AI Safety Verification Engine'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.translateWithContext(context, 'Wishes undergo automated scans for prohibited activities, weapons, drug requests, begging phrases, and collision networks. Suspicious cases are routed to human review.', defaultValue: 'Wishes undergo automated scans for prohibited activities, weapons, drug requests, begging phrases, and collision networks. Suspicious cases are routed to human review.'),
                              style: TextStyle(color: Colors.grey[750], fontSize: 11, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              if (karmaProvider.isSubmitting)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8F00),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    AppLocalizations.translateWithContext(context, 'Generate Wish Plan & Submit', defaultValue: 'Generate Wish Plan & Submit'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
