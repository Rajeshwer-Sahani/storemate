import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storemate/features/inventory/data/models/product_model.dart';
import 'package:storemate/features/inventory/data/services/product_unit_service.dart';

class AddProductUnitScreen extends StatefulWidget {
  const AddProductUnitScreen({
    required this.product,
    super.key,
  });

  final ProductModel product;

  @override
  State<AddProductUnitScreen> createState() => _AddProductUnitScreenState();
}

class _AddProductUnitScreenState extends State<AddProductUnitScreen> {
  final ProductUnitService _productUnitService = ProductUnitService();

  final _formKey = GlobalKey<FormState>();

  final _imei1Controller = TextEditingController();
  final _imei2Controller = TextEditingController();
  final _serialNumberController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _imei1Controller.dispose();
    _imei2Controller.dispose();
    _serialNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveDevice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
    });

    try {
      await _productUnitService.addProductUnit(
        storeId: widget.product.storeId,
        productId: widget.product.id,
        imei1: _imei1Controller.text,
        imei2: _imei2Controller.text,
        serialNumber: _serialNumberController.text,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Device added successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
        );

      Navigator.of(context).pop(true);
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
              'Unable to add device. Check the IMEI or serial number '
              'and try again.',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
    }
  }

  String? _validateImei1(String? value) {
    final trimmed = value?.trim() ?? '';

    if (trimmed.isEmpty) {
      return 'IMEI 1 is required';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Device'),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              _buildProductCard(
                theme,
                colorScheme,
              ),

              const SizedBox(height: 28),

              Text(
                'Device Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Enter the identifiers for this individual physical unit.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 18),

              _buildField(
                controller: _imei1Controller,
                label: 'IMEI 1',
                hint: 'Enter 15-digit IMEI',
                icon: Icons.looks_one_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                validator: _validateImei1,
                required: true,
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

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: colorScheme.primary,
                      size: 21,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        'IMEI 1 identifies this individual device. '
                        'IMEI 2 is used for dual-SIM devices and can be '
                        'left empty when not applicable.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _saveDevice,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add_rounded),
                  label: Text(
                    _isSaving ? 'Adding Device...' : 'Add Device',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
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
                  'Adding individual device',
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
          borderSide: BorderSide(
            color: colorScheme.outlineVariant,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}