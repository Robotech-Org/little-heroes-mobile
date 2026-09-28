import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/qr_scanner/qr_scanner_page.dart';
import '../../../../core/widgets/qr_scanner/qr_scanner_result.dart';
import '../../../../injection_container.dart' as di;
import '../../data/models/pending_scan.dart';
import '../../data/models/punch_response.dart';
import '../../data/services/gate_queue_service.dart';
import '../../data/utils/qr_decoder.dart';
import '../../domain/repositories/gate_attendance_repository.dart';

enum GateMode { morning, evening }

class GateAttendancePage extends StatefulWidget {
  const GateAttendancePage({super.key});

  @override
  State<GateAttendancePage> createState() => _GateAttendancePageState();
}

class _GateAttendancePageState extends State<GateAttendancePage> {
  GateMode _mode = GateMode.morning;
  List<PendingScan> _queue = [];
  bool _busy = false;
  String? _lastAddedId;

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    final svc = di.sl<GateQueueService>();
    final list = _mode == GateMode.morning
        ? await svc.getMorning()
        : await svc.getEvening();
    if (!mounted) return;
    setState(() => _queue = list);
  }

  Future<void> _switchMode(GateMode next) async {
    setState(() => _mode = next);
    await _loadQueue();
  }

  // ═════════════════════════════════════════════════════════════
  // SCAN LOOP — keeps reopening scanner until user taps Done
  // ═════════════════════════════════════════════════════════════
  Future<void> _startScanning() async {
    while (mounted) {
      // 1) Open scanner
      final result = await Navigator.push<QrScannerResult>(
        context,
        MaterialPageRoute(
          builder: (_) => QrScannerPage(
            title: _mode == GateMode.morning
                ? 'Morning — Scan Student'
                : 'Evening — Scan Student',
            instruction: 'Place the student QR card inside the frame',
          ),
        ),
      );

      // User backed out with system back → exit loop
      if (!mounted || result == null) return;

      // 2) Decode & validate
      final card = QrDecoder.tryDecode(result.value);
      if (card == null || card.card.isEmpty) {
        final keepGoing = await _showScanResultDialog(
          title: 'Invalid card',
          message: 'This QR code is not a student ID card.\nTry again.',
          icon: Icons.error_outline_rounded,
          color: const Color(0xFFDC2626),
          showDone: false,
        );
        if (!keepGoing) return;
        continue;
      }

      // 3) Duplicate check
      final existingIndex = _queue.indexWhere((s) => s.studentId == card.card);
      if (existingIndex >= 0) {
        final existing = _queue[existingIndex];
        final keepGoing = await _showScanResultDialog(
          title: 'Already scanned',
          message:
              '${card.card}\n\nWas already scanned at ${_fmt(existing.scannedAt)}.',
          icon: Icons.info_outline_rounded,
          color: const Color(0xFFF59E0B),
          showDone: false,
        );
        if (!keepGoing) return;
        continue;
      }

      // 4) Add to queue
      final scan = PendingScan(
        studentId: card.card,
        qrPayload: result.value,
        scannedAt: DateTime.now(),
      );

      final svc = di.sl<GateQueueService>();
      if (_mode == GateMode.morning) {
        await svc.addMorning(scan);
      } else {
        await svc.addEvening(scan);
      }

      await _loadQueue();
      if (!mounted) return;
      setState(() => _lastAddedId = card.card);

      // 5) Show result dialog
      final keepGoing = await _showScanResultDialog(
        title: 'Scanned ✓',
        message: '${card.card}\n\nTotal scanned: ${_queue.length}',
        icon: Icons.check_rounded,
        color: const Color(0xFF16A34A),
        showDone: true,
      );

      // Done → exit loop; Scan Next → reopen scanner
      if (!keepGoing) return;
    }
  }

  // ═════════════════════════════════════════════════════════════
  // RESULT DIALOG — returns true to keep scanning, false to stop
  // ═════════════════════════════════════════════════════════════
  Future<bool> _showScanResultDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    required bool showDone,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final theme = Theme.of(ctx);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon circle
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 40),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 10),

              // Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          actions: [
            // Primary button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  showDone ? 'Scan Next' : 'Try Again',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            // Secondary "Done" button (only on success)
            if (showDone) ...[
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );

    return result ?? true;
  }

  // ═════════════════════════════════════════════════════════════
  // GPS
  // ═════════════════════════════════════════════════════════════
  Future<Position?> _getPosition() async {
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    if (p == LocationPermission.denied ||
        p == LocationPermission.deniedForever) {
      SnackbarUtils.showError(context, 'Location permission denied');
      return null;
    }
    if (!await Geolocator.isLocationServiceEnabled()) {
      SnackbarUtils.showError(context, 'Please enable location services');
      return null;
    }
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // SAVE & CLEAR
  // ═════════════════════════════════════════════════════════════
  Future<void> _saveAndClear() async {
    if (_queue.isEmpty || _busy) return;

    setState(() => _busy = true);
    try {
      final pos = await _getPosition();
      if (pos == null) return;

      final scans = _queue.map((s) => {'qr_payload': s.qrPayload}).toList();
      final repo = di.sl<GateAttendanceRepository>();

      final PunchResponse res = _mode == GateMode.morning
          ? await repo.punchIn(
              scans: scans,
              latitude: pos.latitude,
              longitude: pos.longitude,
              accuracyMeters: pos.accuracy,
            )
          : await repo.punchOut(
              scans: scans,
              latitude: pos.latitude,
              longitude: pos.longitude,
              accuracyMeters: pos.accuracy,
            );

      if (!mounted) return;

      // Clear local queue
      final svc = di.sl<GateQueueService>();
      if (_mode == GateMode.morning) {
        await svc.clearMorning();
      } else {
        await svc.clearEvening();
      }

      await _loadQueue();
      if (!mounted) return;

      await _showSaveResultSheet(response: res);
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.showError(
        context,
        'Save failed: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ═════════════════════════════════════════════════════════════
  // SAVE RESULT SHEET — successful + failed lists
  // ═════════════════════════════════════════════════════════════
  Future<void> _showSaveResultSheet({required PunchResponse response}) async {
    final allOk = response.failedCount == 0 && response.successCount > 0;

    // Quick success — just a snackbar
    if (allOk) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'All saved — ${response.successCount} student(s).',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      return;
    }

    // Partial/failed — full sheet
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colors = theme.colorScheme;

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        response.failedCount > 0 && response.successCount > 0
                            ? 'Partial Save'
                            : response.successCount == 0
                            ? 'Save Failed'
                            : 'Save Complete',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${response.successCount} saved • ${response.failedCount} failed',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    children: [
                      if (response.successfulScans.isNotEmpty) ...[
                        _sectionHeader(
                          theme,
                          icon: Icons.check_circle_rounded,
                          color: const Color(0xFF16A34A),
                          label: 'Successful (${response.successCount})',
                        ),
                        const SizedBox(height: 8),
                        ...response.successfulScans.map(
                          (s) => _resultTile(
                            theme,
                            colors,
                            icon: Icons.check_rounded,
                            color: const Color(0xFF16A34A),
                            title: s.studentName.isNotEmpty
                                ? s.studentName
                                : s.studentId,
                            subtitle: '${s.punchType} • ${s.name}',
                          ),
                        ),
                      ],
                      if (response.failedScans.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _sectionHeader(
                          theme,
                          icon: Icons.cancel_rounded,
                          color: const Color(0xFFDC2626),
                          label: 'Failed (${response.failedCount})',
                        ),
                        const SizedBox(height: 8),
                        ...response.failedScans.map(
                          (s) => _resultTile(
                            theme,
                            colors,
                            icon: Icons.close_rounded,
                            color: const Color(0xFFDC2626),
                            title: s.studentId.isNotEmpty
                                ? s.studentId
                                : 'Unknown card',
                            subtitle: _friendlyFailure(s.reason),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFF92400E),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Ask the parent to visit the office to fix '
                                  'these cards. Successful students are already '
                                  'saved.',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF92400E),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _sectionHeader(
    ThemeData theme, {
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _resultTile(
    ThemeData theme,
    ColorScheme colors, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outline.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _friendlyFailure(String? raw) {
    if (raw == null || raw.isEmpty) return 'Server rejected this scan';

    final r = raw.toLowerCase();
    if (r.contains('missing qr_payload')) return 'Nothing was scanned.';
    if (r.contains('invalid qr')) return 'This is not a student card.';
    if (r.contains('signature verification')) {
      return 'Card is invalid or tampered.';
    }
    if (r.contains('voided')) return 'This card is no longer active.';
    if (r.contains('not found')) return 'Card not recognised.';
    return raw;
  }

  // ═════════════════════════════════════════════════════════════
  // CLEAR QUEUE
  // ═════════════════════════════════════════════════════════════
  Future<void> _clearQueue() async {
    if (_queue.isEmpty || _busy) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Clear queue?'),
        content: Text(
          '${_queue.length} scanned student(s) will be removed '
          'without saving.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final svc = di.sl<GateQueueService>();
    if (_mode == GateMode.morning) {
      await svc.clearMorning();
    } else {
      await svc.clearEvening();
    }
    await _loadQueue();
    if (!mounted) return;
    SnackbarUtils.showSuccess(context, 'Queue cleared.');
  }

  // ═════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isMorning = _mode == GateMode.morning;
    final accent = isMorning ? colors.primary : colors.secondary;
    final onAccent = isMorning ? colors.onPrimary : colors.onSecondary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Gate Attendance',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (_queue.isNotEmpty)
            IconButton(
              tooltip: 'Clear queue',
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: _busy ? null : _clearQueue,
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Mode tabs ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: _modeTabs(theme, colors),
          ),

          // ── Scan button ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _busy ? null : _startScanning,
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 22),
                label: Text(
                  isMorning ? 'Scan Arriving Student' : 'Scan Leaving Student',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: onAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),

          // ── Queue counter ────────────────────────────
          if (_queue.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.people_alt_rounded, size: 16, color: accent),
                    const SizedBox(width: 8),
                    Text(
                      '${_queue.length} student(s) scanned',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Queue list ───────────────────────────────
          Expanded(child: _buildQueue(theme, colors)),
        ],
      ),
      bottomNavigationBar: _queue.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton.icon(
                  onPressed: _busy ? null : _saveAndClear,
                  icon: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.cloud_upload_rounded),
                  label: Text(
                    'Save & Clear (${_queue.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _modeTabs(ThemeData theme, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tab(
            label: 'Morning (In)',
            icon: Icons.wb_sunny_rounded,
            selected: _mode == GateMode.morning,
            onTap: _busy ? null : () => _switchMode(GateMode.morning),
          ),
          _tab(
            label: 'Evening (Out)',
            icon: Icons.nights_stay_rounded,
            selected: _mode == GateMode.evening,
            onTap: _busy ? null : () => _switchMode(GateMode.evening),
          ),
        ],
      ),
    );
  }

  Widget _tab({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? colors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQueue(ThemeData theme, ColorScheme colors) {
    if (_queue.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 34,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No scans yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _mode == GateMode.morning
                    ? 'Tap "Scan Arriving Student" to begin.\n'
                          'Save when you are done.'
                    : 'Tap "Scan Leaving Student" to begin.\n'
                          'Save when you are done.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: _queue.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final scan = _queue[i];
        final isNewest = scan.studentId == _lastAddedId;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isNewest
                ? colors.primary.withValues(alpha: 0.08)
                : colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isNewest
                  ? colors.primary
                  : colors.outline.withValues(alpha: 0.15),
              width: isNewest ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 18,
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            scan.studentId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (isNewest) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'NEW',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: colors.onPrimary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Scanned at ${_fmt(scan.scannedAt)}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _fmt(DateTime dt) {
    final l = dt.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:'
        '${l.minute.toString().padLeft(2, '0')}';
  }
}
