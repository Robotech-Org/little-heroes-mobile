import 'package:flutter/material.dart';

import '../../../../../core/widgets/qr_scanner/qr_scanner_page.dart';
import '../../../../../core/widgets/qr_scanner/qr_scanner_result.dart';

class TeacherQrScannerCard extends StatelessWidget {
  const TeacherQrScannerCard({super.key});

  Future<void> _scanQrCode(BuildContext context) async {
    final result = await Navigator.push<QrScannerResult>(
      context,
      MaterialPageRoute(
        builder: (_) => const QrScannerPage(
          title: 'Scan Student QR',
          instruction: 'Place the student QR code inside the frame',
        ),
      ),
    );

    if (!context.mounted || result == null) {
      return;
    }

    // TODO:
    // Handle the scanned student QR value here.
    //
    // Example:
    // final qrValue = result.value;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('QR scanned: ${result.value}')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => _scanQrCode(context),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  color: colors.primary,
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan Student QR',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Scan a student QR code to continue',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.65,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: theme.iconTheme.color?.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
