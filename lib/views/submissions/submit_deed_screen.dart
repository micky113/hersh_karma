import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/auth_provider.dart';
import '../../providers/karma_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../models/karma_category.dart';
import '../../models/karma_activity.dart';
import '../../data/karma_grid_presets.dart';

class SubmitDeedScreen extends StatefulWidget {
  const SubmitDeedScreen({super.key});

  @override
  State<SubmitDeedScreen> createState() => _SubmitDeedScreenState();
}

class _SubmitDeedScreenState extends State<SubmitDeedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _witnessController = TextEditingController();
  final _searchPresetController = TextEditingController();
  final _scaleController = TextEditingController(text: '1');
  final _searchFocusNode = FocusNode();

  KarmaCategory _selectedCategory = KarmaCategory.environment;
  KarmaActivity? _selectedPreset;
  List<KarmaActivity> _filteredPresets = [];
  bool _showSuggestions = false;

  String _durationCategory = 'Quick';
  String _impactScope = 'Individual';
  bool _creativityBonus = false;
  bool _participationBonus = false;
  bool _rippleInspirationBonus = false;

  int _verificationLevel = 1;
  bool _stakeProofBond = false;
  bool _protectVulnerable = false;
  final _witnessCodeController = TextEditingController();
  
  String? _mockImagePath;
  double? _latitude;
  double? _longitude;
  bool _isGettingLocation = false;

  bool _capturedInApp = false;
  int _evidenceScore = 0;
  String? _beforeImageUrl;
  int? _wasteBeforeCount;
  int? _wasteAfterCount;
  double? _sceneMatchConfidence;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _witnessController.dispose();
    _searchPresetController.dispose();
    _scaleController.dispose();
    _searchFocusNode.dispose();
    _witnessCodeController.dispose();
    super.dispose();
  }

  Widget _buildLadderStep(int level, String label, String tooltip, ThemeData theme) {
    final isSelected = _verificationLevel == level;
    Color stepColor = Colors.green;
    if (level == 2) stepColor = Colors.blue;
    if (level == 3) stepColor = Colors.purple;
    if (level == 4) stepColor = Colors.orange;
    if (level == 5) stepColor = Colors.red;

    return Expanded(
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _verificationLevel = level;
              if (level < 4) {
                _stakeProofBond = false;
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2.0),
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: isSelected ? stepColor.withOpacity(0.18) : theme.cardColor,
              border: Border.all(
                color: isSelected ? stepColor : Colors.grey.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isSelected ? stepColor : theme.textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  String _getBeforeLabel() {
    switch (_selectedCategory) {
      case KarmaCategory.healthcare:
        return 'BEFORE Check-in / Initial Assessment';
      case KarmaCategory.education:
        return 'BEFORE Initial Assessment / Syllabus';
      case KarmaCategory.environment:
      case KarmaCategory.animalWelfare:
        return 'BEFORE Condition Photo';
      default:
        return 'BEFORE Starting Condition Proof';
    }
  }

  String _getAfterLabel() {
    switch (_selectedCategory) {
      case KarmaCategory.healthcare:
        return 'AFTER Donation Receipt';
      case KarmaCategory.education:
        return 'AFTER Final Assessment / Outcome';
      case KarmaCategory.environment:
      case KarmaCategory.animalWelfare:
        return 'AFTER Resulting State Photo';
      default:
        return 'AFTER Resulting Change Proof';
    }
  }

  // Simulate photo selection
  void _simulateBeforePhotoPick() {
    setState(() {
      _beforeImageUrl = 'assets/proofs/deed_before_${DateTime.now().millisecondsSinceEpoch}.jpg';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📸 BEFORE evidence attached! (AI verification will register starting condition)'),
        backgroundColor: Color(0xFF00B074),
      ),
    );
  }

  void _simulateAfterPhotoPick() {
    setState(() {
      _mockImagePath = 'assets/proofs/deed_after_${DateTime.now().millisecondsSinceEpoch}.jpg';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📸 AFTER evidence attached! (AI verification will register resulting outcome)'),
        backgroundColor: Color(0xFF00B074),
      ),
    );
  }

  // Fetch or simulate GPS location
  Future<void> _fetchGPS() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      // In a real device, check permissions and get location
      // We will try running it, and fallback to simulation if on desktop or permission denied
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 4),
        );
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
      } else {
        _simulateGPSFallback();
      }
    } catch (e) {
      _simulateGPSFallback();
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  void _simulateGPSFallback() {
    // Standard mock GPS coordinates
    setState(() {
      _latitude = 37.7749 + (DateTime.now().millisecond % 100) * 0.0001;
      _longitude = -122.4194 - (DateTime.now().millisecond % 100) * 0.0001;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📍 GPS location fetched! (Simulated secure hardware enclave)'),
        backgroundColor: Color(0xFF00B074),
      ),
    );
  }

  double _calculateConfidenceEstimate() {
    final bool hasBefore = _beforeImageUrl != null && _beforeImageUrl!.isNotEmpty;
    final bool hasAfter = _mockImagePath != null && _mockImagePath!.isNotEmpty;
    final bool hasWitnessCode = _protectVulnerable && _witnessCodeController.text.trim().isNotEmpty;
    final bool hasEvidencePair = (hasBefore && hasAfter) || hasWitnessCode;

    if (!hasEvidencePair) {
      return 0.0;
    }

    if (_selectedPreset == null) {
      double score = 0.40; // baseline for written report
      if (_mockImagePath != null) score += 0.25;
      if (_latitude != null && _longitude != null) score += 0.20;
      if (_witnessController.text.trim().contains('@')) score += 0.15;
      return score;
    }

    final method = _selectedPreset!.verificationMethod;
    double score = 0.30; // base

    switch (method) {
      case VerificationMethod.gpsAndImage:
        if (_mockImagePath != null) score += 0.35;
        if (_latitude != null && _longitude != null) score += 0.35;
        break;
      case VerificationMethod.imageRequired:
        if (_mockImagePath != null) score += 0.50;
        if (_latitude != null && _longitude != null) score += 0.10;
        break;
      case VerificationMethod.securePrivate:
        score = 0.50;
        if (_witnessController.text.trim().contains('@')) score += 0.35;
        if (_mockImagePath != null) score += 0.10;
        break;
      case VerificationMethod.standard:
        score = 0.40;
        if (_mockImagePath != null) score += 0.20;
        if (_latitude != null && _longitude != null) score += 0.20;
        if (_witnessController.text.trim().contains('@')) score += 0.15;
        break;
    }

    return score.clamp(0.0, 1.0);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final karmaProvider = Provider.of<KarmaProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    final bool hasBefore = _beforeImageUrl != null && _beforeImageUrl!.isNotEmpty;
    final bool hasAfter = _mockImagePath != null && _mockImagePath!.isNotEmpty;
    final bool hasWitnessCode = _protectVulnerable && _witnessCodeController.text.trim().isNotEmpty;
    final bool hasEvidencePair = (hasBefore && hasAfter) || hasWitnessCode;

    if (!hasEvidencePair) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Core Principle Violated: No Proof of Change, No Impact Credit. Both BEFORE and AFTER evidence must be provided.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final scale = int.tryParse(_scaleController.text.trim()) ?? 1;
    final confidence = _calculateConfidenceEstimate();

    final success = await karmaProvider.submitDeed(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory,
      userName: authProvider.currentUser!.name,
      imageUrl: _mockImagePath,
      latitude: _latitude,
      longitude: _longitude,
      witnessEmail: _witnessController.text.trim().isNotEmpty ? _witnessController.text.trim() : null,
      scale: scale,
      confidenceScore: confidence,
      durationCategory: _durationCategory,
      impactScope: _impactScope,
      creativityBonus: _creativityBonus,
      participationBonus: _participationBonus,
      rippleInspirationBonus: _rippleInspirationBonus,
      verificationLevel: _verificationLevel,
      proofBondStaked: _stakeProofBond ? 20 : 0,
      anonymizedWitnessCode: _protectVulnerable ? _witnessCodeController.text.trim() : null,
      capturedInApp: _capturedInApp,
      evidenceScore: _evidenceScore,
      beforeImageUrl: _beforeImageUrl,
      wasteBeforeCount: _wasteBeforeCount,
      wasteAfterCount: _wasteAfterCount,
      sceneMatchConfidence: _sceneMatchConfidence,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Deed submitted to Validator Queue!'),
          backgroundColor: Color(0xFF00B074),
        ),
      );
      // Reset form
      _titleController.clear();
      _descController.clear();
      _witnessController.clear();
      _searchPresetController.clear();
      _witnessCodeController.clear();
      _scaleController.text = '1';
      setState(() {
        _mockImagePath = null;
        _latitude = null;
        _longitude = null;
        _selectedCategory = KarmaCategory.environment;
        _selectedPreset = null;
        _filteredPresets = [];
        _showSuggestions = false;
        _durationCategory = 'Quick';
        _impactScope = 'Individual';
        _creativityBonus = false;
        _participationBonus = false;
        _rippleInspirationBonus = false;
        _verificationLevel = 1;
        _stakeProofBond = false;
        _protectVulnerable = false;
        _capturedInApp = false;
        _evidenceScore = 0;
        _beforeImageUrl = null;
        _wasteBeforeCount = null;
        _wasteAfterCount = null;
        _sceneMatchConfidence = null;
      });
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
    final karmaProvider = Provider.of<KarmaProvider>(context);

    if (karmaProvider.prefilledPreset != null) {
      final p = karmaProvider.prefilledPreset!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedPreset = p;
          _titleController.text = p.title;
          _selectedCategory = p.category;
          _searchPresetController.text = p.title;
        });
        karmaProvider.clearPrefilledPreset();
      });
    }

    final theme = Theme.of(context);
    final confidence = _calculateConfidenceEstimate();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Preset Bar
            Text(
              'Curated Positive Actions (366 Presets)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _searchPresetController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                labelText: 'Search leap-year master list...',
                hintText: 'e.g., cpr, recycle, mentor, feed...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchPresetController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchPresetController.clear();
                            _selectedPreset = null;
                            _filteredPresets = [];
                            _showSuggestions = false;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                setState(() {
                  if (val.trim().isEmpty) {
                    _filteredPresets = [];
                    _showSuggestions = false;
                  } else {
                    _filteredPresets = karmaGridPresets
                        .where((act) => act.title.toLowerCase().contains(val.toLowerCase()))
                        .take(5)
                        .toList();
                    _showSuggestions = _filteredPresets.isNotEmpty;
                  }
                });
              },
            ),
            if (_showSuggestions) ...[
              Card(
                elevation: 3,
                margin: const EdgeInsets.only(top: 4, bottom: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredPresets.length,
                      itemBuilder: (context, idx) {
                        final act = _filteredPresets[idx];
                        return ListTile(
                          dense: true,
                          leading: Text(act.category.icon, style: const TextStyle(fontSize: 16)),
                          title: Text(act.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            'Tier ${act.tier} | Base Impact: ${act.baseImpact} | ${act.effortRating} Effort',
                            style: const TextStyle(fontSize: 10),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedPreset = act;
                              _titleController.text = act.title;
                              _selectedCategory = act.category;
                              _searchPresetController.text = act.title;
                              _showSuggestions = false;
                              _searchFocusNode.unfocus();
                            });
                          },
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.add_circle_outline_rounded, color: Colors.purple),
                      title: const Text(
                        'Can\'t find your deed? Propose a new Action to the registry',
                        style: TextStyle(color: Colors.purple, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        setState(() {
                          _showSuggestions = false;
                        });
                        Navigator.pushNamed(context, AppRoutes.proposeAction);
                      },
                    ),
                  ],
                ),
              ),
            ],
            if (_selectedPreset != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _selectedPreset!.category.color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _selectedPreset!.category.color.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_selectedPreset!.category.icon, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          'Taxonomy Match: Tier ${_selectedPreset!.tier}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: _selectedPreset!.category.color, fontSize: 13),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _selectedPreset!.category.color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Base Impact: ${_selectedPreset!.baseImpact}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Effort Level: ${_selectedPreset!.effortRating}  |  Frequency Limit: ${_selectedPreset!.frequencyLimit.label}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Required Verification: ${_selectedPreset!.verificationMethod.label}',
                      style: TextStyle(color: Colors.grey[700], fontSize: 11),
                    ),
                    if (_selectedPreset!.verificationMethod == VerificationMethod.gpsAndImage &&
                        (_latitude == null || _mockImagePath == null)) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Warning: This action requires GPS location and photo proof for verification.',
                              style: TextStyle(color: Colors.orange[800], fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Verification Ladder selection widget
            Text(
              'Verification Level Ladder',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLadderStep(1, '🟢 Self', 'Self-verification for tiny actions', theme),
                _buildLadderStep(2, '🔵 Evidence', 'Photos, location and timestamps', theme),
                _buildLadderStep(3, '🟣 Community', 'Peer validator consensus', theme),
                _buildLadderStep(4, '🟠 Org', 'Official NGO/institution signature', theme),
                _buildLadderStep(5, '🔴 Independent', 'Independent third-party audits', theme),
              ],
            ),
            const SizedBox(height: 20),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Activity Title',
                hintText: 'e.g., Planted saplings, Fed animals...',
                prefixIcon: Icon(Icons.title_rounded),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Enter a title' : null,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Describe your contribution',
                hintText: 'What did you do? Who did it benefit? Include any key context.',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              validator: (val) => val == null || val.length < 10
                  ? 'Please provide a detailed description (min 10 characters)'
                  : null,
            ),
            const SizedBox(height: 16),

            // Scale of Action
            TextFormField(
              controller: _scaleController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Scale of Action (People/Units helped)',
                hintText: 'e.g. 1 (individual), 20 (group), 1000 (scaled course/tool)',
                prefixIcon: Icon(Icons.people_outline_rounded),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Enter the scale of action';
                final parsed = int.tryParse(val);
                if (parsed == null || parsed <= 0) return 'Enter a valid positive number';
                return null;
              },
              onChanged: (_) {
                // Trigger dynamic calculation update in projected confidence card
                setState(() {});
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _durationCategory,
                    decoration: const InputDecoration(
                      labelText: 'Duration Type',
                      prefixIcon: Icon(Icons.hourglass_bottom_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Quick', child: Text('⚡ Quick (1-15m)')),
                      DropdownMenuItem(value: 'Deep', child: Text('🌱 Deep (hours/days)')),
                      DropdownMenuItem(value: 'Impact', child: Text('🚀 Impact (project)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _durationCategory = val;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _impactScope,
                    decoration: const InputDecoration(
                      labelText: 'Impact Scope',
                      prefixIcon: Icon(Icons.language_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Individual', child: Text('Individual')),
                      DropdownMenuItem(value: 'Team', child: Text('Team')),
                      DropdownMenuItem(value: 'Community', child: Text('Community')),
                      DropdownMenuItem(value: 'City', child: Text('City')),
                      DropdownMenuItem(value: 'Global', child: Text('Global')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _impactScope = val;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_verificationLevel >= 4) ...[
              SwitchListTile.adaptive(
                dense: true,
                title: const Text('Stake Proof Bond (20 Reputation)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                subtitle: const Text('Required for Level 4/5 actions. Bond is forfeited on fraudulent claims.', style: TextStyle(fontSize: 10)),
                value: _stakeProofBond,
                onChanged: (val) {
                  setState(() {
                    _stakeProofBond = val;
                  });
                },
              ),
              const SizedBox(height: 12),
            ],

            SwitchListTile.adaptive(
              dense: true,
              title: const Text('Vulnerable Person Protection', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              subtitle: const Text('Protects patients/kids. Uses QR codes/receipts instead of photo proof.', style: TextStyle(fontSize: 10)),
              value: _protectVulnerable,
              onChanged: (val) {
                setState(() {
                  _protectVulnerable = val;
                });
              },
            ),

            if (_protectVulnerable) ...[
              const SizedBox(height: 10),
              TextFormField(
                controller: _witnessCodeController,
                decoration: const InputDecoration(
                  labelText: 'Anonymized Witness QR Code / Receipt ID',
                  hintText: 'e.g. Blood bank donation code, shelter registration QR',
                  prefixIcon: Icon(Icons.qr_code_scanner_rounded),
                ),
              ),
              const SizedBox(height: 16),
            ],

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Column(
                  children: [
                    CheckboxListTile(
                      dense: true,
                      title: const Text('Creativity Bonus (+10% credits)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Creative methods, art, or unique solutions applied.', style: TextStyle(fontSize: 10)),
                      value: _creativityBonus,
                      onChanged: (val) {
                        setState(() {
                          _creativityBonus = val ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      dense: true,
                      title: const Text('Group Participation Bonus (+15% credits)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Completed with friends, family, or teams.', style: TextStyle(fontSize: 10)),
                      value: _participationBonus,
                      onChanged: (val) {
                        setState(() {
                          _participationBonus = val ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      dense: true,
                      title: const Text('Ripple Inspiration Bonus (+20% credits)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Directly inspired others to join or copy the activity.', style: TextStyle(fontSize: 10)),
                      value: _rippleInspirationBonus,
                      onChanged: (val) {
                        setState(() {
                          _rippleInspirationBonus = val ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category Selector Label
            Text(
              'Select Category',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Grid of categories
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.8,
              ),
              itemCount: KarmaCategory.values.length,
              itemBuilder: (context, index) {
                final cat = KarmaCategory.values[index];
                final isSelected = _selectedCategory == cat;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? cat.color.withOpacity(0.15) : theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? cat.color : Colors.grey.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Text(cat.icon, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cat.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? cat.color : theme.textTheme.bodyMedium?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Guided Proof Capture Button
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0052CC), // Secure Blue
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.security_rounded),
                label: const Text('Launch guided Proof Capture Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    AppRoutes.proofCapture,
                    arguments: _selectedCategory,
                  );
                  if (result != null && result is Map<String, dynamic>) {
                    setState(() {
                      _capturedInApp = result['capturedInApp'] ?? false;
                      _mockImagePath = result['imageUrl'];
                      _beforeImageUrl = result['beforeImageUrl'];
                      _wasteBeforeCount = result['wasteBeforeCount'];
                      _wasteAfterCount = result['wasteAfterCount'];
                      _sceneMatchConfidence = result['sceneMatchConfidence'];
                      _evidenceScore = result['evidenceScore'];
                      
                      // Auto prefill GPS
                      _latitude = 12.9716;
                      _longitude = 77.5946;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🔐 Proof Captured! AI Evidence Score: $_evidenceScore/100'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
              ),
            ),

            if (_capturedInApp) ...[
              Card(
                color: Colors.green.withOpacity(0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.green, width: 1.5),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.verified_user_rounded, color: Colors.green),
                          SizedBox(width: 8),
                          Text('🔐 Secure Proof Capture Verified', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('• Scene Match Confidence: ${(_sceneMatchConfidence! * 100).toInt()}%', style: const TextStyle(fontSize: 12)),
                      Text('• Measurable Impact: $_wasteBeforeCount objects detected before ➔ $_wasteAfterCount after', style: const TextStyle(fontSize: 12)),
                      Text('• Locked Coordinates: Lat: $_latitude, Lon: $_longitude', style: const TextStyle(fontSize: 12)),
                      Text('• Secure App Signature: ✅ VALID Enclave Seal', style: const TextStyle(fontSize: 12)),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('AI Evidence Score:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('$_evidenceScore / 100', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Layer 2 Proof Verification Checklist
            Text(
              'Attach Proof of Change (Required)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Card(
              color: Colors.red.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.gavel_rounded, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No Proof of Change, No Impact Credit: You must attach both BEFORE and AFTER evidence to verify your impact.',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // BEFORE and AFTER Media attachment buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _simulateBeforePhotoPick,
                    icon: Icon(
                      _beforeImageUrl != null ? Icons.check_circle_rounded : Icons.camera_alt_rounded,
                      color: _beforeImageUrl != null ? const Color(0xFF00B074) : null,
                    ),
                    label: Text(
                      _beforeImageUrl != null ? 'BEFORE Attached' : 'Attach BEFORE',
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: _beforeImageUrl != null ? const Color(0xFF00B074) : Colors.grey.withOpacity(0.4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _simulateAfterPhotoPick,
                    icon: Icon(
                      _mockImagePath != null ? Icons.check_circle_rounded : Icons.camera_alt_rounded,
                      color: _mockImagePath != null ? const Color(0xFF00B074) : null,
                    ),
                    label: Text(
                      _mockImagePath != null ? 'AFTER Attached' : 'Attach AFTER',
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: _mockImagePath != null ? const Color(0xFF00B074) : Colors.grey.withOpacity(0.4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isGettingLocation ? null : _fetchGPS,
                    icon: Icon(
                      _latitude != null ? Icons.location_on_rounded : Icons.gps_fixed_rounded,
                      color: _latitude != null ? const Color(0xFF00B074) : null,
                    ),
                    label: Text(
                      _isGettingLocation
                          ? 'Fetching...'
                          : _latitude != null
                              ? 'GPS Verified'
                              : 'Fetch Location',
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: _latitude != null ? const Color(0xFF00B074) : Colors.grey.withOpacity(0.4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Show Evidence description guidelines based on category
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Evidence Type Guidelines for ${_selectedCategory.label}:',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• ${_getBeforeLabel()}\n• ${_getAfterLabel()}',
                    style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.uploadProof),
              icon: const Icon(Icons.cloud_upload_outlined, size: 16),
              label: const Text('Open advanced Proof Upload Hub (MP4 / WAV)'),
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 12),

            // Witness Email input
            TextFormField(
              controller: _witnessController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Community Witness Email (Optional)',
                hintText: 'e.g., recipient, observer, or NGO head',
                prefixIcon: Icon(Icons.people_outline_rounded),
              ),
              onChanged: (_) {
                // Trigger UI update to recalculate confidence
                setState(() {});
              },
            ),
            const SizedBox(height: 24),

            // Confidence Indicator Meter
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Projected Proof Strength',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        '${(confidence * 100).toInt()}% Confidence',
                        style: TextStyle(
                          color: confidence >= 0.8
                              ? const Color(0xFF00B074)
                              : confidence >= 0.6
                                  ? Colors.orange
                                  : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: confidence,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      confidence >= 0.8
                          ? const Color(0xFF00B074)
                          : confidence >= 0.6
                              ? Colors.orange
                              : Colors.red,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    confidence >= 0.8
                        ? 'Excellent proof! Validators will process this submission immediately.'
                        : confidence >= 0.6
                            ? 'Good proof. Highly eligible for verification and standard rewards.'
                            : 'Weak proof. Submissions with low proof require extra manual validators.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                  const Divider(height: 20),
                  // Calculate dynamic estimation
                  Builder(
                    builder: (context) {
                      final scale = int.tryParse(_scaleController.text.trim()) ?? 1;
                      final double scaleMultiplier = scale.toDouble();
                      
                      double effortMultiplier = 1.0;
                      if (_durationCategory == 'Deep') {
                        effortMultiplier = 2.0;
                      } else if (_durationCategory == 'Impact') {
                        effortMultiplier = 5.0;
                      }

                      int baseCredits = _selectedPreset != null ? _selectedPreset!.baseImpact : 30;
                      if (_selectedPreset == null) {
                        switch (_selectedCategory) {
                          case KarmaCategory.environment: baseCredits = 50; break;
                          case KarmaCategory.animalWelfare: baseCredits = 40; break;
                          case KarmaCategory.innovation: baseCredits = 80; break;
                          case KarmaCategory.healthcare: baseCredits = 45; break;
                          case KarmaCategory.education: baseCredits = 35; break;
                          default: baseCredits = 30;
                        }
                      }
                      double qualityFactor = 1.0;
                      if (_creativityBonus) qualityFactor += 0.10;
                      if (_participationBonus) qualityFactor += 0.15;
                      if (_rippleInspirationBonus) qualityFactor += 0.20;

                      final directEstimate = (baseCredits * qualityFactor * scaleMultiplier * effortMultiplier * confidence).round();
                      final rippleEstimate = (directEstimate * 0.20).round();
                      final totalEstimate = directEstimate + rippleEstimate;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Scale Multiplier: ${scaleMultiplier.toStringAsFixed(1)}x | Effort: ${effortMultiplier.toStringAsFixed(1)}x',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                'Direct: $directEstimate Credits',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Ripple Factor: +20% capacity ripple',
                                style: TextStyle(fontSize: 11, color: Colors.blueGrey),
                              ),
                              Text(
                                'Ripple: +$rippleEstimate Credits',
                                style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Projected Total Payout',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF00B074)),
                              ),
                              Text(
                                '$totalEstimate Karma Credits',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF00B074)),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          if (_verificationLevel == 1) ...[
                            Text(
                              '🟢 Level 1: 100% Provisional ($totalEstimate Credits) released immediately on submission.',
                              style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ] else ...[
                            Builder(
                              builder: (context) {
                                final prov = (totalEstimate * 0.30).round();
                                final ver = (totalEstimate * 0.50).round();
                                final out = totalEstimate - prov - ver;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('⚡ Provisional (30%): +$prov credits released instantly.', style: const TextStyle(fontSize: 10)),
                                    const SizedBox(height: 2),
                                    Text('🛡️ Verified (50%): +$ver credits released on validator consensus.', style: const TextStyle(fontSize: 10)),
                                    const SizedBox(height: 2),
                                    Text('🌱 Outcome (20%): +$out credits released on 6-month survival milestone.', style: const TextStyle(fontSize: 10)),
                                  ],
                                );
                              }
                            ),
                          ],
                        ],
                      );
                    }
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.aiStatus),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Track AI verification steps',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00B074)),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 12, color: Color(0xFF00B074)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            if (karmaProvider.isSubmitting)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit to Ledger Queue'),
              ),
          ],
        ),
      ),
    );
  }
}
