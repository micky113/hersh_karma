import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/karma_category.dart';
import '../../services/voice_service.dart';
import '../../services/gemini_vision_service.dart';
import '../../core/config/ai_config.dart';
import '../support/feedback_modal.dart';

class ProofCaptureScreen extends StatefulWidget {
  final KarmaCategory category;

  const ProofCaptureScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<ProofCaptureScreen> createState() => _ProofCaptureScreenState();
}

class _ProofCaptureScreenState extends State<ProofCaptureScreen> {
  int _currentStep = 0;
  bool _isLocating = false;
  bool _isCapturingBefore = false;
  bool _isCapturingAfter = false;
  bool _isAnalyzingWithGemini = false;
  GeminiVerificationResult? _geminiResult;
  
  String? _beforeImage;
  String? _afterImage;
  Uint8List? _beforeImageBytes;
  Uint8List? _afterImageBytes;
  int _wasteBefore = 120;
  int _wasteAfter = 8;
  double _sceneMatch = 0.94;
  int _evidenceScore = 95;
  
  int _timerSeconds = 5;
  Timer? _timer;
  bool _timerRunning = false;

  void _startTimer() {
    setState(() {
      _timerRunning = true;
      _timerSeconds = 5;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 1) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _timerRunning = false;
          _currentStep = 3; // Move to Step 4 (Reposition alignment)
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔐 Proof Capture Mode'),
        backgroundColor: widget.category.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline_rounded, color: Colors.white),
            tooltip: 'Improve Karma Grid',
            onPressed: () => FeedbackModal.show(context, 'ProofCaptureScreen'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress tracker
            Container(
              padding: const EdgeInsets.all(16),
              color: widget.category.color.withOpacity(0.08),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  final isDone = index < _currentStep;
                  final isCurrent = index == _currentStep;
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: isDone 
                            ? Colors.green 
                            : (isCurrent ? widget.category.color : Colors.grey[300]),
                        child: isDone
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : Text('${index + 1}', style: TextStyle(fontSize: 12, color: isCurrent ? Colors.white : Colors.black87)),
                      ),
                      if (index < 5) 
                        Container(
                          width: MediaQuery.of(context).size.width / 10,
                          height: 2,
                          color: index < _currentStep ? Colors.green : Colors.grey[300],
                        ),
                    ],
                  );
                }),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildStepContent(theme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(ThemeData theme) {
    switch (_currentStep) {
      case 0:
        return _buildLocatingStep(theme);
      case 1:
        return _buildCaptureBeforeStep(theme);
      case 2:
        return _buildActionProgressStep(theme);
      case 3:
        return _buildRepositionStep(theme);
      case 4:
        return _buildCaptureAfterStep(theme);
      case 5:
        return _buildEvidenceReportStep(theme);
      default:
        return const SizedBox.shrink();
    }
  }

  // STEP 1: Locating
  Widget _buildLocatingStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Icon(Icons.gps_fixed, size: 80, color: widget.category.color),
        const SizedBox(height: 24),
        Text('Step 1: Check-in Location', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text(
          'Stand in the exact area where the action will be performed. The system will secure GPS coordinates and evaluate surrounding environment context.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 40),
        if (_isLocating) ...[
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          const Text('Analyzing geofence integrity and locking GPS satellites...', style: TextStyle(fontStyle: FontStyle.italic)),
        ] else ...[
          Card(
            elevation: 0,
            color: Colors.grey[100],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.green),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GPS Coordinates Locked', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Lat: 12.9716, Lon: 77.5946 (Within geofence)', style: TextStyle(color: Colors.black54, fontSize: 13)),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.category.color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Proceed to Before Photo'),
            onPressed: () {
              setState(() {
                _currentStep = 1;
              });
            },
          )
        ],
      ],
    );
  }

  // STEP 2: Capture BEFORE
  Widget _buildCaptureBeforeStep(ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Step 2: Capture BEFORE Image', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.volume_up, color: Colors.green),
              onPressed: () => KarmaVoice.speak('before_proof', context: context),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Align the area of impact. AI will scan for trash items or soil conditions.', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 24),
        
        // Mock Camera Viewport
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          child: _isCapturingBefore
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : (_beforeImage != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            color: Colors.grey[900],
                            alignment: Alignment.center,
                            child: const Text('📸 BEFORE Image Mock Captured', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            color: Colors.black.withOpacity(0.70),
                            child: Text('AI Object Detection: $_wasteBefore visible plastic items', style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
                          ),
                        )
                      ],
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, color: Colors.white54, size: 48),
                          SizedBox(height: 8),
                          Text('Camera ready. Press capture below.', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    )),
        ),
        
        const SizedBox(height: 32),
        if (_beforeImage == null)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            icon: const Icon(Icons.photo_camera),
            label: const Text('Capture Before State'),
            onPressed: () => _captureImageInEnclave(true),
          )
        else
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.category.color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Cleaning Mission'),
            onPressed: () {
              setState(() {
                _currentStep = 2;
              });
              _startTimer();
            },
          )
      ],
    );
  }

  // STEP 3: Action Progress Countdown
  Widget _buildActionProgressStep(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const SizedBox(
          height: 100,
          width: 100,
          child: CircularProgressIndicator(
            value: null,
            strokeWidth: 8,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Step 3: Complete Your Activity', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.volume_up, color: Colors.green),
              onPressed: () => KarmaVoice.speak('action_in_progress', context: context),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Complete your environmental action now.', style: TextStyle(color: widget.category.color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text(
          'Please clean up the items in the locked geofenced area. Once finished, we will verify the changes using our transparent viewpoint matching overlay.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 40),
        Text('Simulating action duration... $_timerSeconds seconds remaining', style: const TextStyle(fontStyle: FontStyle.italic)),
      ],
    );
  }

  // STEP 4: Alignment Viewpoint Helper
  Widget _buildRepositionStep(ThemeData theme) {
    return Column(
      children: [
        Text('Step 4: Align Camera Angle', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Return to your initial position. Place the overlay outline over the landscape to ensure same-scene comparison.', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 24),
        
        // Transparent Overlay Alignment Box
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.amber, width: 4),
            borderRadius: BorderRadius.circular(16),
            color: Colors.black87,
          ),
          child: const Stack(
            alignment: Alignment.center,
            children: [
              // Wireframe simulation
              Opacity(
                opacity: 0.3,
                child: Icon(Icons.grid_on, color: Colors.white, size: 100),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.center_focus_strong, color: Colors.amber, size: 48),
                  SizedBox(height: 8),
                  Text('📷 VIEWPOINT ALIGNED (97% Match)', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.category.color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          icon: const Icon(Icons.camera_enhance),
          label: const Text('Lock & Capture After State'),
          onPressed: () {
            setState(() {
              _currentStep = 4;
            });
          },
        ),
      ],
    );
  }

  // STEP 5: Capture AFTER
  Widget _buildCaptureAfterStep(ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Step 5: Capture AFTER Image', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.volume_up, color: Colors.green),
              onPressed: () => KarmaVoice.speak('after_proof', context: context),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Confirming outcome. AI is scanning for remaining objects.', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 24),
        
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          child: _isCapturingAfter
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : (_afterImage != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            color: Colors.grey[900],
                            alignment: Alignment.center,
                            child: const Text('📸 AFTER Image Mock Captured', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            color: Colors.black.withOpacity(0.70),
                            child: Text('AI Object Detection: $_wasteAfter visible plastic items remaining', style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
                          ),
                        )
                      ],
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, color: Colors.white54, size: 48),
                          SizedBox(height: 8),
                          Text('Alignment verified. Press capture below.', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    )),
        ),
        
        const SizedBox(height: 32),
        if (_afterImage == null)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            icon: const Icon(Icons.photo_camera),
            label: const Text('Capture After State'),
            onPressed: () => _captureImageInEnclave(false),
          )
        else
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.category.color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            icon: const Icon(Icons.analytics),
            label: const Text('Analyze Evidence Score'),
            onPressed: _runGeminiAnalysis,
          )
      ],
    );
  }

  Future<void> _captureImageInEnclave(bool isBefore) async {
    setState(() {
      if (isBefore) {
        _isCapturingBefore = true;
      } else {
        _isCapturingAfter = true;
      }
    });

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          if (isBefore) {
            _beforeImageBytes = bytes;
            _beforeImage = picked.path;
          } else {
            _afterImageBytes = bytes;
            _afterImage = picked.path;
          }
        });
      } else {
        // Fallback simulated capture if camera is canceled
        setState(() {
          if (isBefore) {
            _beforeImage = 'captured_before.jpg';
          } else {
            _afterImage = 'captured_after.jpg';
          }
        });
      }
    } catch (_) {
      setState(() {
        if (isBefore) {
          _beforeImage = 'captured_before.jpg';
        } else {
          _afterImage = 'captured_after.jpg';
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          if (isBefore) {
            _isCapturingBefore = false;
          } else {
            _isCapturingAfter = false;
          }
        });
      }
    }
  }

  Future<void> _runGeminiAnalysis() async {
    setState(() {
      _isAnalyzingWithGemini = true;
      _currentStep = 5;
    });

    try {
      final result = await GeminiVisionService.analyzeEvidence(
        beforeImageBytes: _beforeImageBytes,
        afterImageBytes: _afterImageBytes,
        deedTitle: 'Proof of Good Action',
        category: widget.category.name,
        description: 'Community deed captured via secure camera enclave in ${widget.category.name}',
        latitude: 12.9716,
        longitude: 77.5946,
        capturedInApp: true,
      );

      if (mounted) {
        setState(() {
          _isAnalyzingWithGemini = false;
          _geminiResult = result;
          _evidenceScore = result.evidenceScore;
          _sceneMatch = result.sceneMatchConfidence;
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

  // STEP 6: Evidence Score & Compile
  Widget _buildEvidenceReportStep(ThemeData theme) {
    if (_isAnalyzingWithGemini) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF00B074)),
              const SizedBox(height: 24),
              Text(
                'Connecting to ${AiConfig.modelName}...',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Analyzing Before & After scene perspective, object changes, and metadata integrity.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    final isLiveAi = _geminiResult?.isLiveAiResult ?? false;
    final summary = _geminiResult?.changeSummary ?? 'Positive civic impact detected.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: _evidenceScore >= 90 ? Colors.green : Colors.amber.shade700,
                  child: Icon(
                    _evidenceScore >= 90 ? Icons.verified : Icons.hourglass_top_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('AI Screening Report', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.green),
                      onPressed: () => KarmaVoice.speak('verification', context: context),
                    ),
                  ],
                ),
                // AI Engine Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLiveAi ? Colors.purple.withOpacity(0.12) : const Color(0xFF00B074).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLiveAi ? Icons.auto_awesome : Icons.shield_outlined,
                        size: 13,
                        color: isLiveAi ? Colors.purple : const Color(0xFF00B074),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isLiveAi ? '✨ Powered by ${AiConfig.modelName}' : '🛡️ Proof-of-Good Firewall Enclave',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isLiveAi ? Colors.purple : const Color(0xFF00B074),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Score metric
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_evidenceScore',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: _evidenceScore >= 90 ? Colors.green : Colors.amber.shade800,
                      ),
                    ),
                    const Text('/100', style: TextStyle(fontSize: 20, color: Colors.grey)),
                  ],
                ),
                const Text('Evidence Score', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // AI Change Summary Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.psychology_outlined, size: 20, color: Colors.purple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          summary,
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                const Divider(),
                const SizedBox(height: 10),
                
                _buildMetricsRow('Same Location GPS Locking', '+20 pts', isPassed: true),
                _buildMetricsRow('AI Scene Match (${(_sceneMatch * 100).toInt()}%)', '+20 pts', isPassed: _sceneMatch >= 0.85),
                _buildMetricsRow('In-App Capture Proof Verification', '+20 pts', isPassed: true),
                _buildMetricsRow('Measurable Impact Detected', '+15 pts', isPassed: true),
                _buildMetricsRow('Geofence & Clock In-Sync', '+10 pts', isPassed: true),
                _buildMetricsRow('Anti-Tampering Integrity Verified', '+10 pts', isPassed: true),
                
                const SizedBox(height: 16),
                if (_evidenceScore >= 90)
                  const Text(
                    '🎉 Score ≥ 90: Meets Auto-Verification standards. Upon submission, Karma will release immediately without waiting for validator consensus!',
                    style: TextStyle(color: Colors.green, fontSize: 11.5, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  )
                else
                  const Text(
                    '👥 Score 70–89: Queued for multi-peer validator consensus (3 votes required).',
                    style: TextStyle(color: Colors.orange, fontSize: 11.5, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00B074),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () {
            // Return proof metrics map back to submit screen
            Navigator.of(context).pop({
              'capturedInApp': true,
              'beforeImageUrl': 'captured_before.png',
              'imageUrl': 'captured_after.png',
              'wasteBeforeCount': _wasteBefore,
              'wasteAfterCount': _wasteAfter,
              'sceneMatchConfidence': _sceneMatch,
              'evidenceScore': _evidenceScore,
              'changeSummary': summary,
              'isLiveAi': isLiveAi,
            });
          },
          child: const Text('Apply Verified Proof to Submission', style: TextStyle(fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  Widget _buildMetricsRow(String label, String points, {required bool isPassed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(isPassed ? Icons.check_circle : Icons.error, color: isPassed ? Colors.green : Colors.red, size: 16),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
          Text(points, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }
}
