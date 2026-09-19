import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/three_month_report_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/three_month_report_repository.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/teacher/pages/three_month_report_detail_page.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

class ParentThreeMonthReportListPage extends StatefulWidget {
  final String studentId;
  final String studentName;

  const ParentThreeMonthReportListPage({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<ParentThreeMonthReportListPage> createState() =>
      _ParentThreeMonthReportListPageState();
}

class _ParentThreeMonthReportListPageState
    extends State<ParentThreeMonthReportListPage> {
  List<ThreeMonthReportModel> _reports = [];
  List<ThreeMonthReportModel> _filteredReports = [];
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';

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
  // LOAD
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

      final repository = di.sl<ThreeMonthReportRepository>();
      final response = await repository.getThreeMonthReports(
        page: 1,
        pageSize: 100,
      );

      // Filter to this student (by id, fallback to name)
      final visible = response.items.where((r) {
        if (widget.studentId.isNotEmpty && r.student == widget.studentId) {
          return true;
        }
        return r.studentName.toLowerCase() == widget.studentName.toLowerCase();
      }).toList();

      // Sort by name or creation date descending
      visible.sort((a, b) => b.name.compareTo(a.name));

      if (!mounted) return;

      setState(() {
        _reports = visible;
        _filteredReports = visible;
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
  // SEARCH
  // ═════════════════════════════════════════════════════════════
  void _applySearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredReports = _reports;
        return;
      }
      _filteredReports = _reports.where((r) {
        return r.classroom.toLowerCase().contains(query) ||
            r.name.toLowerCase().contains(query) ||
            r.status.toLowerCase().contains(query);
      }).toList();
    });
  }

  // ═════════════════════════════════════════════════════════════
  // NAVIGATION
  // ═════════════════════════════════════════════════════════════
  void _openReport(ThreeMonthReportModel report) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ThreeMonthReportDetailPage(reportName: report.name),
      ),
    );
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
              '3-Month Assessment',
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
            // ── Search bar ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _buildSearchBar(theme, colors),
            ),

            // ── Content ────────────────────────────────
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
      onChanged: (_) => _applySearch(),
      decoration: InputDecoration(
        hintText: 'Search assessments...',
        prefixIcon: Icon(Icons.search_rounded, color: colors.onSurfaceVariant),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear_rounded, color: colors.onSurfaceVariant),
                onPressed: () {
                  _searchController.clear();
                  _applySearch();
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
          child: _ReportCard(report: report, onTap: () => _openReport(report)),
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════
  // ERROR
  // ═════════════════════════════════════════════════════════════
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

  // ═════════════════════════════════════════════════════════════
  // EMPTY
  // ═════════════════════════════════════════════════════════════
  Widget _buildEmpty(ThemeData theme, ColorScheme colors) {
    final hasSearch = _searchController.text.isNotEmpty;

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
                Icons.assignment_outlined,
                size: 34,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch ? 'No matches' : 'No assessments yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch ? 'Try a different search term.' : '3-month assessments from the teacher\nwill appear here once shared.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            if (hasSearch) ...[
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  _applySearch();
                },
                icon: const Icon(Icons.clear_rounded),
                label: const Text('Clear search'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// REPORT CARD
// ═══════════════════════════════════════════════════════════════
class _ReportCard extends StatelessWidget {
  final ThreeMonthReportModel report;
  final VoidCallback onTap;

  const _ReportCard({required this.report, required this.onTap});

  String get _initial {
    final name = report.studentName.trim();
    if (name.isEmpty) return '?';
    return name.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final statusText = _statusText(report.status);
    final statusColor = _statusColor(report.status, colors);

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outline.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.primaryContainer,
                      colors.primaryContainer.withValues(alpha: 0.5),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _initial,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.class_outlined,
                          size: 14,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            report.classroom,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return 'Complete';
      case 'saved':
        return 'In Progress';
      case 'draft':
        return 'Not Started';
      case 'pending':
        return 'Pending';
      default:
        return status;
    }
  }

  Color _statusColor(String status, ColorScheme colors) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Colors.green;
      case 'saved':
        return Colors.orange;
      case 'draft':
        return Colors.grey;
      case 'pending':
        return Colors.amber;
      default:
        return colors.primary;
    }
  }
}
