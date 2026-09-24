import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:storemate/app/navigation/main_navigation_screen.dart';
import 'package:storemate/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:storemate/features/auth/presentation/screens/register_screen.dart';
import 'package:storemate/features/store_setup/presentation/screens/store_setup_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  StreamSubscription<AuthState>? _authSubscription;

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
  // EMAIL LOGIN
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
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

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

      // The authenticated session is handled by
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

  @override
  void dispose() {
    _authSubscription?.cancel();

    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
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
}
