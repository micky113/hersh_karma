import 'package:flutter/material.dart';

class AiStatusScreen extends StatelessWidget {
  const AiStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('AI Verification Status')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.query_stats_rounded, color: Color(0xFF00B074), size: 48),
                  SizedBox(height: 12),
                  Text('Auditing Current Submission', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Text('Estimated consensus: 85%', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'AI AUDIT PIPELINE LOGS',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            _buildPipelineStep('Pixel Authentication', 'PASSED • Neural nets parsed sapling count correctly (5 detected).', true),
            _buildPipelineStep('EXIF Metadata Verification', 'PASSED • GPS coordinates and camera model timestamps validated.', true),
            _buildPipelineStep('Anomalous Image Detection', 'PASSED • No traces of tampering or generative AI duplication.', true),
            _buildPipelineStep('Witness Trust Consensus', 'PENDING • Waiting for 1 observer nodes to reply to confirmation email.', false),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close Tracker'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineStep(String title, String desc, bool isPassed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isPassed ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
            color: isPassed ? const Color(0xFF00B074) : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
