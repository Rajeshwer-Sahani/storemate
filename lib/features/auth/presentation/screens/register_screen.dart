import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:storemate/app/navigation/main_navigation_screen.dart';
import 'package:storemate/features/auth/presentation/screens/login_screen.dart';
import 'package:storemate/features/store_setup/presentation/screens/store_setup_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  StreamSubscription<AuthState>? _authSubscription;

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

  @override
  void dispose() {
    _authSubscription?.cancel();

    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // CREATE ACCOUNT
  // ============================================================

  Future<void> _createAccount() async {
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

      final fullName = _fullNameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (!mounted) return;

      if (response.user != null) {
        // If email confirmation is enabled in Supabase,
        // the user must verify their email before logging in.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account created. Please check your email and verify your account.',
            ),
          ),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
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

      // The authenticated session is handled by
      // onAuthStateChange above after Google redirects
      // back to the application.
    } on AuthException catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to continue with Google. Please try again.'),
        ),
      );
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
  // UI
  // ============================================================

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // LOGO
                  // ==================================================
                  Center(
                    child: Image.asset(
                      logoPath,
                      width: 135,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // HEADING
                  // ==================================================
                  Text('Create your account', style: textTheme.headlineMedium),

                  const SizedBox(height: 6),

                  Text(
                    'Start managing your store, inventory, and sales.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // FULL NAME
                  // ==================================================
                  TextFormField(
                    controller: _fullNameController,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    validator: (value) {
                      final fullName = value?.trim() ?? '';

                      if (fullName.isEmpty) {
                        return 'Please enter your full name';
                      }

                      if (fullName.length < 3) {
                        return 'Full name must contain at least 3 characters';
                      }

                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      hintText: 'Enter your full name',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ==================================================
                  // EMAIL
                  // ==================================================
                  TextFormField(
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

                  const SizedBox(height: 15),

                  // ==================================================
                  // PASSWORD
                  // ==================================================
                  TextFormField(
                    controller: _passwordController,
                    enabled: !_isLoading,
                    obscureText: !_isPasswordVisible,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }

                      if (value.length < 6) {
                        return 'Password must contain at least 6 characters';
                      }

                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Create a password',
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

                  const SizedBox(height: 15),

                  // ==================================================
                  // CONFIRM PASSWORD
                  // ==================================================
                  TextFormField(
                    controller: _confirmPasswordController,
                    enabled: !_isLoading,
                    obscureText: !_isConfirmPasswordVisible,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }

                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }

                      return null;
                    },
                    onFieldSubmitted: (_) {
                      if (!_isLoading) {
                        _createAccount();
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Confirm password',
                      hintText: 'Re-enter your password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        tooltip: _isConfirmPasswordVisible
                            ? 'Hide confirm password'
                            : 'Show confirm password',
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // CREATE ACCOUNT
                  // ==================================================
                  ElevatedButton(
                    onPressed: _isLoading ? null : _createAccount,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Text('Create Account'),
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

                  const SizedBox(height: 10),

                  // ==================================================
                  // LOGIN
                  // ==================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
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
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
