import 'package:flutter/material.dart';

import '../../data/services/customer_service.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final CustomerService _customerService = CustomerService();

  final TextEditingController _fullNameController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _notesController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  Future<void> _saveCustomer() async {
    final form = _formKey.currentState;

    if (form == null || !form.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
    });

    try {
      await _customerService.addCustomer(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),

        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),

        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer added successfully.')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter customer name';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter phone number';
    }

    final phone = value.trim();

    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      return 'Please enter a valid 10-digit phone number';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Customer')),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),

                  /// Full Name
                  TextFormField(
                    controller: _fullNameController,
                    validator: _validateFullName,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter customer name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Phone Number
                  TextFormField(
                    controller: _phoneController,
                    validator: _validatePhone,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                      signed: false,
                    ),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter phone number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Email
                  TextFormField(
                    controller: _emailController,
                    validator: _validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email (Optional)',
                      hintText: 'Enter email address',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Address
                  TextFormField(
                    controller: _addressController,
                    keyboardType: TextInputType.streetAddress,
                    textInputAction: TextInputAction.next,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Address (Optional)',
                      hintText: 'Enter address',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Notes
                  TextFormField(
                    controller: _notesController,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.done,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'Additional notes...',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.note_alt_outlined),
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: _isSaving ? null : _saveCustomer,
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Save Customer'),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
