import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/karma_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/wish.dart';

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
        title: const Text('💫 Make a Wish'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Describe Your Wish',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Wishes should be meaningful achievements. Direct cash transfers are disabled; funds are routed to verified providers.',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Wish Title',
                  hintText: 'e.g. Learn guitar, Get clean drinking water...',
                  prefixIcon: Icon(Icons.star_outline_rounded),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter a title for your wish' : null,
              ),
              const SizedBox(height: 20),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Why is this wish important to you?',
                  hintText: 'Provide details. What do you need? Who will it help?',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 56.0),
                    child: Icon(Icons.description_outlined),
                  ),
                ),
                validator: (val) => val == null || val.trim().length < 15
                    ? 'Provide a detailed description (min 15 characters)'
                    : null,
              ),
              const SizedBox(height: 20),

              // Category dropdown
              DropdownButtonFormField<WishCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: WishCategory.values.map((cat) {
                  return DropdownMenuItem<WishCategory>(
                    value: cat,
                    child: Row(
                      children: [
                        Text(cat.icon),
                        const SizedBox(width: 8),
                        Text(cat.label),
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
                decoration: const InputDecoration(
                  labelText: 'Wish Verification Level',
                  prefixIcon: Icon(Icons.verified_user_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('🟢 Level 1 — Personal/Experience')),
                  DropdownMenuItem(value: 2, child: Text('🔵 Level 2 — Material (needs proof)')),
                  DropdownMenuItem(value: 3, child: Text('🟠 Level 3 — High-Value (KYC required)')),
                  DropdownMenuItem(value: 4, child: Text('🔴 Level 4 — Sensitive/High-Risk')),
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
                decoration: const InputDecoration(
                  labelText: 'Privacy Setting',
                  prefixIcon: Icon(Icons.visibility_outlined),
                ),
                items: PrivacyLevel.values.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(level.label),
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
                decoration: const InputDecoration(
                  labelText: 'Fulfillment / Routing Type',
                  prefixIcon: Icon(Icons.payment_outlined),
                ),
                items: SponsorshipType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.label),
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
                  decoration: const InputDecoration(
                    labelText: 'Verified Retailer / Provider Name',
                    hintText: 'e.g. Croma Music Store, Apex Academy, WaterAid NGO',
                    prefixIcon: Icon(Icons.storefront_outlined),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Enter a verified provider to receive funds'
                      : null,
                ),
                const SizedBox(height: 20),

                // Karma target goal
                TextFormField(
                  controller: _targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Desired Karma Crowdfund Target',
                    hintText: 'e.g. 500, 1000, 2000',
                    prefixIcon: Icon(Icons.favorite_border_rounded),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter a Karma goal';
                    final parsed = int.tryParse(val.trim());
                    if (parsed == null || parsed <= 0) return 'Enter a valid positive number';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Evidence documents input
              TextFormField(
                controller: _evidenceController,
                decoration: const InputDecoration(
                  labelText: 'Evidence / Reference Documents (Optional URLs)',
                  hintText: 'Comma separated links: e.g. admission_receipt.pdf',
                  prefixIcon: Icon(Icons.attachment_outlined),
                ),
              ),
              const SizedBox(height: 20),

              // Trust & Safety Toggle simulations
              Text(
                '🛡️ Safety Controls Verification',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              SwitchListTile(
                title: const Text('Simulate KYC Identity Verified Account', style: TextStyle(fontSize: 12)),
                subtitle: const Text('Required for Level 3 and 4 wishes', style: TextStyle(fontSize: 10)),
                value: _isIdentityVerified,
                onChanged: (val) {
                  setState(() {
                    _isIdentityVerified = val;
                  });
                },
              ),

              SwitchListTile(
                title: const Text('Underage minor account holder (under 18)', style: TextStyle(fontSize: 12)),
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
                  title: const Text('Verified Parent/Guardian consent document attached', style: TextStyle(fontSize: 12)),
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
                            const Text(
                              '🤖 AI Safety Verification Engine',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Wishes undergo automated scans for prohibited activities, weapons, drug requests, begging phrases, and collision networks. Suspicious cases are routed to human review.',
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
                  child: const Text(
                    'Generate Wish Plan & Submit',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
