import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:storemate/app/navigation/main_navigation_screen.dart';
import 'package:storemate/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:storemate/features/auth/presentation/screens/register_screen.dart';
import 'package:storemate/features/store_setup/presentation/screens/store_setup_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  StreamSubscription<AuthState>? _authSubscription;

  bool _isPhoneLogin = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Google OAuth returns to the app through a deep link.
    // Supabase emits SIGNED_IN when the session is restored.
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      authState,
    ) {
      if (authState.event == AuthChangeEvent.signedIn &&
          authState.session != null) {
        _handleAuthenticatedUser(authState.session!.user);
      }
    });
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _login() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      final AuthResponse response;

      if (_isPhoneLogin) {
        final phone = _normalizePhoneNumber(_phoneController.text);

        response = await supabase.auth.signInWithPassword(
          phone: phone,
          password: _passwordController.text,
        );
      } else {
        response = await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      final user = response.user;

      if (user == null) {
        throw const AuthException('Unable to get the logged-in user.');
      }

      await _handleAuthenticatedUser(user);
    } on AuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // GOOGLE SIGN-IN
  // ============================================================

  Future<void> _signInWithGoogle() async {
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.flutter://signin-callback/',
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );

      // The actual authenticated session is handled by
      // onAuthStateChange above after Google redirects back.
    } on AuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to continue with Google. Please try again.'),
        ),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // AFTER AUTHENTICATION
  // ============================================================

  Future<void> _handleAuthenticatedUser(User user) async {
    try {
      final store = await Supabase.instance.client
          .from('stores')
          .select('id')
          .eq('owner_id', user.id)
          .maybeSingle();

      if (!mounted) return;

      if (store != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const StoreSetupScreen()),
          (route) => false,
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load your store. Please try again.'),
        ),
      );
    }
  }

  // ============================================================
  // PHONE NORMALIZATION
  // ============================================================

  String _normalizePhoneNumber(String value) {
    final cleaned = value.replaceAll(RegExp(r'[\s\-()]'), '');

    // StoreMate currently targets the Indian market,
    // so a 10-digit number is treated as an Indian number.
    if (cleaned.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
      return '+91$cleaned';
    }

    if (cleaned.startsWith('0') &&
        cleaned.length == 11 &&
        RegExp(r'^0[6-9]\d{9}$').hasMatch(cleaned)) {
      return '+91${cleaned.substring(1)}';
    }

    return cleaned;
  }

  // ============================================================
  // PHONE VALIDATION
  // ============================================================

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return 'Please enter your phone number';
    }

    final cleaned = phone.replaceAll(RegExp(r'[\s\-()]'), '');

    final isIndianLocalNumber = RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned);

    final isIndianNumberWithZero = RegExp(r'^0[6-9]\d{9}$').hasMatch(cleaned);

    final isInternationalNumber = RegExp(r'^\+\d{10,15}$').hasMatch(cleaned);

    if (!isIndianLocalNumber &&
        !isIndianNumberWithZero &&
        !isInternationalNumber) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // ============================================================
  // SWITCH LOGIN METHOD
  // ============================================================

  void _setLoginMethod(bool phoneLogin) {
    if (_isPhoneLogin == phoneLogin) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _isPhoneLogin = phoneLogin;

      // Clear validation errors from the previous method.
      _formKey.currentState?.reset();
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();

    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isDarkMode = theme.brightness == Brightness.dark;

    final logoPath = isDarkMode
        ? 'assets/logos/storemate_logo_darkmode.png'
        : 'assets/logos/storemate_logo.png';

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.sizeOf(context).height -
                      MediaQuery.paddingOf(context).vertical -
                      48,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // LOGO
                      // ==================================================
                      Center(
                        child: Image.asset(
                          logoPath,
                          width: 150,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ==================================================
                      // HEADING
                      // ==================================================
                      Text(
                        'Login to StoreMate',
                        style: textTheme.headlineMedium,
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Manage your store, inventory, sales, and more.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 26),

                      // ==================================================
                      // EMAIL / PHONE SWITCH
                      // ==================================================
                      _buildAuthMethodSelector(context, colorScheme),

                      const SizedBox(height: 22),

                      // ==================================================
                      // EMAIL OR PHONE FIELD
                      // ==================================================
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _isPhoneLogin
                            ? TextFormField(
                                key: const ValueKey('phone'),
                                controller: _phoneController,
                                enabled: !_isLoading,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.telephoneNumber,
                                ],
                                validator: _validatePhone,
                                decoration: const InputDecoration(
                                  labelText: 'Phone number',
                                  hintText: '+91 98765 43210',
                                  prefixIcon: Icon(Icons.phone_outlined),
                                ),
                              )
                            : TextFormField(
                                key: const ValueKey('email'),
                                controller: _emailController,
                                enabled: !_isLoading,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                validator: (value) {
                                  final email = value?.trim() ?? '';

                                  if (email.isEmpty) {
                                    return 'Please enter your email address';
                                  }

                                  final emailPattern = RegExp(
                                    r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$',
                                  );

                                  if (!emailPattern.hasMatch(email)) {
                                    return 'Please enter a valid email address';
                                  }

                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Email address',
                                  hintText: 'Enter your email address',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                              ),
                      ),

                      const SizedBox(height: 15),

                      // ==================================================
                      // PASSWORD
                      // ==================================================
                      TextFormField(
                        controller: _passwordController,
                        enabled: !_isLoading,
                        obscureText: !_isPasswordVisible,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }

                          if (value.length < 6) {
                            return 'Password must contain at least 6 characters';
                          }

                          return null;
                        },
                        onFieldSubmitted: (_) {
                          if (!_isLoading) {
                            _login();
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            tooltip: _isPasswordVisible
                                ? 'Hide password'
                                : 'Show password',
                            onPressed: _isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // ==================================================
                      // FORGOT PASSWORD
                      // ==================================================
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                          child: const Text('Forgot password?'),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ==================================================
                      // LOGIN BUTTON
                      // ==================================================
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text('Log in'),
                      ),

                      const SizedBox(height: 22),

                      // ==================================================
                      // DIVIDER
                      // ==================================================
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Or continue with',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // ==================================================
                      // GOOGLE
                      // ==================================================
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        icon: Image.asset(
                          'assets/icons/google_logo.png',
                          width: 22,
                          height: 22,
                        ),
                        label: const Text('Continue with Google'),
                      ),

                      const SizedBox(height: 22),

                      // ==================================================
                      // REGISTER
                      // ==================================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterScreen(),
                                      ),
                                    );
                                  },
                            child: const Text('Create account'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMAIL / PHONE SELECTOR
  // ============================================================

  Widget _buildAuthMethodSelector(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMethodOption(
              label: 'Email',
              selected: !_isPhoneLogin,
              onTap: () => _setLoginMethod(false),
            ),
          ),
          Expanded(
            child: _buildMethodOption(
              label: 'Phone',
              selected: _isPhoneLogin,
              onTap: () => _setLoginMethod(true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(9),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
