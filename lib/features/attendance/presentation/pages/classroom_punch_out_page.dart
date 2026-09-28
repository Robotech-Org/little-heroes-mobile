import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/utils/snackbar_utils.dart';
import '../../../../injection_container.dart' as di;
import '../../data/models/student_status.dart';
import '../../domain/repositories/classroom_attendance_repository.dart';

class ClassroomPunchOutPage extends StatefulWidget {
  const ClassroomPunchOutPage({super.key});

  @override
  State<ClassroomPunchOutPage> createState() => _ClassroomPunchOutPageState();
}

class _ClassroomPunchOutPageState extends State<ClassroomPunchOutPage> {
  List<StudentStatus> _students = [];
  final Set<String> _selected = {};
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _selected.clear();
    });
    try {
      final repo = di.sl<ClassroomAttendanceRepository>();
      final all = await repo.todayStatus();
      final inClass = all.where((s) => s.isIn).toList();
      if (!mounted) return;
      setState(() {
        _students = inClass;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<Position?> _pos() async {
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

  Future<void> _submit() async {
    if (_selected.isEmpty || _busy) return;
    setState(() => _busy = true);
    try {
      final p = await _pos();
      if (p == null) return;

      final res = await di.sl<ClassroomAttendanceRepository>().punchOut(
        studentIds: _selected.toList(),
        latitude: p.latitude,
        longitude: p.longitude,
        accuracyMeters: p.accuracy,
      );

      if (!mounted) return;
      if (res.failedCount == 0) {
        SnackbarUtils.showSuccess(context, '${res.successCount} punched out.');
      } else {
        SnackbarUtils.showError(
          context,
          '${res.successCount} ok • ${res.failedCount} failed',
        );
      }
      await _load();
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toggleAll() {
    setState(() {
      if (_selected.length == _students.length) {
        _selected.clear();
      } else {
        _selected
          ..clear()
          ..addAll(_students.map((s) => s.student));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final allSel = _students.isNotEmpty && _selected.length == _students.length;

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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Punch Out of Class',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            Text(
              'In-class students — mark who left',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          if (_students.isNotEmpty)
            TextButton.icon(
              onPressed: _busy ? null : _toggleAll,
              icon: Icon(
                allSel ? Icons.deselect_rounded : Icons.select_all_rounded,
                size: 18,
              ),
              label: Text(allSel ? 'Clear' : 'All'),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _busy ? null : _load,
          ),
        ],
      ),
      body: _buildBody(theme, colors),
      bottomNavigationBar: (_students.isEmpty || _loading)
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton.icon(
                  onPressed: _busy || _selected.isEmpty ? null : _submit,
                  icon: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.logout_rounded),
                  label: Text(
                    _selected.isEmpty
                        ? 'Select students to punch out'
                        : 'Punch Out (${_selected.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA580C),
                    foregroundColor: Colors.white,
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

  Widget _buildBody(ThemeData theme, ColorScheme colors) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: colors.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load status',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_students.isEmpty) {
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
                  Icons.check_circle_outline_rounded,
                  size: 34,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No students in class',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Punch in the arrived students first.',
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

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _students.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final s = _students[i];
          final sel = _selected.contains(s.student);
          return Material(
            color: sel
                ? colors.primary.withValues(alpha: 0.10)
                : colors.surface,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () => setState(() {
                sel ? _selected.remove(s.student) : _selected.add(s.student);
              }),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: sel
                        ? colors.primary
                        : colors.outline.withValues(alpha: 0.15),
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: sel,
                        onChanged: (_) => setState(() {
                          sel
                              ? _selected.remove(s.student)
                              : _selected.add(s.student);
                        }),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: colors.primaryContainer,
                      child: Text(
                        _initials(s.studentName),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.studentName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'IN CLASS',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.green,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static String _initials(String n) {
    final p = n
        .trim()
        .split(RegExp(r'\s+'))
        .where((x) => x.isNotEmpty)
        .toList();
    if (p.isEmpty) return '?';
    if (p.length == 1) return p[0][0].toUpperCase();
    return '${p[0][0]}${p[1][0]}'.toUpperCase();
  }
}
