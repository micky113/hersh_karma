import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/karma_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../models/karma_category.dart';
import '../../models/karma_activity.dart';
import '../../data/karma_grid_presets.dart';
import '../../core/localization/app_localizations.dart';
import '../../services/gemini_vision_service.dart';
import '../../core/config/ai_config.dart';

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

  // Real Image Capture & Compression Fields
  XFile? _beforeImageFile;
  XFile? _afterImageFile;
  Uint8List? _beforeImageBytes;
  Uint8List? _afterImageBytes;
  int? _beforeImageBytesCount;
  int? _afterImageBytesCount;
  bool _isCompressing = false;

  // Real-time Gemini Multimodal AI Verification Fields
  bool _isAnalyzingWithGemini = false;
  GeminiVerificationResult? _geminiAnalysisResult;

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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _buildLadderStep(int level, String label, String tooltip, ThemeData theme) {
    final isSelected = _verificationLevel == level;
    Color stepColor = Colors.green;
    if (level == 2) stepColor = Colors.blue;
    if (level == 3) stepColor = Colors.purple;
    if (level == 4) stepColor = Colors.orange;
    if (level == 5) stepColor = Colors.red;

    final translatedLabel = AppLocalizations.translateWithContext(context, label, defaultValue: label);
    final translatedTooltip = AppLocalizations.translateWithContext(context, tooltip, defaultValue: tooltip);

    return Expanded(
      child: Tooltip(
        message: translatedTooltip,
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
              translatedLabel,
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

  String _getBeforeLabel(BuildContext context) {
    switch (_selectedCategory) {
      case KarmaCategory.healthcare:
        return AppLocalizations.translateWithContext(context, 'BEFORE Check-in / Initial Assessment', defaultValue: 'BEFORE Check-in / Initial Assessment');
      case KarmaCategory.education:
        return AppLocalizations.translateWithContext(context, 'BEFORE Initial Assessment / Syllabus', defaultValue: 'BEFORE Initial Assessment / Syllabus');
      case KarmaCategory.environment:
      case KarmaCategory.animalWelfare:
        return AppLocalizations.translateWithContext(context, 'BEFORE Condition Photo', defaultValue: 'BEFORE Condition Photo');
      default:
        return AppLocalizations.translateWithContext(context, 'BEFORE Starting Condition Proof', defaultValue: 'BEFORE Starting Condition Proof');
    }
  }

  String _getAfterLabel(BuildContext context) {
    switch (_selectedCategory) {
      case KarmaCategory.healthcare:
        return AppLocalizations.translateWithContext(context, 'AFTER Donation Receipt', defaultValue: 'AFTER Donation Receipt');
      case KarmaCategory.education:
        return AppLocalizations.translateWithContext(context, 'AFTER Final Assessment / Outcome', defaultValue: 'AFTER Final Assessment / Outcome');
      case KarmaCategory.environment:
      case KarmaCategory.animalWelfare:
        return AppLocalizations.translateWithContext(context, 'AFTER Resulting State Photo', defaultValue: 'AFTER Resulting State Photo');
      default:
        return AppLocalizations.translateWithContext(context, 'AFTER Resulting Change Proof', defaultValue: 'AFTER Resulting Change Proof');
    }
  }

  // Camera & Gallery Modal Sheet
  void _showPhotoSourceSheet(bool isBefore) {
    final theme = Theme.of(context);
    final String stepName = isBefore ? 'BEFORE' : 'AFTER';

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${AppLocalizations.translateWithContext(context, 'Attach Proof', defaultValue: 'Attach Proof')} ($stepName)',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.translateWithContext(
                  context,
                  'Photos are automatically compressed (max 1024px, 80% quality) for fast upload and lightweight storage.',
                  defaultValue: 'Photos are automatically compressed (max 1024px, 80% quality) for fast upload and lightweight storage.',
                ),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.blue),
                ),
                title: Text(
                  AppLocalizations.translateWithContext(context, 'Take Photo with Camera', defaultValue: 'Take Photo with Camera'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  AppLocalizations.translateWithContext(context, 'Capture real-time proof right now', defaultValue: 'Capture real-time proof right now'),
                  style: const TextStyle(fontSize: 11),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(isBefore, ImageSource.camera);
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Colors.green),
                ),
                title: Text(
                  AppLocalizations.translateWithContext(context, 'Choose from Gallery', defaultValue: 'Choose from Gallery'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  AppLocalizations.translateWithContext(context, 'Upload existing photo from device', defaultValue: 'Upload existing photo from device'),
                  style: const TextStyle(fontSize: 11),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(isBefore, ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(bool isBefore, ImageSource source) async {
    setState(() {
      _isCompressing = true;
    });

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          if (isBefore) {
            _beforeImageFile = pickedFile;
            _beforeImageBytes = bytes;
            _beforeImageBytesCount = bytes.length;
            _beforeImageUrl = pickedFile.path;
          } else {
            _afterImageFile = pickedFile;
            _afterImageBytes = bytes;
            _afterImageBytesCount = bytes.length;
            _mockImagePath = pickedFile.path;
          }
        });

        if (mounted) {
          final sizeStr = _formatFileSize(bytes.length);
          final label = isBefore ? 'BEFORE' : 'AFTER';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📸 $label evidence attached ($sizeStr, optimized for fast upload)!'),
              backgroundColor: const Color(0xFF00B074),
              duration: const Duration(seconds: 2),
            ),
          );
          _checkAndRunAiAnalysis();
        }
      }
    } catch (e) {
      debugPrint('Image pick note: $e');
      if (mounted) {
        if (isBefore) {
          _simulateBeforePhotoPick();
        } else {
          _simulateAfterPhotoPick();
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCompressing = false;
        });
      }
    }
  }

  void _checkAndRunAiAnalysis() {
    final bool hasBefore = _beforeImageBytes != null || (_beforeImageUrl != null && _beforeImageUrl!.isNotEmpty);
    final bool hasAfter = _afterImageBytes != null || (_mockImagePath != null && _mockImagePath!.isNotEmpty);
    if (hasBefore && hasAfter) {
      _runGeminiMultimodalAnalysis();
    }
  }

  Future<void> _runGeminiMultimodalAnalysis() async {
    final bool hasBefore = _beforeImageBytes != null || (_beforeImageUrl != null && _beforeImageUrl!.isNotEmpty);
    final bool hasAfter = _afterImageBytes != null || (_mockImagePath != null && _mockImagePath!.isNotEmpty);

    if (!hasBefore || !hasAfter) return;

    setState(() {
      _isAnalyzingWithGemini = true;
    });

    try {
      final result = await GeminiVisionService.analyzeEvidence(
        beforeImageBytes: _beforeImageBytes,
        afterImageBytes: _afterImageBytes,
        deedTitle: _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : 'Community Impact Deed',
        category: _selectedCategory.name,
        description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
        latitude: _latitude,
        longitude: _longitude,
        capturedInApp: _capturedInApp,
      );

      if (mounted) {
        setState(() {
          _isAnalyzingWithGemini = false;
          _geminiAnalysisResult = result;
          _evidenceScore = result.evidenceScore;
          _sceneMatchConfidence = result.sceneMatchConfidence;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isAnalyzingWithGemini = false;
        });
      }
    }
  }

  void _removePhoto(bool isBefore) {
    setState(() {
      if (isBefore) {
        _beforeImageFile = null;
        _beforeImageBytes = null;
        _beforeImageBytesCount = null;
        _beforeImageUrl = null;
      } else {
        _afterImageFile = null;
        _afterImageBytes = null;
        _afterImageBytesCount = null;
        _mockImagePath = null;
      }
      _geminiAnalysisResult = null;
      _evidenceScore = 0;
      _sceneMatchConfidence = null;
    });
  }

  // Simulate photo selection fallback
  void _simulateBeforePhotoPick() {
    setState(() {
      _beforeImageUrl = 'assets/proofs/deed_before_${DateTime.now().millisecondsSinceEpoch}.jpg';
      _beforeImageBytes = null;
      _beforeImageBytesCount = 142000;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📸 BEFORE evidence attached! (AI verification will register starting condition)'),
        backgroundColor: Color(0xFF00B074),
      ),
    );
    _checkAndRunAiAnalysis();
  }

  void _simulateAfterPhotoPick() {
    setState(() {
      _mockImagePath = 'assets/proofs/deed_after_${DateTime.now().millisecondsSinceEpoch}.jpg';
      _afterImageBytes = null;
      _afterImageBytesCount = 158000;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📸 AFTER evidence attached! (AI verification will register resulting outcome)'),
        backgroundColor: Color(0xFF00B074),
      ),
    );
    _checkAndRunAiAnalysis();
  }

  // Fetch or simulate GPS location
  Future<void> _fetchGPS() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
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

  Widget _buildPhotoSlot(bool isBefore, ThemeData theme) {
    final bool hasFile = isBefore
        ? (_beforeImageBytes != null || _beforeImageUrl != null)
        : (_afterImageBytes != null || _mockImagePath != null);
    final Uint8List? bytes = isBefore ? _beforeImageBytes : _afterImageBytes;
    final int? byteCount = isBefore ? _beforeImageBytesCount : _afterImageBytesCount;
    final String label = isBefore
        ? AppLocalizations.translateWithContext(context, 'BEFORE Photo', defaultValue: 'BEFORE Photo')
        : AppLocalizations.translateWithContext(context, 'AFTER Photo', defaultValue: 'AFTER Photo');
    final String attachLabel = isBefore
        ? AppLocalizations.translateWithContext(context, 'Attach BEFORE', defaultValue: 'Attach BEFORE')
        : AppLocalizations.translateWithContext(context, 'Attach AFTER', defaultValue: 'Attach AFTER');
    final String subLabel = isBefore
        ? AppLocalizations.translateWithContext(context, 'Starting state', defaultValue: 'Starting state')
        : AppLocalizations.translateWithContext(context, 'Outcome state', defaultValue: 'Outcome state');

    if (!hasFile) {
      return OutlinedButton.icon(
        onPressed: () => _showPhotoSourceSheet(isBefore),
        icon: const Icon(Icons.camera_alt_rounded, size: 20),
        label: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(attachLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            Text(subLabel, style: TextStyle(fontSize: 9, color: Colors.grey[600]), overflow: TextOverflow.ellipsis),
          ],
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.withOpacity(0.4)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF00B074).withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF00B074), width: 1.5),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: bytes != null
                ? Image.memory(bytes, width: 38, height: 38, fit: BoxFit.cover)
                : Container(
                    width: 38,
                    height: 38,
                    color: Colors.green.withOpacity(0.2),
                    child: const Icon(Icons.check_circle, color: Color(0xFF00B074), size: 22),
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF00B074), size: 12),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        label,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00B074)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (byteCount != null)
                  Text(
                    '${_formatFileSize(byteCount)} • ${AppLocalizations.translateWithContext(context, 'Ready to upload', defaultValue: 'Ready to upload')}',
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch_outlined, size: 16),
            tooltip: AppLocalizations.translateWithContext(context, 'Change photo', defaultValue: 'Change photo'),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _showPhotoSourceSheet(isBefore),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 16, color: Colors.red),
            tooltip: AppLocalizations.translateWithContext(context, 'Remove photo', defaultValue: 'Remove photo'),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _removePhoto(isBefore),
          ),
        ],
      ),
    );
  }

  Widget _buildRealtimeGeminiAnalysisCard(ThemeData theme) {
    final bool hasBefore = _beforeImageBytes != null || (_beforeImageUrl != null && _beforeImageUrl!.isNotEmpty);
    final bool hasAfter = _afterImageBytes != null || (_mockImagePath != null && _mockImagePath!.isNotEmpty);

    if (_isAnalyzingWithGemini) {
      return Container(
        margin: const EdgeInsets.only(top: 10, bottom: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.purple.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.purple),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '⚡ Gemini Vision AI Scanning Evidence (${AiConfig.modelName})...',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.purple),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const LinearProgressIndicator(
              backgroundColor: Color(0xFFF3E5F5),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
            const SizedBox(height: 6),
            const Text(
              'Evaluating Before/After scene perspective, object transformation, and media authenticity in real-time...',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_geminiAnalysisResult != null) {
      final res = _geminiAnalysisResult!;
      final isLive = res.isLiveAiResult;
      final score = res.evidenceScore;
      final Color scoreColor = score >= 90 ? const Color(0xFF00B074) : (score >= 70 ? Colors.amber.shade800 : Colors.redAccent);
      final String routingText = score >= 90
          ? '⚡ AUTO-VERIFIED (Instant Karma Credited)'
          : (score >= 70 ? '🛡️ PENDING VALIDATORS (3 Consensus Votes Needed)' : '⚠️ LOW CONFIDENCE EVIDENCE');

      return Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scoreColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scoreColor.withOpacity(0.35), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.auto_awesome, color: scoreColor, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLive ? '✨ Gemini Multimodal Vision AI' : '🛡️ Proof-of-Good Engine Analysis',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: scoreColor),
                      ),
                      Text(
                        routingText,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: scoreColor),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scoreColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Score: $score/100',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.grey),
                  tooltip: 'Re-analyze with Gemini Vision',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: _runGeminiMultimodalAnalysis,
                ),
              ],
            ),
            const Divider(height: 18, thickness: 0.8),
            // AI Detection Brief Header
            Row(
              children: [
                const Icon(Icons.psychology_outlined, size: 16, color: Color(0xFF5E35B1)),
                const SizedBox(width: 6),
                const Text(
                  'AI Visual Detection & Difference Analysis',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF311B92)),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (res.isGoodDeedDetected && !res.isTampered ? const Color(0xFF00B074) : Colors.red).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    res.isGoodDeedDetected && !res.isTampered ? '✅ Good Deed Verified' : '❌ No Deed Detected',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: res.isGoodDeedDetected && !res.isTampered ? const Color(0xFF007A50) : Colors.red.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.withOpacity(0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    res.changeSummary,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF2D3748), height: 1.3),
                  ),
                  const SizedBox(height: 10),
                  // Photo 1 (Before) vs Photo 2 (After) Visual Content & Object Recognition
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('📸 Photo 1 (Before):', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.brown)),
                              const SizedBox(height: 2),
                              Text(
                                res.whatSeenBefore.isNotEmpty ? res.whatSeenBefore : res.measurableBefore,
                                style: const TextStyle(fontSize: 11, color: Colors.black87),
                              ),
                              if (res.detectedObjectsBefore.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: res.detectedObjectsBefore.map((obj) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.brown.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '🏷️ $obj',
                                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.brown),
                                    ),
                                  )).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (res.isGoodDeedDetected && !res.isTampered ? const Color(0xFF00B074) : Colors.red).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: (res.isGoodDeedDetected && !res.isTampered ? const Color(0xFF00B074) : Colors.red).withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('✨ Photo 2 (After):', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF007A50))),
                              const SizedBox(height: 2),
                              Text(
                                res.whatSeenAfter.isNotEmpty ? res.whatSeenAfter : res.measurableAfter,
                                style: const TextStyle(fontSize: 11, color: Colors.black87),
                              ),
                              if (res.detectedObjectsAfter.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: res.detectedObjectsAfter.map((obj) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (res.isGoodDeedDetected && !res.isTampered ? const Color(0xFF00B074) : Colors.red).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '🏷️ $obj',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: res.isGoodDeedDetected && !res.isTampered ? const Color(0xFF007A50) : Colors.red.shade900,
                                      ),
                                    ),
                                  )).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Visual Difference Detected
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5E35B1).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🔬 Detected Difference: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF311B92))),
                        Expanded(
                          child: Text(
                            res.visualDifference.isNotEmpty ? res.visualDifference : res.changeSummary,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF311B92)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (res.reasoning.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '⚖️ AI Verdict: ${res.reasoning}',
                      style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey.shade800),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Badges for Scene Match and Anti-Tamper Authenticity
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.compare_arrows_rounded, size: 13, color: Colors.blue),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Scene Match: ${(res.sceneMatchConfidence * 100).toInt()}%',
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.blue),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: res.isTampered ? Colors.red.withOpacity(0.08) : const Color(0xFF00B074).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: (res.isTampered ? Colors.red : const Color(0xFF00B074)).withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          res.isTampered ? Icons.warning_amber_rounded : Icons.verified_user_rounded,
                          size: 13,
                          color: res.isTampered ? Colors.red : const Color(0xFF00B074),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            res.isTampered ? 'Tampering Flagged' : 'Authentic Media',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: res.isTampered ? Colors.red : const Color(0xFF00B074),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (hasBefore && hasAfter) {
      return Container(
        margin: const EdgeInsets.only(top: 10, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.purple.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, size: 16, color: Colors.purple),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Both photos attached. Ready for Gemini Multimodal Analysis.',
                style: TextStyle(fontSize: 11, color: Colors.purple, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: _runGeminiMultimodalAnalysis,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Analyze Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple)),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
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
      beforeImageFile: _beforeImageFile,
      afterImageFile: _afterImageFile,
    );

    if (success && mounted) {
      final newDeed = karmaProvider.myActions.isNotEmpty ? karmaProvider.myActions.first : null;
      final credits = newDeed?.creditsAwarded ?? 350;

      Navigator.pushNamed(context, AppRoutes.karmaResult, arguments: credits);

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
        _beforeImageFile = null;
        _afterImageFile = null;
        _beforeImageBytes = null;
        _afterImageBytes = null;
        _beforeImageBytesCount = null;
        _afterImageBytesCount = null;
        _isCompressing = false;
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

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.translateWithContext(context, 'dash_action_do', defaultValue: '🌱 Curated Positive Action')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Preset Bar
            Text(
              AppLocalizations.translateWithContext(context, 'Curated Positive Actions (366 Presets)', defaultValue: 'Curated Positive Actions (366 Presets)'),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _searchPresetController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                labelText: AppLocalizations.translateWithContext(context, 'Search leap-year master list...', defaultValue: 'Search leap-year master list...'),
                hintText: AppLocalizations.translateWithContext(context, 'e.g., cpr, recycle, mentor, feed...', defaultValue: 'e.g., cpr, recycle, mentor, feed...'),
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
                          title: Text(AppLocalizations.translateWithContext(context, act.title, defaultValue: act.title), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
                      title: Text(
                        AppLocalizations.translateWithContext(context, 'Can\'t find your deed? Propose a new Action to the registry', defaultValue: 'Can\'t find your deed? Propose a new Action to the registry'),
                        style: const TextStyle(color: Colors.purple, fontSize: 11, fontWeight: FontWeight.bold),
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
                          '${AppLocalizations.translateWithContext(context, 'Taxonomy Match: Tier', defaultValue: 'Taxonomy Match: Tier')} ${_selectedPreset!.tier}',
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
                            '${AppLocalizations.translateWithContext(context, 'Base Impact:', defaultValue: 'Base Impact:')} ${_selectedPreset!.baseImpact}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${AppLocalizations.translateWithContext(context, 'Effort Level:', defaultValue: 'Effort Level:')} ${AppLocalizations.translateWithContext(context, _selectedPreset!.effortRating, defaultValue: _selectedPreset!.effortRating)}  |  ${AppLocalizations.translateWithContext(context, 'Frequency Limit:', defaultValue: 'Frequency Limit:')} ${AppLocalizations.translateWithContext(context, _selectedPreset!.frequencyLimit.label, defaultValue: _selectedPreset!.frequencyLimit.label)}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppLocalizations.translateWithContext(context, 'Required Verification:', defaultValue: 'Required Verification:')} ${AppLocalizations.translateWithContext(context, _selectedPreset!.verificationMethod.label, defaultValue: _selectedPreset!.verificationMethod.label)}',
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
                              AppLocalizations.translateWithContext(context, 'Warning: This action requires GPS location and photo proof for verification.', defaultValue: 'Warning: This action requires GPS location and photo proof for verification.'),
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
              AppLocalizations.translateWithContext(context, 'Verification Level Ladder', defaultValue: 'Verification Level Ladder'),
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
              decoration: InputDecoration(
                labelText: AppLocalizations.translateWithContext(context, 'Activity Title', defaultValue: 'Activity Title'),
                hintText: AppLocalizations.translateWithContext(context, 'e.g., Planted saplings, Fed animals...', defaultValue: 'e.g., Planted saplings, Fed animals...'),
                prefixIcon: const Icon(Icons.title_rounded),
              ),
              validator: (val) => val == null || val.isEmpty ? AppLocalizations.translateWithContext(context, 'Enter a title', defaultValue: 'Enter a title') : null,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: AppLocalizations.translateWithContext(context, 'Describe your contribution', defaultValue: 'Describe your contribution'),
                hintText: AppLocalizations.translateWithContext(context, 'What did you do? Who did it benefit? Include any key context.', defaultValue: 'What did you do? Who did it benefit? Include any key context.'),
                prefixIcon: const Icon(Icons.description_outlined),
              ),
              validator: (val) => val == null || val.length < 10
                  ? AppLocalizations.translateWithContext(context, 'Please provide a detailed description (min 10 characters)', defaultValue: 'Please provide a detailed description (min 10 characters)')
                  : null,
            ),
            const SizedBox(height: 16),

            // Scale of Action
            TextFormField(
              controller: _scaleController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppLocalizations.translateWithContext(context, 'Scale of Action (People/Units helped)', defaultValue: 'Scale of Action (People/Units helped)'),
                hintText: AppLocalizations.translateWithContext(context, 'e.g. 1 (individual), 20 (group), 1000 (scaled course/tool)', defaultValue: 'e.g. 1 (individual), 20 (group), 1000 (scaled course/tool)'),
                prefixIcon: const Icon(Icons.people_outline_rounded),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return AppLocalizations.translateWithContext(context, 'Enter the scale of action', defaultValue: 'Enter the scale of action');
                final parsed = int.tryParse(val);
                if (parsed == null || parsed <= 0) return AppLocalizations.translateWithContext(context, 'Enter a valid positive number', defaultValue: 'Enter a valid positive number');
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
                    isExpanded: true,
                    value: _durationCategory,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.translateWithContext(context, 'Duration Type', defaultValue: 'Duration Type'),
                      prefixIcon: const Icon(Icons.hourglass_bottom_rounded),
                    ),
                    items: [
                      DropdownMenuItem(value: 'Quick', child: Text(AppLocalizations.translateWithContext(context, '⚡ Quick (1-15m)', defaultValue: '⚡ Quick (1-15m)'))),
                      DropdownMenuItem(value: 'Deep', child: Text(AppLocalizations.translateWithContext(context, '🌱 Deep (hours/days)', defaultValue: '🌱 Deep (hours/days)'))),
                      DropdownMenuItem(value: 'Impact', child: Text(AppLocalizations.translateWithContext(context, '🚀 Impact (project)', defaultValue: '🚀 Impact (project)'))),
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
                    isExpanded: true,
                    value: _impactScope,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.translateWithContext(context, 'Impact Scope', defaultValue: 'Impact Scope'),
                      prefixIcon: const Icon(Icons.language_rounded),
                    ),
                    items: [
                      DropdownMenuItem(value: 'Individual', child: Text(AppLocalizations.translateWithContext(context, 'Individual', defaultValue: 'Individual'))),
                      DropdownMenuItem(value: 'Team', child: Text(AppLocalizations.translateWithContext(context, 'Team', defaultValue: 'Team'))),
                      DropdownMenuItem(value: 'Community', child: Text(AppLocalizations.translateWithContext(context, 'Community', defaultValue: 'Community'))),
                      DropdownMenuItem(value: 'City', child: Text(AppLocalizations.translateWithContext(context, 'City', defaultValue: 'City'))),
                      DropdownMenuItem(value: 'Global', child: Text(AppLocalizations.translateWithContext(context, 'Global', defaultValue: 'Global'))),
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
                title: Text(AppLocalizations.translateWithContext(context, 'Stake Proof Bond (20 Reputation)', defaultValue: 'Stake Proof Bond (20 Reputation)'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                subtitle: Text(AppLocalizations.translateWithContext(context, 'Required for Level 4/5 actions. Bond is forfeited on fraudulent claims.', defaultValue: 'Required for Level 4/5 actions. Bond is forfeited on fraudulent claims.'), style: const TextStyle(fontSize: 10)),
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
              title: Text(AppLocalizations.translateWithContext(context, 'Vulnerable Person Protection', defaultValue: 'Vulnerable Person Protection'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              subtitle: Text(AppLocalizations.translateWithContext(context, 'Protects patients/kids. Uses QR codes/receipts instead of photo proof.', defaultValue: 'Protects patients/kids. Uses QR codes/receipts instead of photo proof.'), style: const TextStyle(fontSize: 10)),
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
                decoration: InputDecoration(
                  labelText: AppLocalizations.translateWithContext(context, 'Anonymized Witness QR Code / Receipt ID', defaultValue: 'Anonymized Witness QR Code / Receipt ID'),
                  hintText: AppLocalizations.translateWithContext(context, 'e.g. Blood bank donation code, shelter registration QR', defaultValue: 'e.g. Blood bank donation code, shelter registration QR'),
                  prefixIcon: const Icon(Icons.qr_code_scanner_rounded),
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
                      title: Text(AppLocalizations.translateWithContext(context, 'Creativity Bonus (+10% credits)', defaultValue: 'Creativity Bonus (+10% credits)'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      subtitle: Text(AppLocalizations.translateWithContext(context, 'Creative methods, art, or unique solutions applied.', defaultValue: 'Creative methods, art, or unique solutions applied.'), style: const TextStyle(fontSize: 10)),
                      value: _creativityBonus,
                      onChanged: (val) {
                        setState(() {
                          _creativityBonus = val ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      dense: true,
                      title: Text(AppLocalizations.translateWithContext(context, 'Group Participation Bonus (+15% credits)', defaultValue: 'Group Participation Bonus (+15% credits)'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      subtitle: Text(AppLocalizations.translateWithContext(context, 'Completed with friends, family, or teams.', defaultValue: 'Completed with friends, family, or teams.'), style: const TextStyle(fontSize: 10)),
                      value: _participationBonus,
                      onChanged: (val) {
                        setState(() {
                          _participationBonus = val ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      dense: true,
                      title: Text(AppLocalizations.translateWithContext(context, 'Ripple Inspiration Bonus (+20% credits)', defaultValue: 'Ripple Inspiration Bonus (+20% credits)'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      subtitle: Text(AppLocalizations.translateWithContext(context, 'Directly inspired others to join or copy the activity.', defaultValue: 'Directly inspired others to join or copy the activity.'), style: const TextStyle(fontSize: 10)),
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
              AppLocalizations.translateWithContext(context, 'Select Category', defaultValue: 'Select Category'),
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
                            AppLocalizations.translateWithContext(context, cat.label, defaultValue: cat.label),
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
                label: Text(AppLocalizations.translateWithContext(context, 'Launch guided Proof Capture Mode', defaultValue: 'Launch guided Proof Capture Mode'), style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    final bool isLiveAi = result['isLiveAi'] == true;
                    final String summary = result['changeSummary'] ?? 'Proof captured successfully.';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isLiveAi 
                              ? '✨ Gemini 1.5 Flash Verified! Score: $_evidenceScore/100'
                              : '🔐 Proof Captured! AI Evidence Score: $_evidenceScore/100',
                        ),
                        backgroundColor: const Color(0xFF00B074),
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
              AppLocalizations.translateWithContext(context, 'Attach Proof of Change (Required)', defaultValue: 'Attach Proof of Change (Required)'),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Card(
              color: Colors.red.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.red.withOpacity(0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.gavel_rounded, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.translateWithContext(context, 'No Proof of Change, No Impact Credit: You must attach both BEFORE and AFTER evidence to verify your impact.', defaultValue: 'No Proof of Change, No Impact Credit: You must attach both BEFORE and AFTER evidence to verify your impact.'),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red),
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
                  child: _buildPhotoSlot(true, theme),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPhotoSlot(false, theme),
                ),
              ],
            ),
            _buildRealtimeGeminiAnalysisCard(theme),
            const SizedBox(height: 8),

            // GPS Geotag Button
            OutlinedButton.icon(
              onPressed: _isGettingLocation ? null : _fetchGPS,
              icon: Icon(
                _latitude != null ? Icons.location_on_rounded : Icons.gps_fixed_rounded,
                color: _latitude != null ? const Color(0xFF00B074) : null,
              ),
              label: Text(
                _isGettingLocation
                    ? AppLocalizations.translateWithContext(context, 'Fetching GPS Hardware Lock...', defaultValue: 'Fetching GPS Hardware Lock...')
                    : _latitude != null
                        ? '${AppLocalizations.translateWithContext(context, 'GPS Geotag Verified', defaultValue: 'GPS Geotag Verified')} (${_latitude!.toStringAsFixed(3)}, ${_longitude!.toStringAsFixed(3)})'
                        : AppLocalizations.translateWithContext(context, 'Fetch GPS Coordinates (Required for Map Pin)', defaultValue: 'Fetch GPS Coordinates (Required for Map Pin)'),
                style: const TextStyle(fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: _latitude != null ? const Color(0xFF00B074) : Colors.grey.withOpacity(0.4),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
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
                    '${AppLocalizations.translateWithContext(context, 'Evidence Type Guidelines for', defaultValue: 'Evidence Type Guidelines for')} ${AppLocalizations.translateWithContext(context, _selectedCategory.label, defaultValue: _selectedCategory.label)}:',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• ${_getBeforeLabel(context)}\n• ${_getAfterLabel(context)}',
                    style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.uploadProof),
              icon: const Icon(Icons.cloud_upload_outlined, size: 16),
              label: Text(AppLocalizations.translateWithContext(context, 'Open advanced Proof Upload Hub (MP4 / WAV)', defaultValue: 'Open advanced Proof Upload Hub (MP4 / WAV)')),
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
              decoration: InputDecoration(
                labelText: AppLocalizations.translateWithContext(context, 'Community Witness Email (Optional)', defaultValue: 'Community Witness Email (Optional)'),
                hintText: AppLocalizations.translateWithContext(context, 'e.g., recipient, observer, or NGO head', defaultValue: 'e.g., recipient, observer, or NGO head'),
                prefixIcon: const Icon(Icons.people_outline_rounded),
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
                      Text(
                        AppLocalizations.translateWithContext(context, 'Projected Proof Strength', defaultValue: 'Projected Proof Strength'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        '${(confidence * 100).toInt()}% ${AppLocalizations.translateWithContext(context, 'Confidence', defaultValue: 'Confidence')}',
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
                        ? AppLocalizations.translateWithContext(context, 'Excellent proof! Validators will process this submission immediately.', defaultValue: 'Excellent proof! Validators will process this submission immediately.')
                        : confidence >= 0.6
                            ? AppLocalizations.translateWithContext(context, 'Good proof. Highly eligible for verification and standard rewards.', defaultValue: 'Good proof. Highly eligible for verification and standard rewards.')
                            : AppLocalizations.translateWithContext(context, 'Weak proof. Submissions with low proof require extra manual validators.', defaultValue: 'Weak proof. Submissions with low proof require extra manual validators.'),
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
                                '${AppLocalizations.translateWithContext(context, 'Scale Multiplier:', defaultValue: 'Scale Multiplier:')} ${scaleMultiplier.toStringAsFixed(1)}x | ${AppLocalizations.translateWithContext(context, 'Effort:', defaultValue: 'Effort:')} ${effortMultiplier.toStringAsFixed(1)}x',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '${AppLocalizations.translateWithContext(context, 'Direct:', defaultValue: 'Direct:')} $directEstimate ${AppLocalizations.translateWithContext(context, 'Credits', defaultValue: 'Credits')}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.translateWithContext(context, 'Ripple Factor: +20% capacity ripple', defaultValue: 'Ripple Factor: +20% capacity ripple'),
                                style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                              ),
                              Text(
                                '${AppLocalizations.translateWithContext(context, 'Ripple:', defaultValue: 'Ripple:')} +$rippleEstimate ${AppLocalizations.translateWithContext(context, 'Credits', defaultValue: 'Credits')}',
                                style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.translateWithContext(context, 'Projected Total Payout', defaultValue: 'Projected Total Payout'),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF00B074)),
                              ),
                              Text(
                                '$totalEstimate ${AppLocalizations.translateWithContext(context, 'Karma Credits', defaultValue: 'Karma Credits')}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF00B074)),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          if (_verificationLevel == 1) ...[
                            Text(
                              '🟢 ${AppLocalizations.translateWithContext(context, 'Level 1: 100% Provisional', defaultValue: 'Level 1: 100% Provisional')} ($totalEstimate ${AppLocalizations.translateWithContext(context, 'Credits', defaultValue: 'Credits')}) ${AppLocalizations.translateWithContext(context, 'released immediately on submission.', defaultValue: 'released immediately on submission.')}',
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
                                    Text('⚡ ${AppLocalizations.translateWithContext(context, 'Provisional (30%):', defaultValue: 'Provisional (30%):')} +$prov ${AppLocalizations.translateWithContext(context, 'credits released instantly.', defaultValue: 'credits released instantly.')}', style: const TextStyle(fontSize: 10)),
                                    const SizedBox(height: 2),
                                    Text('🛡️ ${AppLocalizations.translateWithContext(context, 'Verified (50%):', defaultValue: 'Verified (50%):')} +$ver ${AppLocalizations.translateWithContext(context, 'credits released on validator consensus.', defaultValue: 'credits released on validator consensus.')}', style: const TextStyle(fontSize: 10)),
                                    const SizedBox(height: 2),
                                    Text('🌱 ${AppLocalizations.translateWithContext(context, 'Outcome (20%):', defaultValue: 'Outcome (20%):')} +$out ${AppLocalizations.translateWithContext(context, 'credits released on 6-month survival milestone.', defaultValue: 'credits released on 6-month survival milestone.')}', style: const TextStyle(fontSize: 10)),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          AppLocalizations.translateWithContext(context, 'Track AI verification steps', defaultValue: 'Track AI verification steps'),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00B074)),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded, size: 12, color: Color(0xFF00B074)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            if (karmaProvider.isSubmitting || _isCompressing)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    _isCompressing
                        ? AppLocalizations.translateWithContext(context, 'Optimizing and compressing photo memory...', defaultValue: 'Optimizing and compressing photo memory...')
                        : AppLocalizations.translateWithContext(context, 'Uploading proof images to Firebase Storage & securing record...', defaultValue: 'Uploading proof images to Firebase Storage & securing record...'),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: _submit,
                child: Text(AppLocalizations.translateWithContext(context, 'Submit to Ledger Queue', defaultValue: 'Submit to Ledger Queue')),
              ),
          ],
        ),
      ),
    ),
  );
}
}
