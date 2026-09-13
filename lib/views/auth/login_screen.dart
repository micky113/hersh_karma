import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../../services/firebase/web_google_auth.dart';
import '../../providers/auth_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../models/user_profile.dart';
import '../support/language_hub_modal.dart';
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
  final _confirmPasswordController = TextEditingController();

  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isAuthenticated && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoading) return; // Prevent duplicate requests

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    bool success;

    if (_isSignUp) {
      final name = _nameController.text.trim();
      success = await authProvider.signUp(
        name,
        email,
        password,
        role: UserRole.individual,
      );
    } else {
      success = await authProvider.login(email, password);
    }

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (!success && mounted) {
      final rawError = authProvider.error ?? 'Authentication failed';
      String friendlyError = 'We couldn\'t sign you in. Please check your credentials and try again.';

      if (rawError.toLowerCase().contains('password')) {
        friendlyError = 'Incorrect password. Please verify your password and try again.';
      } else if (rawError.toLowerCase().contains('email') || rawError.toLowerCase().contains('user')) {
        friendlyError = 'Account error: please check the email entered.';
      } else if (rawError.toLowerCase().contains('network')) {
        friendlyError = 'Network connection issue. Please check your internet connection.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(friendlyError),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoading) return;

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
          msg = 'Sign-in was cancelled. Please try again.';
        } else if (msg.contains('operation-not-allowed')) {
          msg = 'Google sign-in is currently unavailable.';
        } else {
          msg = 'Unable to complete Google Sign-In. Please check your connection.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text.trim());
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Form(
          key: dialogFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your registered email address or phone to receive password reset instructions.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: resetEmailController,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Email or Phone',
                  hintText: 'name@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your email or phone';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B074),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              if (dialogFormKey.currentState!.validate()) {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final res = await auth.resetPassword(resetEmailController.text.trim());
                if (mounted) {
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        res
                            ? 'Password reset instructions sent to ${resetEmailController.text.trim()}.'
                            : (auth.error ?? 'Could not send reset instructions.'),
                      ),
                      backgroundColor: res ? const Color(0xFF00B074) : Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.language_rounded, color: Color(0xFF00B074), size: 16),
            label: const Text(
              '🌐 Language / भाषा',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF00B074)),
            ),
            onPressed: () => LanguageHubModal.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. ELEGANT BRAND HEADER
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B074).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_rounded, color: Color(0xFF00B074), size: 36),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.translateWithContext(context, 'app_title', defaultValue: 'Karma Grid'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF00B074),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.translateWithContext(context, 'app_tagline', defaultValue: 'Proof of Good'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '«${AppLocalizations.translateWithContext(context, 'app_hero_sub', defaultValue: 'Do good. Show the difference. Create verified impact.')}»',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white60 : Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // 2. AUTHENTICATION CARD
                Card(
                  elevation: isDark ? 0 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _isSignUp
                                ? AppLocalizations.translateWithContext(context, 'login_create_account', defaultValue: 'Create your Account')
                                : AppLocalizations.translateWithContext(context, 'login_welcome_back', defaultValue: 'Welcome to Karma Grid'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isSignUp
                                ? AppLocalizations.translateWithContext(context, 'login_sub_signup', defaultValue: 'Join the community of verified impact')
                                : AppLocalizations.translateWithContext(context, 'login_sub_welcome', defaultValue: 'Enter to record deeds, verify impact, and earn Karma'),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Full Name (Only for Registration)
                          if (_isSignUp) ...[
                            TextFormField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.translateWithContext(context, 'login_fullname', defaultValue: 'Full Name'),
                                hintText: AppLocalizations.translateWithContext(context, 'login_fullname_hint', defaultValue: 'Your name'),
                                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Email / Phone Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.translateWithContext(context, 'login_email_phone', defaultValue: 'Email or Phone'),
                              hintText: 'name@example.com',
                              prefixIcon: const Icon(Icons.email_outlined, size: 20),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your email or phone';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.translateWithContext(context, 'login_password', defaultValue: 'Password'),
                              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (_isSignUp && val.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          // Confirm Password (Only for Registration)
                          if (_isSignUp) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.translateWithContext(context, 'login_confirm_password', defaultValue: 'Confirm Password'),
                                prefixIcon: const Icon(Icons.lock_reset_rounded, size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (val != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ],

                          // Forgot Password link (Only on Login mode)
                          if (!_isSignUp) ...[
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _showForgotPasswordDialog,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  AppLocalizations.translateWithContext(context, 'login_forgot_password', defaultValue: 'Forgot password?'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ] else ...[
                            const SizedBox(height: 20),
                          ],

                          // PRIMARY ACTION BUTTON (Login or Create Account)
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00B074),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: authProvider.isLoading ? null : _submit,
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(
                                      _isSignUp
                                          ? AppLocalizations.translateWithContext(context, 'login_btn_create', defaultValue: 'Create Account')
                                          : AppLocalizations.translateWithContext(context, 'login_btn', defaultValue: 'LOGIN'),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Divider "OR"
                          Row(
                            children: [
                              Expanded(child: Divider(color: isDark ? Colors.white12 : Colors.grey.shade300)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Text(
                                  AppLocalizations.translateWithContext(context, 'login_or', defaultValue: 'OR'),
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                ),
                              ),
                              Expanded(child: Divider(color: isDark ? Colors.white12 : Colors.grey.shade300)),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // GOOGLE SIGN IN BUTTON
                          SizedBox(
                            height: 46,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: authProvider.isLoading ? null : _handleGoogleSignIn,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.grey.shade300, width: 0.5),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'G',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    AppLocalizations.translateWithContext(context, 'login_google_btn', defaultValue: 'Continue with Google'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // QUICK 1-TAP DEMO & ADMIN LOGINS
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B074).withOpacity(isDark ? 0.12 : 0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF00B074).withOpacity(0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Text('⚡ ', style: TextStyle(fontSize: 14)),
                                    Expanded(
                                      child: Text(
                                        'Quick Demo & Admin 1-Tap Logins:',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    _buildQuickLoginChip('👑 Super Admin', 'governance@karma.org', 'password123'),
                                    _buildQuickLoginChip('🤝 Jane (NGO)', 'jane@karma.com', 'password123'),
                                    _buildQuickLoginChip('🏫 Apex School', 'school@karma.com', 'password123'),
                                    _buildQuickLoginChip('🏢 CSR TechCorp', 'corp@karma.com', 'password123'),
                                    _buildQuickLoginChip('👤 John Doe', 'john@karma.com', 'password123'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // TOGGLE LOGIN / SIGN UP
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                _isSignUp
                                    ? AppLocalizations.translateWithContext(context, 'login_already_have_acc', defaultValue: 'Already have an account? ')
                                    : AppLocalizations.translateWithContext(context, 'login_dont_have_acc', defaultValue: 'Don\'t have an account? '),
                                style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey.shade600),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isSignUp = !_isSignUp;
                                    _formKey.currentState?.reset();
                                  });
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  _isSignUp
                                      ? AppLocalizations.translateWithContext(context, 'login_signin_link', defaultValue: 'Sign In')
                                      : AppLocalizations.translateWithContext(context, 'login_btn_create', defaultValue: 'Create Account'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Color(0xFF00B074),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Trust footer
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(Icons.shield_outlined, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.translateWithContext(context, 'login_secured_by', defaultValue: 'Secured by Proof of Good Integrity Ledger'),
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLoginChip(String label, String email, String password) {
    return ActionChip(
      visualDensity: VisualDensity.compact,
      label: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.white.withOpacity(0.9),
      side: BorderSide(color: const Color(0xFF00B074).withOpacity(0.35)),
      onPressed: () {
        setState(() {
          _isSignUp = false;
          _emailController.text = email;
          _passwordController.text = password;
        });
        _submit();
      },
    );
  }
}
