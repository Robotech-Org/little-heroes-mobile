import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/daily_report_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/daily_report_repository.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/parent/daily_report_page.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/teacher/daily_report_card.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

class ParentDailyReportListPage extends StatefulWidget {
  final String studentId;
  final String studentName;

  const ParentDailyReportListPage({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<ParentDailyReportListPage> createState() =>
      _ParentDailyReportListPageState();
}

class _ParentDailyReportListPageState extends State<ParentDailyReportListPage> {
  List<DailyReportModel> _reports = [];
  List<DailyReportModel> _filteredReports = [];
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';

  // Calendar
  DateTime? _selectedDate;
  List<DateTime> _availableDates = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ═════════════════════════════════════════════════════════════
  // LOAD — fetch all, filter to this student
  // ═════════════════════════════════════════════════════════════
  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() {
          _isLoading = false;
          _isError = true;
          _errorMessage = 'Please login to view reports';
        });
        return;
      }

      final repository = di.sl<DailyReportRepository>();
      final response = await repository.getDailyReports(page: 1, pageSize: 100);

      // Filter to this student (by id, fallback to name)
      final visible = response.items.where((r) {
        if (widget.studentId.isNotEmpty && r.student == widget.studentId) {
          return true;
        }
        return r.studentName.toLowerCase() == widget.studentName.toLowerCase();
      }).toList();

      // Sort by date descending (newest first)
      visible.sort((a, b) {
        final da = DateTime.tryParse(a.reportDate) ?? DateTime(1970);
        final db = DateTime.tryParse(b.reportDate) ?? DateTime(1970);
        return db.compareTo(da);
      });

      // Extract unique dates — sorted newest first
      final dates =
          visible
              .map((r) => DateTime.tryParse(r.reportDate))
              .where((d) => d != null)
              .map((d) => DateTime(d!.year, d.month, d.day))
              .toSet()
              .toList()
            ..sort((a, b) => b.compareTo(a));

      if (!mounted) return;

      setState(() {
        _reports = visible;
        _filteredReports = visible;
        _availableDates = dates;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = e.toString();
      });
    }
  }

  // ═════════════════════════════════════════════════════════════
  // FILTERS
  // ═════════════════════════════════════════════════════════════
  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredReports = _reports.where((r) {
        // Date filter
        if (_selectedDate != null) {
          final reportDate = DateTime.tryParse(r.reportDate);
          if (reportDate == null) return false;
          final match =
              reportDate.year == _selectedDate!.year &&
              reportDate.month == _selectedDate!.month &&
              reportDate.day == _selectedDate!.day;
          if (!match) return false;
        }

        // Text search
        if (query.isNotEmpty) {
          final haystack = '${r.reportDate} ${r.name}'.toLowerCase();
          if (!haystack.contains(query)) return false;
        }

        return true;
      }).toList();
    });
  }

  /// Moves the selected date to the previous (-1) or next (+1)
  /// available date. Does nothing at the ends of the list.
  void _stepDate(int direction, DateTime currentDisplayDate) {
    final currentIndex = _availableDates.indexOf(currentDisplayDate);
    if (currentIndex < 0) return;

    final newIndex = currentIndex + direction;
    if (newIndex < 0 || newIndex >= _availableDates.length) return;

    setState(() {
      _selectedDate = _availableDates[newIndex];
    });
    _applyFilters();
  }

  Future<void> _pickDate() async {
    if (_availableDates.isEmpty) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? _availableDates.first,
      firstDate: _availableDates.last, // oldest
      lastDate: _availableDates.first, // newest
    );
    if (picked == null) return;

    // Snap to the closest available date
    final closestDate = _availableDates.reduce((a, b) {
      final diffA = (picked.difference(a).inDays).abs();
      final diffB = (picked.difference(b).inDays).abs();
      return diffA < diffB ? a : b;
    });

    setState(() {
      _selectedDate = DateTime(
        closestDate.year,
        closestDate.month,
        closestDate.day,
      );
    });
    _applyFilters();
  }

  void _clearDateFilter() {
    setState(() => _selectedDate = null);
    _applyFilters();
  }

  void _openReport(DailyReportModel report) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DailyReportPage(
          studentName: report.studentName,
          studentId: report.student,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // ═════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Reports',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              widget.studentName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadReports,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadReports,
        child: Column(
          children: [
            // ── Search bar ────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _buildSearchBar(theme, colors),
            ),

            // ── Date filter with arrows ───────────────
            if (_availableDates.isNotEmpty) _buildDateFilterChip(theme, colors),

            // ── Content ──────────────────────────────
            Expanded(child: _buildContent(theme, colors)),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // SEARCH BAR
  // ═════════════════════════════════════════════════════════════
  Widget _buildSearchBar(ThemeData theme, ColorScheme colors) {
    return TextField(
      controller: _searchController,
      onChanged: (_) => _applyFilters(),
      decoration: InputDecoration(
        hintText: 'Search reports...',
        prefixIcon: Icon(Icons.search_rounded, color: colors.onSurfaceVariant),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear_rounded, color: colors.onSurfaceVariant),
                onPressed: () {
                  _searchController.clear();
                  _applyFilters();
                },
              )
            : null,
        filled: true,
        fillColor: colors.surfaceVariant.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // DATE FILTER — prev chip center chip next
  // ═════════════════════════════════════════════════════════════
  Widget _buildDateFilterChip(ThemeData theme, ColorScheme colors) {
    if (_availableDates.isEmpty) return const SizedBox.shrink();

    final DateTime currentDisplayDate = _selectedDate ?? _availableDates.first;

    final currentIndex = _availableDates.indexOf(currentDisplayDate);
    final canGoPrev = currentIndex < _availableDates.length - 1;
    final canGoNext = currentIndex > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          // ── Previous date ─────────────────────────────
          GestureDetector(
            onTap: canGoPrev ? () => _stepDate(1, currentDisplayDate) : null,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: canGoPrev
                    ? colors.primaryContainer.withValues(alpha: 0.4)
                    : colors.surfaceVariant.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: canGoPrev
                      ? colors.primary.withValues(alpha: 0.25)
                      : colors.outline.withValues(alpha: 0.15),
                ),
              ),
              child: Icon(
                Icons.chevron_left_rounded,
                color: canGoPrev
                    ? colors.primary
                    : colors.onSurfaceVariant.withValues(alpha: 0.35),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // ── Center chip (tap to open calendar) ────────
          Expanded(
            child: GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _selectedDate != null
                      ? colors.primaryContainer.withValues(alpha: 0.4)
                      : colors.surfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedDate != null
                        ? colors.primary.withValues(alpha: 0.25)
                        : colors.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _formatDate(currentDisplayDate),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_selectedDate != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _clearDateFilter,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 12,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // ── Next date ─────────────────────────────────
          GestureDetector(
            onTap: canGoNext ? () => _stepDate(-1, currentDisplayDate) : null,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: canGoNext
                    ? colors.primaryContainer.withValues(alpha: 0.4)
                    : colors.surfaceVariant.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: canGoNext
                      ? colors.primary.withValues(alpha: 0.25)
                      : colors.outline.withValues(alpha: 0.15),
                ),
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: canGoNext
                    ? colors.primary
                    : colors.onSurfaceVariant.withValues(alpha: 0.35),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // CONTENT
  // ═════════════════════════════════════════════════════════════
  Widget _buildContent(ThemeData theme, ColorScheme colors) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isError) {
      return _buildError(theme, colors);
    }

    if (_filteredReports.isEmpty) {
      return _buildEmpty(theme, colors);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      physics: const BouncingScrollPhysics(),
      itemCount: _filteredReports.length,
      itemBuilder: (_, i) {
        final report = _filteredReports[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DailyReportCard(
            report: report,
            onTap: () => _openReport(report),
          ),
        );
      },
    );
  }

  Widget _buildError(ThemeData theme, ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: colors.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load reports',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadReports,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme, ColorScheme colors) {
    final hasFilter =
        _selectedDate != null || _searchController.text.isNotEmpty;

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
                Icons.description_outlined,
                size: 34,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilter ? 'No reports match' : 'No reports yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'Try a different date or search term.'
                  : 'Daily reports from the teacher will appear here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            if (hasFilter) ...[
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _selectedDate = null);
                  _applyFilters();
                },
                icon: const Icon(Icons.clear_rounded),
                label: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
