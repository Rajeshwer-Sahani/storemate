import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storemate/features/inventory/data/models/product_model.dart';
import 'package:storemate/features/inventory/data/services/product_unit_service.dart';
import 'package:storemate/features/inventory/presentation/screens/imei_scanner_screen.dart';

class AddProductUnitScreen extends StatefulWidget {
  const AddProductUnitScreen({required this.product, super.key});

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

  bool _isImei1Scanned = false;
  bool _isImei2Scanned = false;
  bool _isSerialNumberScanned = false;

  bool _isUpdatingFromScanner = false;

  @override
  void dispose() {
    _imei1Controller.removeListener(_handleImei1Changed);
    _imei2Controller.removeListener(_handleImei2Changed);
    _serialNumberController.removeListener(_handleSerialNumberChanged);

    _imei1Controller.dispose();
    _imei2Controller.dispose();
    _serialNumberController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _imei1Controller.addListener(_handleImei1Changed);
    _imei2Controller.addListener(_handleImei2Changed);
    _serialNumberController.addListener(_handleSerialNumberChanged);
  }

  void _handleImei1Changed() {
    if (_isUpdatingFromScanner) {
      return;
    }

    if (_isImei1Scanned) {
      setState(() {
        _isImei1Scanned = false;
      });
    }
  }

  void _handleImei2Changed() {
    if (_isUpdatingFromScanner) {
      return;
    }

    if (_isImei2Scanned) {
      setState(() {
        _isImei2Scanned = false;
      });
    }
  }

  void _handleSerialNumberChanged() {
    if (_isUpdatingFromScanner) {
      return;
    }

    if (_isSerialNumberScanned) {
      setState(() {
        _isSerialNumberScanned = false;
      });
    }
  }

  Future<void> _saveDevice() async {
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

    final duplicateImeiError = _validateDuplicateImeis();

    if (duplicateImeiError != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(duplicateImeiError),
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

  Future<void> _scanImei1() async {
    FocusScope.of(context).unfocus();

    final imei = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) =>
            const ImeiScannerScreen(scanType: 'imei', imeiNumber: 1),
      ),
    );

    if (!mounted || imei == null) {
      return;
    }

    _isUpdatingFromScanner = true;

    _imei1Controller.text = imei;

    _isUpdatingFromScanner = false;

    setState(() {
      _isImei1Scanned = true;
    });
  }

  Future<void> _scanImei2() async {
    FocusScope.of(context).unfocus();

    final imei1 = _imei1Controller.text.trim();

    final imei = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => ImeiScannerScreen(
          scanType: 'imei',
          imeiNumber: 2,
          excludedValues: [if (imei1.isNotEmpty) imei1],
        ),
      ),
    );

    if (!mounted || imei == null) {
      return;
    }

    _isUpdatingFromScanner = true;

    _imei2Controller.text = imei;

    _isUpdatingFromScanner = false;

    setState(() {
      _isImei2Scanned = true;
    });
  }

  Future<void> _scanSerialNumber() async {
    FocusScope.of(context).unfocus();

    final existingSerialNumber = _serialNumberController.text.trim();
    final imei1 = _imei1Controller.text.trim();
    final imei2 = _imei2Controller.text.trim();

    final serialNumber = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => ImeiScannerScreen(
          scanType: 'serial',
          excludedValues: [
            if (existingSerialNumber.isNotEmpty) existingSerialNumber,
            if (imei1.isNotEmpty) imei1,
            if (imei2.isNotEmpty) imei2,
          ],
        ),
      ),
    );

    if (!mounted || serialNumber == null) return;

    _isUpdatingFromScanner = true;
    _serialNumberController.text = serialNumber;
    _isUpdatingFromScanner = false;

    setState(() => _isSerialNumberScanned = true);
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

  String? _validateDuplicateImeis() {
    final imei1 = _imei1Controller.text.trim();
    final imei2 = _imei2Controller.text.trim();

    if (imei1.isNotEmpty && imei2.isNotEmpty && imei1 == imei2) {
      return 'IMEI 1 and IMEI 2 cannot be the same.';
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
      appBar: AppBar(title: const Text('Add Device'), centerTitle: false),
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
                onScan: _scanImei1,
                isScanned: _isImei1Scanned,
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
                onScan: _scanImei2,
                isScanned: _isImei2Scanned,
              ),

              const SizedBox(height: 14),

              _buildField(
                controller: _serialNumberController,
                label: 'Serial Number',
                hint: 'Enter serial number (optional)',
                icon: Icons.numbers_rounded,
                keyboardType: TextInputType.text,
                onScan: _scanSerialNumber,
                isScanned: _isSerialNumberScanned,
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
                        'At least one identifier is required. '
                        'For mobile phones, enter IMEI 1. '
                        'For other devices, you can use the serial number.',
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
                  label: Text(_isSaving ? 'Adding Device...' : 'Add Device'),
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
    VoidCallback? onScan,
    bool isScanned = false,
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
        suffixIcon: onScan == null
            ? null
            : IconButton(
                tooltip: isScanned ? 'Scan again' : 'Scan $label',
                onPressed: _isSaving ? null : onScan,
                icon: Icon(
                  isScanned
                      ? Icons.check_circle_rounded
                      : Icons.qr_code_scanner_rounded,
                  color: isScanned ? Colors.green : colorScheme.primary,
                ),
              ),
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
