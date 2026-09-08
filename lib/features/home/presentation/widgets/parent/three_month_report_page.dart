import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

      // Get current month and year
      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;

      // Get the month name (e.g., "January", "February")
      final monthNames = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      final monthName = monthNames[currentMonth - 1];

      // Search for reports by student, month, and year
      final response = await repository.getThreeMonthReports(
        page: 1,
        pageSize: 20,
        student: widget.studentId,
        month: monthName,
        year: currentYear,
      );

      setState(() {
        _reports = response.items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = e.toString();
      });
    }
  }

  String _getMonthRange() {
    final now = DateTime.now();
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final currentMonth = monthNames[now.month - 1];

    // Calculate 3 months back
    final threeMonthsAgo = now.subtract(const Duration(days: 90));
    final startMonth = monthNames[threeMonthsAgo.month - 1];

    return '$startMonth – $currentMonth ${now.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Colors.green;
      case 'saved':
        return Colors.orange;
      case 'draft':
        return Colors.grey;
      case 'pending':
        return Colors.amber;
      case 'reviewed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return 'Complete';
      case 'saved':
        return 'In Progress';
      case 'draft':
        return 'Draft';
      case 'pending':
        return 'Pending';
      case 'reviewed':
        return 'Reviewed';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '3 Month Report',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Student Name
                  Text(
                    widget.studentName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Date Range
                  Text(
                    _getMonthRange(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Loading State
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  // Error State
                  else if (_isError)
                    _buildErrorWidget(theme, colors)
                  // No Report Found
                  else if (_reports.isEmpty)
                    _buildEmptyWidget(theme, colors)
                  // Report Content
                  else ...[
                    // Summary Cards
                    _SummaryCard(
                      title: 'Total Reports',
                      value: '${_reports.length}',
                      icon: Icons.assessment_rounded,
                    ),
                    const SizedBox(height: 12),
                    _SummaryCard(
                      title: 'Current Month',
                      value: _reports.first.month,
                      icon: Icons.calendar_month_rounded,
                    ),
                    const SizedBox(height: 12),
                    _SummaryCard(
                      title: 'Year',
                      value: '${_reports.first.year}',
                      icon: Icons.calendar_today_rounded,
                    ),
                    const SizedBox(height: 12),
                    _SummaryCard(
                      title: 'Classroom',
                      value: _reports.first.classroom,
                      icon: Icons.class_rounded,
                    ),
                    const SizedBox(height: 28),

                    // Reports List
                    Text(
                      'Reports (${_reports.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ..._reports.map((report) {
                      return _ReportCard(
                        report: report,
                        statusColor: _getStatusColor(report.status),
                        statusText: _getStatusText(report.status),
                      );
                    }).toList(),

                    const SizedBox(height: 24),

                    // Download Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Comming soon!')),
                          );
                        },
                        icon: const Icon(Icons.download_outlined),
                        label: const Text(
                          'Download Report',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme, ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
            const SizedBox(height: 12),
            Text(
              'Failed to load report',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _loadReports,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(ThemeData theme, ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(
              Icons.description_outlined,
              size: 48,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No Report Found',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No 3-month report found for ${widget.studentName}.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SUMMARY CARD
// ============================================================

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// REPORT CARD
// ============================================================

class _ReportCard extends StatelessWidget {
  final ThreeMonthReportModel report;
  final Color statusColor;
  final String statusText;

  const _ReportCard({
    required this.report,
    required this.statusColor,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row - Month and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  report.month,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
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
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Report Details
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                'Report Date: ${report.reportDate}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          Row(
            children: [
              Icon(
                Icons.class_rounded,
                size: 14,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                'Classroom: ${report.classroom}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 14,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                'Teacher: ${report.teacher}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Report ID (for reference)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colors.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'ID: ${report.name}',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: colors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ),

          // View Details Button
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: OutlinedButton(
              onPressed: () {
                // Navigate to report detail
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Viewing report for ${report.month} ${report.year}',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(color: colors.primary.withValues(alpha: 0.3)),
              ),
              child: Text(
                'View Details',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
