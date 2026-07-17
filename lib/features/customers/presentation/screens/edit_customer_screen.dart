import 'package:flutter/material.dart';
import 'package:storemate/core/widgets/app_snackbar.dart';

import '../../data/models/customer_model.dart';
import '../../data/services/customer_service.dart';

class EditCustomerScreen extends StatefulWidget {
  const EditCustomerScreen({super.key, required this.customer});

  final CustomerModel customer;

  @override
  State<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final CustomerService _customerService = CustomerService();

  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _fullNameController = TextEditingController(text: widget.customer.fullName);

    _phoneController = TextEditingController(text: widget.customer.phoneNumber);

    _emailController = TextEditingController(text: widget.customer.email ?? '');

    _addressController = TextEditingController(
      text: widget.customer.address ?? '',
    );

    _notesController = TextEditingController(text: widget.customer.notes ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  //--------------------------------------------
  // Update customer method
  //--------------------------------------------

  Future<void> _updateCustomer() async {
    final form = _formKey.currentState;

    if (form == null || !form.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
    });

    try {
      await _customerService.updateCustomer(
        widget.customer.copyWith(
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
        ),
      );

      if (!mounted) return;

      AppSnackbar.success(context, message: 'Customer updated successfully.');

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      AppSnackbar.error(context, message: e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  //--------------------------------------------
  // Validation methods for form fields
  //--------------------------------------------
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

    if (value.trim().length < 10) {
      return 'Please enter a valid phone number';
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
        appBar: AppBar(title: const Text('Edit Customer')),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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

                  TextFormField(
                    controller: _phoneController,
                    validator: _validatePhone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter phone number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),

                  const SizedBox(height: 20),

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
                      onPressed: _isSaving ? null : _updateCustomer,
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Update Customer'),
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
