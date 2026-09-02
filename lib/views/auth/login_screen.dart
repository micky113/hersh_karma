import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../firebase_options.dart';
import '../../services/firebase/web_google_auth.dart';
import '../../providers/auth_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../models/user_profile.dart';
import '../widgets/visual_journey_banner.dart';
import '../support/language_hub_modal.dart';
import '../support/feedback_modal.dart';
import '../../core/localization/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  UserRole _selectedRole = UserRole.individual;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit({String? targetRoute}) async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success;

    if (_isSignUp) {
      success = await authProvider.signUp(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        role: _selectedRole,
      );
    } else {
      success = await authProvider.login(
        _emailController.text,
        _passwordController.text,
      );
    }

    if (success && mounted) {
      if (_isSignUp) {
        Navigator.pushReplacementNamed(context, AppRoutes.createProfile);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        if (targetRoute != null) {
          Navigator.pushNamed(context, targetRoute);
        }
      }
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Authentication failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _quickLogin(String email, String password, {String? targetRoute}) {
    _emailController.text = email;
    _passwordController.text = password;
    setState(() {
      _isSignUp = false;
    });
    _submit(targetRoute: targetRoute);
  }

  void _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      if (kIsWeb) {
        final googleUser = await WebGoogleAuth.triggerGooglePopup();
        if (googleUser != null) {
          final email = googleUser['email'];
          final displayName = googleUser['displayName'];
          final success = await authProvider.signInWithGoogle(
            email: email,
            name: displayName,
          );
          if (success && mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        }
      } else {
        final success = await authProvider.signInWithGoogle(
          email: 'user@gmail.com',
          name: 'Google Contributor',
        );
        if (success && mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString();
        if (msg.contains('popup-closed-by-user') || msg.contains('closed by user') || msg.contains('popup_closed_by_user')) {
          msg = 'Sign-in cancelled. Please select your Google account in the popup.';
        } else if (msg.contains('operation-not-allowed') || msg.contains('auth/operation-not-allowed')) {
          msg = 'Google provider is not enabled in Firebase Console. Please enable it in Authentication > Sign-in method.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In: $msg'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.favorite_rounded, color: Color(0xFF00B074), size: 20),
            const SizedBox(width: 8),
            Text(
              'Karma Grid',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF00B074),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline_rounded, color: Colors.amber),
            tooltip: 'Improve Karma Grid',
            onPressed: () {
              FeedbackModal.show(context, 'Homepage');
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.language_rounded, color: Color(0xFF00B074), size: 16),
            label: const Text('🌐 Language / भाषा', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF00B074))),
            onPressed: () => LanguageHubModal.show(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Section
              const SizedBox(height: 12),
              Text(
                'Karma Grid',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF00B074),
                ),
              ),
              Text(
                'Proof of Good',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '“Do good. Show the difference. Create impact.”',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF00B074)),
              ),
              const SizedBox(height: 8),
              Text(
                'Do something good, report a problem, prove the change, earn Karma and help create more good.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[750], height: 1.4),
              ),
              const SizedBox(height: 24),

              // Visual Proof Flow Card
              Card(
                elevation: 1,
                color: const Color(0xFF00B074).withOpacity(0.04),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _JourneyStep(label: 'BEFORE', icon: '📸'),
                        _JourneyArrow(),
                        _JourneyStep(label: 'DO / FIX', icon: '⚡'),
                        _JourneyArrow(),
                        _JourneyStep(label: 'AFTER', icon: '📸'),
                        _JourneyArrow(),
                        _JourneyStep(label: 'VERIFIED', icon: '✓', color: Color(0xFF00B074)),
                        _JourneyArrow(),
                        _JourneyStep(label: 'IMPACT', icon: '🌍', color: Colors.blue),
                        _JourneyArrow(),
                        _JourneyStep(label: 'KARMA', icon: '✨', color: Colors.orange),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Universal Search Bar Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  onTap: () {
                    // Quick login to access search
                    _quickLogin('john@karma.com', 'password123', targetRoute: AppRoutes.search);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 12),
                        Text(
                          '🔎 What are you looking for?',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        Spacer(),
                        Icon(Icons.mic, color: Colors.red),
                        SizedBox(width: 4),
                        Text('Talk to Karma', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Primary Actions Row
              Row(
                children: [
                  Expanded(
                    child: _PrimaryActionCard(
                      title: '🌱 DO GOOD',
                      subtitle: 'Find something meaningful to do.',
                      examples: 'Plant a tree • Clean a place • Help someone • Teach a skill',
                      color: Colors.green,
                      onTap: () => _quickLogin('john@karma.com', 'password123'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PrimaryActionCard(
                      title: '🔎 REPORT A PROBLEM',
                      subtitle: 'See something that needs fixing?',
                      examples: 'Garbage • Pothole • Broken streetlight • Animal in danger',
                      color: Colors.amber[700]!,
                      onTap: () => _quickLogin('john@karma.com', 'password123', targetRoute: AppRoutes.reportAbuse),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Secondary Actions Row
              Row(
                children: [
                  Expanded(
                    child: _SecondaryActionCard(
                      title: '✨ MAKE A WISH',
                      subtitle: 'Have a meaningful wish? Tell us.',
                      color: Colors.purple,
                      onTap: () => _quickLogin('john@karma.com', 'password123', targetRoute: AppRoutes.createWish),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SecondaryActionCard(
                      title: '🤝 HELP A WISH',
                      subtitle: 'Help make someone\'s wish possible.',
                      color: Colors.blue,
                      onTap: () => _quickLogin('john@karma.com', 'password123', targetRoute: AppRoutes.wishes),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // India-First Section
              Card(
                color: Colors.orange.withOpacity(0.04),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.orange.withOpacity(0.15)),
                ),
                child: ListTile(
                  leading: const Text('🇮🇳', style: TextStyle(fontSize: 28)),
                  title: const Text('Create Good in India', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: const Text('Discover actions and problems that can make your community better.', style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.orange),
                  onTap: () => _quickLogin('john@karma.com', 'password123', targetRoute: AppRoutes.indiaMission),
                ),
              ),
              const SizedBox(height: 28),

              // Light Social Proof
              const Text(
                'VERIFIED REAL-WORLD IMPACT (DEMO DATA)',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildProofStatCard('1,240', 'actions verified\nthis month')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildProofStatCard('8,420', 'people\nparticipating')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildProofStatCard('320', 'community problems\nreported')),
                ],
              ),
              const SizedBox(height: 16),

              // Compact Before -> After Impact Card Showcase
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildShowcaseCard(
                      '🌱 Clean Composting Drive',
                      'Delhi, IN',
                      'assets/proofs/compost_before.jpg',
                      'assets/proofs/compost_after.jpg',
                      'Compost bin loaded ➔ Verified',
                    ),
                    const SizedBox(width: 12),
                    _buildShowcaseCard(
                      '🐕 Street Animal Vet Aid',
                      'Tel Aviv, IL',
                      'assets/proofs/dog_before.jpg',
                      'assets/proofs/dog_after.jpg',
                      'Vet prescription logged ➔ Verified',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Four Simple Ideas
              const Text(
                'FOUR SIMPLE IDEAS',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 1.2),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildIdeaColumn('🌱 DO', 'create positive action')),
                  Expanded(child: _buildIdeaColumn('🔎 REPORT', 'identify something that needs help')),
                  Expanded(child: _buildIdeaColumn('🛠️ FIX', 'help solve it')),
                  Expanded(child: _buildIdeaColumn('📸 PROVE', 'show what changed')),
                ],
              ),
              const SizedBox(height: 24),

              // Visual Proof-of-Good Journey Stepper
              const VisualJourneyBanner(compact: false),
              const SizedBox(height: 24),

              // Karma Core Rule
              Card(
                color: Colors.blueGrey.withOpacity(0.04),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        '💡 THE KARMA RULE',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blueGrey, letterSpacing: 1),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '“Karma is earned from verified positive impact, not from simply clicking buttons.”',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Auth Card
              Card(
                elevation: 3,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B074).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.verified_user_rounded, color: Color(0xFF00B074), size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Access Your Karma Passport',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Sign in with your Google account to record actions & earn Karma',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (authProvider.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00B074),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 2,
                          ),
                          onPressed: () => _handleGoogleSignIn(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('🇬', style: TextStyle(fontSize: 16)),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Continue with Google / Gmail',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shield_outlined, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            'One-click secure Google verification • Zero passwords',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Footer
              const Divider(),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildFooterLink('How It Works'),
                  const Text('•', style: TextStyle(color: Colors.grey)),
                  _buildFooterLink('For Individuals'),
                  const Text('•', style: TextStyle(color: Colors.grey)),
                  _buildFooterLink('Schools'),
                  const Text('•', style: TextStyle(color: Colors.grey)),
                  _buildFooterLink('NGOs'),
                  const Text('•', style: TextStyle(color: Colors.grey)),
                  _buildFooterLink('Companies'),
                  const Text('•', style: TextStyle(color: Colors.grey)),
                  _buildFooterLink('Privacy'),
                  const Text('•', style: TextStyle(color: Colors.grey)),
                  _buildFooterLink('Safety'),
                  const Text('•', style: TextStyle(color: Colors.grey)),
                  _buildFooterLink('Languages'),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                '“Anyone can participate. Every good action can create a ripple.”\n© 2026 Karma Grid',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.grey, height: 1.4),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProofStatCard(String val, String text) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF00B074))),
            const SizedBox(height: 4),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9, color: Colors.grey, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowcaseCard(String title, String loc, String beforeUrl, String afterUrl, String note) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11), overflow: TextOverflow.ellipsis),
              ),
              Text(loc, style: const TextStyle(fontSize: 9, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Text('BEFORE 📸', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Text('AFTER 📸', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(note, style: const TextStyle(fontSize: 9, fontStyle: FontStyle.italic, color: Color(0xFF00B074))),
        ],
      ),
    );
  }

  Widget _buildIdeaColumn(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF00B074))),
          const SizedBox(height: 4),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: Colors.grey, height: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String label) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Footer Option: $label coming soon!')),
        );
      },
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _JourneyStep extends StatelessWidget {
  final String label;
  final String icon;
  final Color? color;

  const _JourneyStep({required this.label, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _JourneyArrow extends StatelessWidget {
  const _JourneyArrow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.grey),
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String examples;
  final Color color;
  final VoidCallback onTap;

  const _PrimaryActionCard({
    required this.title,
    required this.subtitle,
    required this.examples,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: color),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              ),
              const SizedBox(height: 8),
              Text(
                examples,
                style: TextStyle(fontSize: 9, color: Colors.grey[600], height: 1.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SecondaryActionCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.12), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: color),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 9, color: Colors.grey[650]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
