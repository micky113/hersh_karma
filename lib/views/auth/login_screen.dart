import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../models/user_profile.dart';
import '../support/language_hub_modal.dart';

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

  void _submit() async {
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

  void _quickLogin(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
    setState(() {
      _isSignUp = false;
    });
    _submit();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.language_rounded, color: Color(0xFF00B074)),
                  label: const Text('🌐 Language / भाषा', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00B074))),
                  onPressed: () => LanguageHubModal.show(context),
                ),
              ),
              const SizedBox(height: 12),
              const Icon(
                Icons.favorite_rounded,
                size: 72,
                color: Color(0xFF00B074),
              ),
              const SizedBox(height: 16),
              Text(
                'Karma Grid — Proof of Good',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF00B074),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Do good. Prove it. Create impact. Make wishes possible.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPillarBadge('🌱 Actions'),
                  _buildPillarBadge('🔐 Proof'),
                  _buildPillarBadge('🌍 Impact'),
                  _buildPillarBadge('✨ Wishes'),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shadowColor: Colors.black12,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isSignUp ? 'Create Passport' : 'Access Passport',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_isSignUp) ...[
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Display Name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (val) =>
                                val == null || val.isEmpty ? 'Enter display name' : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<UserRole>(
                            value: _selectedRole,
                            decoration: const InputDecoration(
                              labelText: 'Account Role / Type',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            items: UserRole.values.map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(role.label),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedRole = val;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Passport Email / Address',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (val) =>
                              val == null || !val.contains('@') ? 'Enter a valid email' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Security PIN / Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: (val) =>
                              val == null || val.length < 6 ? 'Password must be >= 6 chars' : null,
                        ),
                        const SizedBox(height: 24),
                        if (authProvider.isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else
                          ElevatedButton(
                            onPressed: _submit,
                            child: Text(_isSignUp ? 'Sign Up' : 'Sign In'),
                          ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                            });
                          },
                          child: Text(_isSignUp
                              ? 'Already have a passport? Sign In'
                              : "Don't have a passport? Sign Up"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (!_isSignUp) ...[
                Text(
                  'Quick Accounts (Simulated System)',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _quickLogin('john@karma.com', 'password123'),
                            child: const Text('John (Individual)', style: TextStyle(fontSize: 11)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _quickLogin('jane@karma.com', 'password123'),
                            child: const Text('Jane (NGO / Org)', style: TextStyle(fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _quickLogin('school@karma.com', 'password123'),
                            child: const Text('Apex (School / Inst)', style: TextStyle(fontSize: 11)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _quickLogin('corp@karma.com', 'password123'),
                            child: const Text('CSR Tech (Corporate)', style: TextStyle(fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillarBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.12)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00B074)),
      ),
    );
  }
}
