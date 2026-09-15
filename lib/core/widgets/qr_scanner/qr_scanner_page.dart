

import 'package:flutter/material.dart';
import 'package:little_heroes_mobile/core/widgets/qr_scanner/qr_scanner_page.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'qr_scanner_result.dart';

class QrScannerPage extends StatefulWidget {
  final String title;
  final String instruction;

  const QrScannerPage({
    super.key,
    this.title = 'Scan QR Code',
    this.instruction = 'Place the QR code inside the frame',
  });

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController _controller = MobileScannerController();

  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDetection(BarcodeCapture capture) {
    if (_hasScanned) {
      return;
    }

    if (capture.barcodes.isEmpty) {
      return;
    }

    final barcode = capture.barcodes.first;
    final value = barcode.rawValue;

    if (value == null || value.trim().isEmpty) {
      return;
    }

    _hasScanned = true;

    _controller.stop();

    final result = QrScannerResult(value: value, scannedAt: DateTime.now());

    Navigator.pop(context, result);
  }

  Future<void> _toggleFlash() async {
    await _controller.toggleTorch();
  }

  Future<void> _switchCamera() async {
    await _controller.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        actions: [
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (context, state, child) {
              final torchState = state.torchState;

              return IconButton(
                onPressed: _toggleFlash,
                icon: Icon(
                  torchState == TorchState.on
                      ? Icons.flash_on_rounded
                      : Icons.flash_off_rounded,
                ),
                tooltip: 'Flash',
              );
            },
          ),
          IconButton(
            onPressed: _switchCamera,
            icon: const Icon(Icons.flip_camera_ios_rounded),
            tooltip: 'Switch camera',
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _handleDetection),

          // Dark overlay + scan frame
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.instruction,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.primary, width: 3),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Scanning...',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          // Bottom information
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Scan a valid QR code to continue.',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
