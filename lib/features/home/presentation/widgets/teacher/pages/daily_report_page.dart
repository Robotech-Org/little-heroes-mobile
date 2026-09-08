import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_heroes_mobile/core/constants/user_role.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/daily_report_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/daily_report_repository.dart';
import 'package:little_heroes_mobile/features/home/presentation/widgets/teacher/pages/daily_report_detail_page.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

import '../daily_report_card.dart';
import 'create_daily_report_page.dart';

class DailyReportPageTeachers extends StatefulWidget {
  const DailyReportPageTeachers({super.key});

  @override
  State<DailyReportPageTeachers> createState() => _DailyReportPageState();
}

class _DailyReportPageState extends State<DailyReportPageTeachers> {
  List<DailyReportModel> _reports = [];
  List<DailyReportModel> _filteredReports = [];
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 0;
  int _totalReports = 0;
  final int _pageSize = 20;

  // Calendar selection
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

  Future<void> _loadReports({int page = 1}) async {
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

      final role = authState.user.role;
      if (role != UserRole.teacher) {
        setState(() {
          _isLoading = false;
          _isError = true;
          _errorMessage = 'You do not have permission to view reports';
        });
        return;
      }

      final repository = di.sl<DailyReportRepository>();
      final response = await repository.getDailyReports(
        page: page,
        pageSize: _pageSize,
      );

      // Extract unique dates from reports
      final dates =
          response.items
              .map((r) => DateTime.tryParse(r.reportDate))
              .where((d) => d != null)
              .map((d) => DateTime(d!.year, d.month, d.day))
              .toSet()
              .toList()
            ..sort();

      setState(() {
        _reports = response.items;
        _filteredReports = response.items;
        _availableDates = dates;
        _totalReports = response.total;
        _totalPages = (response.total / response.pageSize).ceil();
        _currentPage = response.page;
        _isLoading = false;
      });

      // Apply date filter if selected
      _applyDateFilter();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _applyDateFilter() {
    if (_selectedDate == null) {
      setState(() {
        _filteredReports = _reports;
      });
      return;
    }

    setState(() {
      _filteredReports = _reports.where((report) {
        final reportDate = DateTime.tryParse(report.reportDate);
        if (reportDate == null) return false;

        final filterDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
        );
        final reportDateOnly = DateTime(
          reportDate.year,
          reportDate.month,
          reportDate.day,
        );

        return reportDateOnly == filterDate;
      }).toList();
    });
  }

  void _searchReports(String query) {
    final searchQuery = query.trim().toLowerCase();

    setState(() {
      if (searchQuery.isEmpty) {
        _filteredReports = _reports;
        _applyDateFilter(); // Re-apply date filter
        return;
      }

      // Apply both search and date filter
      List<DailyReportModel> filtered = _reports;

      // Apply date filter first
      if (_selectedDate != null) {
        final filterDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
        );
        filtered = filtered.where((report) {
          final reportDate = DateTime.tryParse(report.reportDate);
          if (reportDate == null) return false;
          final reportDateOnly = DateTime(
            reportDate.year,
            reportDate.month,
            reportDate.day,
          );
          return reportDateOnly == filterDate;
        }).toList();
      }

      // Apply search filter
      _filteredReports = filtered.where((report) {
        return report.studentName.toLowerCase().contains(searchQuery);
      }).toList();
    });
  }

  void _navigateToCreateReport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateDailyReportPage()),
    ).then((_) => _loadReports());
  }

  void _navigateToReportDetail(DailyReportModel report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyReportDetailPage(reportName: report.name),
      ),
    );
  }

  // ============================================================
  // DATE FORMATTING
  // ============================================================

  String _formatDateShort(DateTime date) {
    final months = [
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
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Daily Reports',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _navigateToCreateReport,
            tooltip: 'Create New Report',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadReports(),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: _buildSearchBar(theme, colorScheme),
            ),
            // Calendar
            _buildCalendar(theme, colorScheme),
            // Stats

            Expanded(child: _buildContent(theme, colorScheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(ThemeData theme, ColorScheme colorScheme) {
    if (_availableDates.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get the current selected date or first available date
    DateTime currentDisplayDate = _selectedDate ?? _availableDates.first;

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Left Arrow - Previous Day
          GestureDetector(
            onTap: () {
              setState(() {
                final currentIndex = _availableDates.indexOf(
                  currentDisplayDate,
                );
                if (currentIndex > 0) {
                  final newDate = _availableDates[currentIndex - 1];
                  _selectedDate = newDate;
                  _applyDateFilter();
                  if (_searchController.text.isNotEmpty) {
                    _searchReports(_searchController.text);
                  }
                }
              });
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200, width: 1),
              ),
              child: Icon(
                Icons.chevron_left_rounded,
                color: Colors.blue.shade700,
                size: 24,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Date Display
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Show date picker
                _selectDate(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDateFull(currentDisplayDate),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Report count badge
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Right Arrow - Next Day
          GestureDetector(
            onTap: () {
              setState(() {
                final currentIndex = _availableDates.indexOf(
                  currentDisplayDate,
                );
                if (currentIndex < _availableDates.length - 1) {
                  final newDate = _availableDates[currentIndex + 1];
                  _selectedDate = newDate;
                  _applyDateFilter();
                  if (_searchController.text.isNotEmpty) {
                    _searchReports(_searchController.text);
                  }
                }
              });
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200, width: 1),
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: Colors.blue.shade700,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateFull(DateTime date) {
    final months = [
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Helper method to get reports for a specific date
  List<DailyReportModel> _getReportsForDate(DateTime date) {
    return _reports.where((report) {
      final reportDate = DateTime.tryParse(report.reportDate);
      if (reportDate == null) return false;
      return reportDate.year == date.year &&
          reportDate.month == date.month &&
          reportDate.day == date.day;
    }).toList();
  }

  // Helper method to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: _availableDates.first,
      lastDate: _availableDates.last,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context)
              .copyWith(colorScheme: Theme.of(context).colorScheme),
          child: child!,
        );
      },
    );
    if (picked != null) {
      // Find the closest available date
      final closestDate = _availableDates.reduce((a, b) {
        final diffA = (picked.difference(a).inDays).abs();
        final diffB = (picked.difference(b).inDays).abs();
        return diffA < diffB ? a : b;
      });

      setState(() {
        _selectedDate = closestDate;
        _applyDateFilter();
        if (_searchController.text.isNotEmpty) {
          _searchReports(_searchController.text);
        }
      });
    }
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar(ThemeData theme, ColorScheme colorScheme) {
    return TextField(
      controller: _searchController,
      onChanged: _searchReports,
      decoration: InputDecoration(
        hintText: 'Search by student name...',
        prefixIcon: Icon(
          Icons.search_rounded,
          color: colorScheme.onSurfaceVariant,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  _searchController.clear();
                  _searchReports('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        filled: true,
        fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.3),
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
      ),
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStats(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Text(
          '${_filteredReports.length} reports',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        if (_selectedDate != null)
          Row(
            children: [
              Text(
                '📅 ${_formatDateFull(_selectedDate!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = null;
                    _applyDateFilter();
                    if (_searchController.text.isNotEmpty) {
                      _searchReports(_searchController.text);
                    }
                  });
                },
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
      ],
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent(ThemeData theme, ColorScheme colorScheme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isError) {
      return _buildErrorWidget(theme, colorScheme);
    }

    if (_filteredReports.isEmpty) {
      return _buildEmptyWidget(theme, colorScheme);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      physics: const BouncingScrollPhysics(),
      itemCount: _filteredReports.length,
      itemBuilder: (context, index) {
        final report = _filteredReports[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DailyReportCard(
            report: report,
            onTap: () => _navigateToReportDetail(report),
          ),
        );
      },
    );
  }

  // ============================================================
  // ERROR & EMPTY WIDGETS
  // ============================================================

  Widget _buildErrorWidget(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load reports',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadReports(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedDate != null
                  ? 'No reports for this date'
                  : 'No Daily Reports',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedDate != null
                  ? 'No daily reports found for ${_formatDateFull(_selectedDate!)}'
                  : 'Start by creating your first daily report',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_selectedDate != null)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedDate = null;
                    _applyDateFilter();
                    if (_searchController.text.isNotEmpty) {
                      _searchReports(_searchController.text);
                    }
                  });
                },
                icon: const Icon(Icons.clear_rounded),
                label: const Text('Clear Date Filter'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: _navigateToCreateReport,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Report'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
