import 'package:flutter/material.dart';

class UploadProofScreen extends StatelessWidget {
  const UploadProofScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Proof Upload Hub')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.cloud_upload_outlined,
              size: 72,
              color: Color(0xFF00B074),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Verification Files',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Attach raw photo, video, or audio logs. The AI algorithm will parse metadata, GPS timestamps, and pixels to calculate a confidence score.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildUploadBtn(Icons.image_rounded, 'Upload Photo Proof (JPEG/PNG)', theme),
            const SizedBox(height: 12),
            _buildUploadBtn(Icons.video_file_rounded, 'Upload Video Capture (MP4)', theme),
            const SizedBox(height: 12),
            _buildUploadBtn(Icons.mic_rounded, 'Upload Audio Witness Testimony (WAV)', theme),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Confirm & Return'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBtn(IconData icon, String label, ThemeData theme) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
