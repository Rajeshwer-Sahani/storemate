import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();

    super.dispose();
  }

  void _sendResetLink() {
    // Close the keyboard
    FocusScope.of(context).unfocus();

    // Validate the email field
    final isFormValid =
        _formKey.currentState?.validate() ?? false;

    if (!isFormValid) {
      return;
    }

    final email = _emailController.text.trim();

    debugPrint(
      'Password reset requested for: $email',
    );

    // Firebase password-reset functionality
    // will be added later.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // Reset-password icon
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          colorScheme.primary.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      size: 34,
                      color: colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Screen heading
                  Text(
                    'Forgot password?',
                    style: textTheme.headlineLarge,
                  ),

                  const SizedBox(height: 10),

                  // Description
                  Text(
                    'Enter the email address associated '
                    'with your account. We’ll send you a '
                    'link to reset your password.',
                    style: textTheme.bodyLarge?.copyWith(
                      color:
                          colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType:
                        TextInputType.emailAddress,
                    textInputAction:
                        TextInputAction.done,
                    autofillHints: const [
                      AutofillHints.email,
                    ],
                    validator: (value) {
                      final email =
                          value?.trim() ?? '';

                      if (email.isEmpty) {
                        return 'Please enter your email address';
                      }

                      final emailPattern = RegExp(
                        r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$',
                      );

                      if (!emailPattern
                          .hasMatch(email)) {
                        return 'Please enter a valid email address';
                      }

                      return null;
                    },
                    onFieldSubmitted: (_) {
                      _sendResetLink();
                    },
                    decoration:
                        const InputDecoration(
                      labelText: 'Email address',
                      hintText:
                          'Enter your email address',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Send-reset-link button
                  ElevatedButton(
                    onPressed: _sendResetLink,
                    child: const Text(
                      'Send Reset Link',
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Return-to-login button
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                      ),
                      label: const Text(
                        'Back to Login',
                      ),
                    ),
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