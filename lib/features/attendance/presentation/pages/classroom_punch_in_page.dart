import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/utils/snackbar_utils.dart';
import '../../../../injection_container.dart' as di;
import '../../data/models/arrived_student.dart';
import '../../domain/repositories/classroom_attendance_repository.dart';

class ClassroomPunchInPage extends StatefulWidget {
  const ClassroomPunchInPage({super.key});

  @override
  State<ClassroomPunchInPage> createState() => _ClassroomPunchInPageState();
}

class _ClassroomPunchInPageState extends State<ClassroomPunchInPage> {
  List<ArrivedStudent> _students = [];
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
      final students = await repo.listArrivedStudents();
      if (!mounted) return;
      setState(() {
        _students = students;
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

      final res = await di.sl<ClassroomAttendanceRepository>().punchIn(
        studentIds: _selected.toList(),
        latitude: p.latitude,
        longitude: p.longitude,
        accuracyMeters: p.accuracy,
      );

      if (!mounted) return;
      if (res.failedCount == 0) {
        SnackbarUtils.showSuccess(context, '${res.successCount} punched in.');
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
              'Punch In to Class',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            Text(
              'Arrived students — mark who is in class',
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
                      : const Icon(Icons.login_rounded),
                  label: Text(
                    _selected.isEmpty
                        ? 'Select students to punch in'
                        : 'Punch In (${_selected.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
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
      return _errView(theme, colors, 'Failed to load roster', _load);
    }
    if (_students.isEmpty) {
      return _empty(theme, colors);
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
          return _studentRow(
            theme: theme,
            colors: colors,
            id: s.student,
            name: s.studentName,
            subtitle: 'Arrived ${_time(s.arrivedAt)}',
            selected: sel,
            onToggle: () => setState(() {
              sel ? _selected.remove(s.student) : _selected.add(s.student);
            }),
          );
        },
      ),
    );
  }

  Widget _empty(ThemeData theme, ColorScheme colors) => Center(
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
              Icons.groups_outlined,
              size: 34,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No students waiting',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Students appear here after the gate teacher scans them.',
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

  Widget _errView(
    ThemeData theme,
    ColorScheme colors,
    String title,
    VoidCallback onRetry,
  ) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: colors.error),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? '',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );

  Widget _studentRow({
    required ThemeData theme,
    required ColorScheme colors,
    required String id,
    required String name,
    required String subtitle,
    required bool selected,
    required VoidCallback onToggle,
  }) {
    return Material(
      color: selected ? colors.primary.withValues(alpha: 0.10) : colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? colors.primary
                  : colors.outline.withValues(alpha: 0.15),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: selected,
                  onChanged: (_) => onToggle(),
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
                  _initials(name),
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
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 11.5,
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

  static String _time(String raw) {
    final dt = DateTime.tryParse(raw.replaceFirst(' ', 'T'));
    if (dt == null) return raw;
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
