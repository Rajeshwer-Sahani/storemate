import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storemate/features/inventory/data/models/product_model.dart';
import 'package:storemate/features/inventory/data/models/product_unit_model.dart';
import 'package:storemate/features/inventory/data/services/product_unit_service.dart';

class EditProductUnitScreen extends StatefulWidget {
  const EditProductUnitScreen({
    required this.product,
    required this.unit,
    super.key,
  });

  final ProductModel product;
  final ProductUnitModel unit;

  @override
  State<EditProductUnitScreen> createState() => _EditProductUnitScreenState();
}

class _EditProductUnitScreenState extends State<EditProductUnitScreen> {
  final ProductUnitService _productUnitService = ProductUnitService();

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _imei1Controller;
  late final TextEditingController _imei2Controller;
  late final TextEditingController _serialNumberController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _imei1Controller = TextEditingController(text: widget.unit.imei1 ?? '');

    _imei2Controller = TextEditingController(text: widget.unit.imei2 ?? '');

    _serialNumberController = TextEditingController(
      text: widget.unit.serialNumber ?? '',
    );
  }

  @override
  void dispose() {
    _imei1Controller.dispose();
    _imei2Controller.dispose();
    _serialNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final identifierError = _validateAtLeastOneIdentifier();

    if (identifierError != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(identifierError),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedUnit = await _productUnitService.updateProductUnit(
        unitId: widget.unit.id,
        imei1: _imei1Controller.text,
        imei2: _imei2Controller.text,
        serialNumber: _serialNumberController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(updatedUnit);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text(
              'Unable to update the device. Check the '
              'IMEI or serial number and try again.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  String? _validateImei1(String? value) {
    final trimmed = value?.trim() ?? '';

    if (trimmed.isEmpty) {
      return null;
    }

    if (!RegExp(r'^\d{15}$').hasMatch(trimmed)) {
      return 'Enter a valid 15-digit IMEI';
    }

    return null;
  }

  String? _validateImei2(String? value) {
    final trimmed = value?.trim() ?? '';

    if (trimmed.isEmpty) {
      return null;
    }

    if (!RegExp(r'^\d{15}$').hasMatch(trimmed)) {
      return 'Enter a valid 15-digit IMEI';
    }

    return null;
  }

  String? _validateAtLeastOneIdentifier() {
    final imei1 = _imei1Controller.text.trim();
    final imei2 = _imei2Controller.text.trim();
    final serialNumber = _serialNumberController.text.trim();

    if (imei1.isEmpty && imei2.isEmpty && serialNumber.isEmpty) {
      return 'Add at least one identifier: IMEI or serial number.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Device'), centerTitle: false),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              _buildProductCard(theme, colorScheme),

              const SizedBox(height: 28),

              Text(
                'Device Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Update the identifiers for this physical unit. At least one is required.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 18),

              _buildField(
                controller: _imei1Controller,
                label: 'IMEI 1',
                hint: 'Enter 15-digit IMEI (optional)',
                icon: Icons.looks_one_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                validator: _validateImei1,
              ),

              const SizedBox(height: 14),

              _buildField(
                controller: _imei2Controller,
                label: 'IMEI 2',
                hint: 'Enter second IMEI (optional)',
                icon: Icons.looks_two_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                validator: _validateImei2,
              ),

              const SizedBox(height: 14),

              _buildField(
                controller: _serialNumberController,
                label: 'Serial Number',
                hint: 'Enter serial number (optional)',
                icon: Icons.numbers_rounded,
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _saveChanges,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(_isSaving ? 'Saving Changes...' : 'Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.phone_android_rounded,
              color: colorScheme.primary,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Individual device',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool required = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }
}
