import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About Proof of Good')),
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
              'Proof of Good Ecosystem',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Version 1.0.0 (Beta)',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Our Vision',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'To turn everyday positive action into a measurable, verifiable digital asset. By separation of reputation credits and currency, we avoid speculative cheating while creating a transparent ecosystem of social good backed by decentralized blockchain technology.',
              style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            Text(
              'The Ripple Effect (Karma Circle)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Every deed creates a chain. When you help someone, and they later help others, the platform maps this ripple effect to show your lasting legacy of contribution.',
              style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            Text(
              'Core Principle: No Proof of Change, No Impact Credit',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'A fundamental requirement of Karma Grid is the Before → Action → After process. Every qualifying action must demonstrate a meaningful change from BEFORE to AFTER using the strongest practical evidence for that action. Karma is awarded for the verified change—not merely for performing the activity.',
              style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 48),
            const Text(
              '© 2026 Proof of Good Foundation. All rights reserved.',
              style: TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
