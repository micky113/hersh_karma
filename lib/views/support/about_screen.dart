import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About Karma Grid')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Icon(
                Icons.favorite_rounded,
                size: 64,
                color: Color(0xFF00B074),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Karma Grid — Proof of Good',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Do good. Prove it. Create impact. Make wishes possible.',
              style: TextStyle(color: Color(0xFF00B074), fontWeight: FontWeight.bold, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Version 1.0.0 (Beta)',
              style: TextStyle(color: Colors.grey, fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 40),

            Text(
              'Our Vision',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'To turn everyday positive actions into verifiable social impacts. By focusing on trust-and-safety, we make sure that contributions are validated, transparent, and routed to where they matter most.',
              style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),

            Text(
              'The Four Pillars',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildPillarRow(Icons.eco_outlined, '🌱 Actions', 'Real activities you can choose to make a difference in your local area.'),
            _buildPillarRow(Icons.add_a_photo_outlined, '🔐 Proof', 'Strict Before → Action → After capture to verify that physical change actually happened.'),
            _buildPillarRow(Icons.public_outlined, '🌍 Impact', 'Measurable contribution to people, animals, society, and our shared environment.'),
            _buildPillarRow(Icons.star_outline_rounded, '✨ Wishes', 'A network-driven plan matching sponsors, tools, and volunteers to fulfill dreams.'),
            const SizedBox(height: 24),

            Text(
              'Core Principle: No Proof of Change, No Impact Credit',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'A fundamental requirement of Karma Grid is the Before → Action → After process. Every qualifying action must demonstrate a meaningful change from BEFORE to AFTER. Karma is awarded for the verified change—not merely for performing the activity.',
              style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),

            Text(
              'Born in India. Built for Humanity. 🇮🇳 🌍',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF00B074)),
            ),
            const SizedBox(height: 8),
            Text(
              'Phase 1 — India First 🇮🇳\n'
              '• Support for Hindi + English and plans for all 22 official Eighth Schedule languages.\n'
              '• Focus on sanitation, skills, waste recovery, and India 30 flagship programs.\n'
              '• Partnerships with local schools, colleges, NGOs, and CSR teams.\n\n'
              'Phase 2 — World Ready 🌍\n'
              '• Expand language support globally (including the 12 most widely spoken languages + Hebrew with RTL layout support).\n'
              '• Connect local efforts with global carbon credits and international impact ecosystems.',
              style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 40),

            const Text(
              '© 2026 Karma Grid. All rights reserved.',
              style: TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillarRow(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF00B074)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(color: Colors.grey[700], fontSize: 11, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
