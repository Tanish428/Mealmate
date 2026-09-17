import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerOverlay extends StatefulWidget {
  final Function(String) onDetect;

  const QRScannerOverlay({super.key, required this.onDetect});

  @override
  State<QRScannerOverlay> createState() => _QRScannerOverlayState();
}

class _QRScannerOverlayState extends State<QRScannerOverlay> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isScanned = false; // Prevents multiple rapid scans

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _isScanned = true;
        widget.onDetect(barcode.rawValue!);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          _buildOverlay(context),
          _buildTopControls(context),
        ],
      ),
    );
  }

  Widget _buildTopControls(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 32),
            onPressed: () => Navigator.of(context).pop(),
          ),
          IconButton(
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.white, size: 32);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow, size: 32);
                  default:
                    return const Icon(Icons.flash_off, color: Colors.grey, size: 32);
                }
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Create a square scanning area in the center
        final scanAreaSize = constraints.maxWidth * 0.7;
        final horizontalPadding = (constraints.maxWidth - scanAreaSize) / 2;
        final verticalPadding = (constraints.maxHeight - scanAreaSize) / 2;

        return Stack(
          children: [
            // Darken Top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: verticalPadding,
              child: Container(color: Colors.black54),
            ),
            // Darken Bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: verticalPadding,
              child: Container(color: Colors.black54),
            ),
            // Darken Left
            Positioned(
              top: verticalPadding,
              bottom: verticalPadding,
              left: 0,
              width: horizontalPadding,
              child: Container(color: Colors.black54),
            ),
            // Darken Right
            Positioned(
              top: verticalPadding,
              bottom: verticalPadding,
              right: 0,
              width: horizontalPadding,
              child: Container(color: Colors.black54),
            ),
            // Target Brackets
            Positioned(
              top: verticalPadding,
              left: horizontalPadding,
              child: CustomPaint(
                size: Size(scanAreaSize, scanAreaSize),
                painter: _ScannerFramePainter(
                  color: Theme.of(context).colorScheme.primary, // Using primary rust/red
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScannerFramePainter extends CustomPainter {
  final Color color;

  _ScannerFramePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final double length = size.width * 0.2;

    // Top-left
    canvas.drawLine(const Offset(0, 0), Offset(length, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(0, length), paint);

    // Top-right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - length, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, length), paint);

    // Bottom-left
    canvas.drawLine(Offset(0, size.height), Offset(length, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - length), paint);

    // Bottom-right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - length, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - length), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
