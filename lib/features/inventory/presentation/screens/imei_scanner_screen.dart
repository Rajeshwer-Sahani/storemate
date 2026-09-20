import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ImeiScannerScreen extends StatefulWidget {
  const ImeiScannerScreen({
    required this.imeiNumber,
    this.excludedImeis = const <String>[],
    super.key,
  });

  final int imeiNumber;

  /// IMEIs that have already been scanned and must not be returned again.
  final List<String> excludedImeis;

  @override
  State<ImeiScannerScreen> createState() => _ImeiScannerScreenState();
}

class _ImeiScannerScreenState extends State<ImeiScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController();

  late final AnimationController _scanLineController;

  bool _isProcessing = false;
  bool _torchEnabled = false;

  Set<String> get _excludedImeis => widget.excludedImeis
      .map((imei) => imei.trim())
      .where((imei) => imei.isNotEmpty)
      .toSet();

  @override
  void initState() {
    super.initState();

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleDetection(BarcodeCapture capture) {
    if (_isProcessing) {
      return;
    }

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;

      if (rawValue == null || rawValue.trim().isEmpty) {
        continue;
      }

      final imei = _extractImei(rawValue);

      if (imei == null) {
        continue;
      }

      // Important:
      // If this IMEI was already scanned, ignore it and continue
      // looking for another barcode.
      if (_excludedImeis.contains(imei)) {
        continue;
      }

      _isProcessing = true;

      _controller.stop();

      Navigator.of(context).pop(imei);
      return;
    }
  }

  String? _extractImei(String value) {
    final matches = RegExp(r'\d{15}').allMatches(value);

    for (final match in matches) {
      final candidate = match.group(0);

      if (candidate == null) {
        continue;
      }

      if (_excludedImeis.contains(candidate)) {
        continue;
      }

      if (_isValidImei(candidate)) {
        return candidate;
      }
    }

    return null;
  }

  bool _isValidImei(String value) {
    if (!RegExp(r'^\d{15}$').hasMatch(value)) {
      return false;
    }

    var sum = 0;

    for (var index = 0; index < value.length; index++) {
      var digit = int.parse(value[index]);

      if (index.isOdd) {
        digit *= 2;

        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
    }

    return sum % 10 == 0;
  }

  Future<void> _toggleTorch() async {
    await _controller.toggleTorch();

    if (!mounted) {
      return;
    }

    setState(() {
      _torchEnabled = !_torchEnabled;
    });
  }

  void _closeScanner() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final imeiLabel = 'IMEI ${widget.imeiNumber}';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview.
          MobileScanner(controller: _controller, onDetect: _handleDetection),

          // Dark camera overlay + scanner frame.
          IgnorePointer(
            child: CustomPaint(
              painter: _ScannerOverlayPainter(
                color: colorScheme.primary,
                scanProgress: _scanLineController,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context, imeiLabel),

                const Spacer(),

                _buildScannerInstruction(context, imeiLabel),

                const SizedBox(height: 24),

                _buildBottomPanel(context, imeiLabel),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, String imeiLabel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _ScannerIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: _closeScanner,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.48),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Scan device',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    imeiLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          _ScannerIconButton(
            icon: _torchEnabled
                ? Icons.flash_on_rounded
                : Icons.flash_off_rounded,
            onPressed: _toggleTorch,
            isActive: _torchEnabled,
          ),
        ],
      ),
    );
  }

  Widget _buildScannerInstruction(BuildContext context, String imeiLabel) {
    final hasExcludedImeis = _excludedImeis.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.center_focus_strong_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scan $imeiLabel',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  hasExcludedImeis
                      ? 'Place the next IMEI barcode inside the frame. '
                            'Previously scanned IMEIs will be ignored.'
                      : 'Place the IMEI barcode inside the frame '
                            'and hold the device steady.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context, String imeiLabel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scanning automatically',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Looking for $imeiLabel barcode',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.qr_code_scanner_rounded,
            color: Colors.white70,
            size: 23,
          ),
        ],
      ),
    );
  }
}

class _ScannerIconButton extends StatelessWidget {
  const _ScannerIconButton({
    required this.icon,
    required this.onPressed,
    this.isActive = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isActive
          ? colorScheme.primary.withValues(alpha: 0.92)
          : Colors.black.withValues(alpha: 0.48),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  const _ScannerOverlayPainter({
    required this.color,
    required this.scanProgress,
  });

  final Color color;
  final Animation<double> scanProgress;

  @override
  void paint(Canvas canvas, Size size) {
    // Overall dark overlay.
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.42)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Offset.zero & size, overlayPaint);

    // Scanner frame.
    final frameWidth = size.width * 0.82;
    const frameHeight = 150.0;

    final left = (size.width - frameWidth) / 2;
    final top = (size.height - frameHeight) / 2;

    final frameRect = Rect.fromLTWH(left, top, frameWidth, frameHeight);

    final frame = RRect.fromRectAndRadius(frameRect, const Radius.circular(24));

    // Clear the scanner area.
    final clearPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;

    canvas.saveLayer(Offset.zero & size, Paint());

    canvas.drawRRect(frame, clearPaint);

    canvas.restore();

    // Subtle inner border.
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(frame, borderPaint);

    // Blue corner accents.
    final cornerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    const cornerLength = 30.0;

    final x = left;
    final y = top;
    final right = left + frameWidth;
    final bottom = top + frameHeight;

    // Top left.
    canvas.drawLine(Offset(x, y + cornerLength), Offset(x, y), cornerPaint);
    canvas.drawLine(Offset(x, y), Offset(x + cornerLength, y), cornerPaint);

    // Top right.
    canvas.drawLine(
      Offset(right - cornerLength, y),
      Offset(right, y),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(right, y),
      Offset(right, y + cornerLength),
      cornerPaint,
    );

    // Bottom left.
    canvas.drawLine(
      Offset(x, bottom - cornerLength),
      Offset(x, bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(x, bottom),
      Offset(x + cornerLength, bottom),
      cornerPaint,
    );

    // Bottom right.
    canvas.drawLine(
      Offset(right - cornerLength, bottom),
      Offset(right, bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(right, bottom),
      Offset(right, bottom - cornerLength),
      cornerPaint,
    );

    // Animated scan line.
    final scanY = top + 18 + (frameHeight - 36) * scanProgress.value;

    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.9),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(left + 20, scanY, frameWidth - 40, 2))
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(left + 20, scanY),
      Offset(right - 20, scanY),
      scanPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.scanProgress.value != scanProgress.value;
  }
}
