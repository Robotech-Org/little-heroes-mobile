import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:little_heroes_mobile/core/utils/url_helper.dart';
import 'package:little_heroes_mobile/core/widgets/document_viewer/document_viewer_page.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/three_month_report_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/three_month_report_repository.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

class ThreeMonthReportPage extends StatefulWidget {
  final String studentName;
  final String studentId;

  const ThreeMonthReportPage({
    super.key,
    required this.studentName,
    required this.studentId,
  });

  @override
  State<ThreeMonthReportPage> createState() => _ThreeMonthReportPageState();
}

class _ThreeMonthReportPageState extends State<ThreeMonthReportPage> {
  List<ThreeMonthReportModel> _reports = [];
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';

  /// Which report is currently fetching its PDF URL (shows spinner on that card).
  String? _loadingPdfFor;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

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
          _errorMessage = 'Please login to view report';
        });
        return;
      }

      final repository = di.sl<ThreeMonthReportRepository>();

      final response = await repository.getThreeMonthReports(
        page: 1,
        pageSize: 100,
        student: widget.studentId,
      );

      final visible = response.items.where((r) {
        if (widget.studentId.isNotEmpty && r.student == widget.studentId) {
          return true;
        }
        return r.studentName.toLowerCase() == widget.studentName.toLowerCase();
      }).toList();

      visible.sort((a, b) {
        final aDate = _parseDate(a.periodEndDate ?? a.creation);
        final bDate = _parseDate(b.periodEndDate ?? b.creation);
        return bDate.compareTo(aDate);
      });

      if (!mounted) return;
      setState(() {
        _reports = visible;
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

  DateTime _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return DateTime(1970);
    return DateTime.tryParse(raw.replaceFirst(' ', 'T')) ?? DateTime(1970);
  }

  // ═════════════════════════════════════════════════════════════
  // FETCH PDF URL → OPEN IN-APP VIEWER (authenticated)
  // ═════════════════════════════════════════════════════════════
  Future<void> _openReportPdf(ThreeMonthReportModel report) async {
    if (_loadingPdfFor != null) return;

    setState(() => _loadingPdfFor = report.name);

    try {
      final repository = di.sl<ThreeMonthReportRepository>();
      final rawUrl = await repository.getThreeMonthReportPdf(report.name);
      final pdfUrl = UrlHelper.resolve(rawUrl);

      if (!mounted) return;

      // ✅ Navigate to the in-app viewer.
      //    The viewer downloads bytes via DioClient (cookie-aware)
      //    and renders with SfPdfViewer.memory — no 403.
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DocumentViewerPage(url: pdfUrl, title: '3-Month Report'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open report: ${_cleanError(e)}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingPdfFor = null);
    }
  }

  String _cleanError(Object e) {
    return e
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('DioException [bad response]: ', '');
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
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '3 Month Reports',
          style: TextStyle(fontWeight: FontWeight.w700),
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
        child: _buildBody(theme, colors),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, ColorScheme colors) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isError) {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: colors.error),
          const SizedBox(height: 16),
          Text(
            'Failed to load reports',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
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
          Center(
            child: ElevatedButton.icon(
              onPressed: _loadReports,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    if (_reports.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          const SizedBox(height: 60),
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No Reports Yet',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '3-month reports for ${widget.studentName} will appear here\nonce the teacher shares them.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: _reports.length,
      itemBuilder: (_, i) {
        final report = _reports[i];
        final isLoadingThis = _loadingPdfFor == report.name;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ReportListCard(
            report: report,
            isLoading: isLoadingThis,
            onTap: () => _openReportPdf(report),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// REPORT LIST CARD
// ═══════════════════════════════════════════════════════════════
class _ReportListCard extends StatelessWidget {
  final ThreeMonthReportModel report;
  final VoidCallback onTap;
  final bool isLoading;

  const _ReportListCard({
    required this.report,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusColor = _statusColor(report.status, colors);
    final statusText = _statusText(report.status);
    final period = _formatPeriod(report.periodStartDate, report.periodEndDate);

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outline.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.picture_as_pdf_rounded,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Three Month Report',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          period,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _infoPill(colors, Icons.class_outlined, report.classroom),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoPill(ColorScheme colors, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colors.onSurfaceVariant),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  String _formatPeriod(String? start, String? end) {
    if (start == null || end == null || start.isEmpty || end.isEmpty) {
      return '';
    }
    return '${_shortDate(start)} – ${_shortDate(end)}';
  }

  String _shortDate(String raw) {
    final dt = DateTime.tryParse(raw.replaceFirst(' ', 'T'));
    if (dt == null) return raw;
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
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'shared with parent':
        return 'Shared';
      case 'submitted':
        return 'Complete';
      case 'needs revision':
        return 'Needs Revision';
      default:
        return status;
    }
  }

  Color _statusColor(String status, ColorScheme colors) {
    switch (status.toLowerCase()) {
      case 'shared with parent':
        return Colors.green;
      case 'submitted':
        return Colors.blue;
      case 'needs revision':
        return Colors.orange;
      default:
        return colors.primary;
    }
  }
}
