import 'package:flutter/material.dart';
import 'package:storemate/app/navigation/main_navigation_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoreSetupScreen extends StatefulWidget {
  const StoreSetupScreen({super.key});

  @override
  State<StoreSetupScreen> createState() => _StoreSetupScreenState();
}

class _StoreSetupScreenState extends State<StoreSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _storeNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _storeAddressController = TextEditingController();
  final _gstNumberController = TextEditingController();

  String? _selectedBusinessType;
  bool _isLoading = false;

  final List<String> _businessTypes = [
    'Electronics',
    'Grocery',
    'Clothing & Fashion',
    'Mobile & Accessories',
    'Furniture',
    'Pharmacy',
    'Hardware',
    'General Store',
    'Other',
  ];

  Future<void> _selectBusinessType() async {
    // Close the keyboard before opening the bottom sheet.
    FocusManager.instance.primaryFocus?.unfocus();

    final selectedType = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final textTheme = theme.textTheme;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select business type', style: textTheme.headlineSmall),

              const SizedBox(height: 8),

              Text(
                'Choose the category that best describes your store.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 20),

              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _businessTypes.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 8);
                  },
                  itemBuilder: (context, index) {
                    final businessType = _businessTypes[index];

                    final isSelected = businessType == _selectedBusinessType;

                    return Material(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.10)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        leading: Icon(
                          Icons.storefront_outlined,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                        title: Text(
                          businessType,
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: colorScheme.primary,
                              )
                            : null,
                        onTap: () {
                          Navigator.of(context).pop(businessType);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selectedType != null) {
      setState(() {
        _selectedBusinessType = selectedType;
      });

      _formKey.currentState?.validate();
    }
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _phoneNumberController.dispose();
    _storeAddressController.dispose();
    _gstNumberController.dispose();

    super.dispose();
  }

  Future<void> _completeSetup() async {
    // Close the keyboard.
    FocusManager.instance.primaryFocus?.unfocus();

    // Stop if form validation fails.
    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      // Get the currently logged-in user.
      final currentUser = supabase.auth.currentUser;

      if (currentUser == null) {
        throw const AuthException(
          'Your session has expired. Please log in again.',
        );
      }

      // Save the store information in Supabase.
      await supabase.from('stores').insert({
        'owner_id': currentUser.id,
        'store_name': _storeNameController.text.trim(),
        'owner_phone': _phoneNumberController.text.trim(),
        'business_type': _selectedBusinessType,
        'store_address': _storeAddressController.text.trim(),
        'gst_number': _gstNumberController.text.trim().isEmpty
            ? null
            : _gstNumberController.text.trim().toUpperCase(),
      });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Store setup completed successfully.')),
      );

      // Navigate to the StoreMate home screen.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        (route) => false,
      );
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } on PostgrestException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) {
        return;
      }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store setup icon
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.storefront_rounded,
                      size: 34,
                      color: colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Screen heading
                  Text('Set up your store', style: textTheme.headlineLarge),

                  const SizedBox(height: 10),

                  // Screen description
                  Text(
                    'Tell us a little about your business '
                    'to personalize your StoreMate experience.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Store name
                  TextFormField(
                    controller: _storeNameController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.organizationName],
                    decoration: const InputDecoration(
                      labelText: 'Store name',
                      hintText: 'Enter your store name',
                      prefixIcon: Icon(Icons.storefront_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your store name';
                      }

                      if (value.trim().length < 2) {
                        return 'Enter a valid store name';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Owner phone number
                  TextFormField(
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    decoration: const InputDecoration(
                      labelText: 'Owner phone number',
                      hintText: 'Enter your phone number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (value) {
                      final phoneNumber = value?.trim() ?? '';

                      if (phoneNumber.isEmpty) {
                        return 'Please enter your phone number';
                      }

                      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phoneNumber)) {
                        return 'Enter a valid 10-digit phone number';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Business/store type
                  FormField<String>(
                    initialValue: _selectedBusinessType,
                    validator: (_) {
                      if (_selectedBusinessType == null) {
                        return 'Please select your business type';
                      }

                      return null;
                    },
                    builder: (field) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: _selectBusinessType,
                            borderRadius: BorderRadius.circular(16),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: _selectedBusinessType == null
                                    ? null
                                    : 'Business/store type',
                                prefixIcon: const Icon(Icons.business_outlined),
                                suffixIcon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                ),
                                errorText: field.errorText,
                              ),
                              child: Text(
                                _selectedBusinessType ?? 'Business/store type',
                                style: _selectedBusinessType == null
                                    ? textTheme.bodyLarge?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      )
                                    : textTheme.bodyLarge,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Store address
                  TextFormField(
                    controller: _storeAddressController,
                    keyboardType: TextInputType.streetAddress,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 2,
                    maxLines: 3,
                    autofillHints: const [AutofillHints.fullStreetAddress],
                    decoration: const InputDecoration(
                      labelText: 'Store address',
                      hintText: 'Enter your complete store address',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your store address';
                      }

                      if (value.trim().length < 5) {
                        return 'Enter a valid store address';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // GST number
                  TextFormField(
                    controller: _gstNumberController,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 15,
                    decoration: const InputDecoration(
                      labelText: 'GST number (Optional)',
                      hintText: 'Enter your GST number',
                      prefixIcon: Icon(Icons.receipt_long_outlined),
                      counterText: '',
                    ),
                    validator: (value) {
                      final gstNumber = value?.trim().toUpperCase() ?? '';

                      // GST number is optional.
                      if (gstNumber.isEmpty) {
                        return null;
                      }

                      if (!RegExp(
                        r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
                      ).hasMatch(gstNumber)) {
                        return 'Enter a valid 15-character GST number';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // Complete setup button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _completeSetup,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Text('Complete Setup'),
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
