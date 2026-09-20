import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ImeiScannerScreen extends StatefulWidget {
  const ImeiScannerScreen({
    required this.imeiNumber,
    super.key,
  });

  final int imeiNumber;

  @override
  State<ImeiScannerScreen> createState() => _ImeiScannerScreenState();
}

class _ImeiScannerScreenState extends State<ImeiScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();

  bool _isProcessing = false;

  @override
  void dispose() {
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

      if (candidate != null && _isValidImei(candidate)) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final imeiLabel = 'IMEI ${widget.imeiNumber}';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Scan $imeiLabel'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Toggle flashlight',
            onPressed: () {
              _controller.toggleTorch();
            },
            icon: const Icon(Icons.flashlight_on_outlined),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleDetection,
          ),

          IgnorePointer(
            child: CustomPaint(
              painter: _ScannerOverlayPainter(
                color: colorScheme.primary,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.62),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Position the IMEI barcode inside the frame.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const Spacer(),

                Container(
                  margin: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.68),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Scanning $imeiLabel automatically...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  const _ScannerOverlayPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.48)
      ..style = PaintingStyle.fill;

    const frameWidth = 300.0;
    const frameHeight = 130.0;

    final left = (size.width - frameWidth) / 2;
    final top = (size.height - frameHeight) / 2;

    final frame = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        left,
        top,
        frameWidth,
        frameHeight,
      ),
      const Radius.circular(22),
    );

    final outerPath = Path()..addRect(Offset.zero & size);
    final framePath = Path()..addRRect(frame);

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        outerPath,
        framePath,
      ),
      paint,
    );

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(frame, borderPaint);

    final cornerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    const cornerLength = 28.0;

    final x = left;
    final y = top;
    final right = left + frameWidth;
    final bottom = top + frameHeight;

    canvas.drawLine(
      Offset(x, y + cornerLength),
      Offset(x, y),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(x, y),
      Offset(x + cornerLength, y),
      cornerPaint,
    );

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
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}