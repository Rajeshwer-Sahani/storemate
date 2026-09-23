import 'package:flutter/material.dart';
import 'package:storemate/app/navigation/main_navigation_screen.dart';
import 'package:storemate/features/auth/presentation/screens/login_screen.dart';
import 'package:storemate/features/store_setup/presentation/screens/store_setup_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isLoading = false;
  bool _isPhoneRegistration = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // CREATE ACCOUNT
  // ============================================================

  Future<void> _createAccount() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      final fullName = _fullNameController.text.trim();
      final password = _passwordController.text;

      final AuthResponse response;

      if (_isPhoneRegistration) {
        final phone = _normalizePhoneNumber(_phoneController.text);

        response = await supabase.auth.signUp(
          phone: phone,
          password: password,
          channel: OtpChannel.sms,
          data: {'full_name': fullName},
        );

        if (!mounted) return;

        // If phone confirmation is enabled, Supabase
        // returns a user without an active session.
        if (response.user != null && response.session == null) {
          await _showPhoneVerificationDialog(phone);

          return;
        }

        if (response.session != null) {
          await _handleAuthenticatedUser(response.user!);

          return;
        }
      } else {
        response = await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: password,
          data: {'full_name': fullName},
        );

        if (!mounted) return;

        if (response.user != null) {
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
  // PHONE OTP VERIFICATION
  // ============================================================

  Future<void> _showPhoneVerificationDialog(String phone) async {
    final otpController = TextEditingController();

    try {
      final verified = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          bool isVerifying = false;

          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Verify your phone'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'We sent a verification code to\n$phone',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: otpController,
                      enabled: !isVerifying,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 6,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Verification code',
                        hintText: '000000',
                        counterText: '',
                        prefixIcon: Icon(Icons.verified_user_outlined),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: isVerifying
                        ? null
                        : () {
                            Navigator.of(dialogContext).pop(false);
                          },
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: isVerifying
                        ? null
                        : () async {
                            final otp = otpController.text.trim();

                            if (otp.length != 6) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter the 6-digit verification code.',
                                  ),
                                ),
                              );
                              return;
                            }

                            setDialogState(() {
                              isVerifying = true;
                            });

                            try {
                              final response = await Supabase
                                  .instance
                                  .client
                                  .auth
                                  .verifyOTP(
                                    type: OtpType.sms,
                                    token: otp,
                                    phone: phone,
                                  );

                              if (!mounted) return;

                              if (response.user == null) {
                                throw const AuthException(
                                  'Phone verification failed.',
                                );
                              }

                              Navigator.of(dialogContext).pop(true);

                              await _handleAuthenticatedUser(response.user!);
                            } on AuthException catch (error) {
                              setDialogState(() {
                                isVerifying = false;
                              });

                              if (!dialogContext.mounted) {
                                return;
                              }

                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(content: Text(error.message)),
                              );
                            } catch (error) {
                              setDialogState(() {
                                isVerifying = false;
                              });

                              if (!dialogContext.mounted) {
                                return;
                              }

                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Unable to verify the code. Please try again.',
                                  ),
                                ),
                              );
                            }
                          },
                    child: isVerifying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Verify'),
                  ),
                ],
              );
            },
          );
        },
      );

      // If the user cancelled verification, keep them
      // on the registration screen.
      if (verified != true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Phone verification is required to complete registration.',
            ),
          ),
        );
      }
    } finally {
      otpController.dispose();
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
        redirectTo: 'io.supabase.flutter://signin-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      // Supabase will restore the session after Google
      // redirects back to the application.
      //
      // Navigation after authentication is handled by
      // the auth state listener below.
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
  // PHONE NORMALIZATION
  // ============================================================

  String _normalizePhoneNumber(String value) {
    final cleaned = value.replaceAll(RegExp(r'[\s\-()]'), '');

    // 10-digit Indian number.
    if (cleaned.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
      return '+91$cleaned';
    }

    // Indian number entered with leading 0.
    if (cleaned.startsWith('0') &&
        cleaned.length == 11 &&
        RegExp(r'^0[6-9]\d{9}$').hasMatch(cleaned)) {
      return '+91${cleaned.substring(1)}';
    }

    return cleaned;
  }

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
  // SWITCH REGISTRATION METHOD
  // ============================================================

  void _setRegistrationMethod(bool phoneRegistration) {
    if (_isPhoneRegistration == phoneRegistration) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _isPhoneRegistration = phoneRegistration;
      _formKey.currentState?.reset();
    });
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
                  // EMAIL / PHONE SWITCH
                  // ==================================================
                  _buildAuthMethodSelector(context, colorScheme),

                  const SizedBox(height: 22),

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
                  // EMAIL / PHONE
                  // ==================================================
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isPhoneRegistration
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
              selected: !_isPhoneRegistration,
              onTap: () => _setRegistrationMethod(false),
            ),
          ),
          Expanded(
            child: _buildMethodOption(
              label: 'Phone',
              selected: _isPhoneRegistration,
              onTap: () => _setRegistrationMethod(true),
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
