// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:little_heroes_mobile/core/utils/url_helper.dart';
// import 'package:little_heroes_mobile/core/widgets/document_viewer/document_viewer_page.dart';
// import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
// import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
// import 'package:little_heroes_mobile/features/home/data/models/three_month_report_model.dart';
// import 'package:little_heroes_mobile/features/home/domain/repositories/three_month_report_repository.dart';
// import 'package:little_heroes_mobile/injection_container.dart' as di;

// class ParentThreeMonthReportListPage extends StatefulWidget {
//   final String studentId;
//   final String studentName;

//   const ParentThreeMonthReportListPage({
//     super.key,
//     required this.studentId,
//     required this.studentName,
//   });

//   @override
//   State<ParentThreeMonthReportListPage> createState() =>
//       _ParentThreeMonthReportListPageState();
// }

// class _ParentThreeMonthReportListPageState
//     extends State<ParentThreeMonthReportListPage> {
//   List<ThreeMonthReportModel> _reports = [];
//   List<ThreeMonthReportModel> _filteredReports = [];
//   bool _isLoading = true;
//   bool _isError = false;
//   String _errorMessage = '';

//   /// Which report is currently fetching its PDF (shows spinner on that card).
//   String? _loadingPdfFor;

//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadReports();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   // ═════════════════════════════════════════════════════════════
//   // LOAD
//   // ═════════════════════════════════════════════════════════════
//   Future<void> _loadReports() async {
//     setState(() {
//       _isLoading = true;
//       _isError = false;
//     });

//     try {
//       final authState = context.read<AuthBloc>().state;
//       if (authState is! AuthAuthenticated) {
//         setState(() {
//           _isLoading = false;
//           _isError = true;
//           _errorMessage = 'Please login to view reports';
//         });
//         return;
//       }

//       final repository = di.sl<ThreeMonthReportRepository>();

//       final response = await repository.getThreeMonthReports(
//         page: 1,
//         pageSize: 100,
//       );

//       // Filter to this student (by id, fallback to name)
//       final visible = response.items.where((r) {
//         if (widget.studentId.isNotEmpty &&
//             r.student.isNotEmpty &&
//             r.student == widget.studentId) {
//           return true;
//         }
//         return r.studentName.toLowerCase() == widget.studentName.toLowerCase();
//       }).toList();

//       // Newest first
//       visible.sort((a, b) {
//         final aDate = _parseDate(a.periodEndDate ?? a.creation);
//         final bDate = _parseDate(b.periodEndDate ?? b.creation);
//         return bDate.compareTo(aDate);
//       });

//       if (!mounted) return;

//       setState(() {
//         _reports = visible;
//         _filteredReports = visible;
//         _isLoading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _isLoading = false;
//         _isError = true;
//         _errorMessage = e.toString();
//       });
//     }
//   }

//   DateTime _parseDate(String? raw) {
//     if (raw == null || raw.isEmpty) return DateTime(1970);
//     return DateTime.tryParse(raw.replaceFirst(' ', 'T')) ?? DateTime(1970);
//   }

//   // ═════════════════════════════════════════════════════════════
//   // SEARCH  (null-safe)
//   // ═════════════════════════════════════════════════════════════
//   void _applySearch() {
//     final query = _searchController.text.trim().toLowerCase();
//     setState(() {
//       if (query.isEmpty) {
//         _filteredReports = _reports;
//         return;
//       }
//       _filteredReports = _reports.where((r) {
//         final classroom = r.classroom.toLowerCase();
//         final name = r.name.toLowerCase();
//         final status = r.status.toLowerCase();
//         final start = (r.periodStartDate ?? '').toLowerCase();
//         final end = (r.periodEndDate ?? '').toLowerCase();

//         return classroom.contains(query) ||
//             name.contains(query) ||
//             status.contains(query) ||
//             start.contains(query) ||
//             end.contains(query);
//       }).toList();
//     });
//   }

//   // ═════════════════════════════════════════════════════════════
//   // OPEN PDF DIRECTLY
//   // ═════════════════════════════════════════════════════════════
//   Future<void> _openReportPdf(ThreeMonthReportModel report) async {
//     if (_loadingPdfFor != null) return; // prevent double-tap

//     setState(() => _loadingPdfFor = report.name);

//     try {
//       final repository = di.sl<ThreeMonthReportRepository>();
//       final rawUrl = await repository.getThreeMonthReportPdf(report.name);
//       final pdfUrl = UrlHelper.resolve(rawUrl);

//       if (!mounted) return;

//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) =>
//               DocumentViewerPage(url: pdfUrl, title: '3-Month Report'),
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Could not open report: ${_cleanError(e)}'),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } finally {
//       if (mounted) setState(() => _loadingPdfFor = null);
//     }
//   }

//   String _cleanError(Object e) {
//     return e
//         .toString()
//         .replaceFirst('Exception: ', '')
//         .replaceFirst('DioException [bad response]: ', '');
//   }

//   // ═════════════════════════════════════════════════════════════
//   // BUILD
//   // ═════════════════════════════════════════════════════════════
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colors = theme.colorScheme;

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: colors.surface,
//         foregroundColor: colors.onSurface,
//         surfaceTintColor: Colors.transparent,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               '3-Month Assessment',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
//             ),
//             Text(
//               widget.studentName,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//                 color: colors.onSurfaceVariant,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             tooltip: 'Refresh',
//             onPressed: _loadReports,
//             icon: const Icon(Icons.refresh_rounded),
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: _loadReports,
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
//               child: _buildSearchBar(theme, colors),
//             ),
//             Expanded(child: _buildContent(theme, colors)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchBar(ThemeData theme, ColorScheme colors) {
//     return TextField(
//       controller: _searchController,
//       onChanged: (_) => _applySearch(),
//       decoration: InputDecoration(
//         hintText: 'Search assessments...',
//         prefixIcon: Icon(Icons.search_rounded, color: colors.onSurfaceVariant),
//         suffixIcon: _searchController.text.isNotEmpty
//             ? IconButton(
//                 icon: Icon(Icons.clear_rounded, color: colors.onSurfaceVariant),
//                 onPressed: () {
//                   _searchController.clear();
//                   _applySearch();
//                 },
//               )
//             : null,
//         filled: true,
//         fillColor: colors.surfaceVariant.withValues(alpha: 0.3),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.2)),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.2)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: colors.primary),
//         ),
//         contentPadding: const EdgeInsets.symmetric(vertical: 4),
//       ),
//     );
//   }

//   Widget _buildContent(ThemeData theme, ColorScheme colors) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (_isError) {
//       return _buildError(theme, colors);
//     }
//     if (_filteredReports.isEmpty) {
//       return _buildEmpty(theme, colors);
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
//       physics: const BouncingScrollPhysics(),
//       itemCount: _filteredReports.length,
//       itemBuilder: (_, i) {
//         final report = _filteredReports[i];
//         final isLoadingThis = _loadingPdfFor == report.name;
//         return Padding(
//           padding: const EdgeInsets.only(bottom: 12),
//           child: _ReportCard(
//             report: report,
//             isLoading: isLoadingThis,
//             onTap: () => _openReportPdf(report),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildError(ThemeData theme, ColorScheme colors) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline_rounded, size: 64, color: colors.error),
//             const SizedBox(height: 16),
//             Text(
//               'Failed to load reports',
//               style: theme.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               _errorMessage,
//               textAlign: TextAlign.center,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: colors.onSurfaceVariant,
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: _loadReports,
//               icon: const Icon(Icons.refresh_rounded),
//               label: const Text('Retry'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmpty(ThemeData theme, ColorScheme colors) {
//     final hasSearch = _searchController.text.isNotEmpty;

//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 72,
//               height: 72,
//               decoration: BoxDecoration(
//                 color: colors.surfaceContainerHighest,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.assignment_outlined,
//                 size: 34,
//                 color: colors.onSurfaceVariant,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               hasSearch ? 'No matches' : 'No assessments yet',
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               hasSearch ? 'Try a different search term.' : '3-month assessments from the teacher\nwill appear here once shared.',
//               textAlign: TextAlign.center,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: colors.onSurfaceVariant,
//                 height: 1.5,
//               ),
//             ),
//             if (hasSearch) ...[
//               const SizedBox(height: 20),
//               TextButton.icon(
//                 onPressed: () {
//                   _searchController.clear();
//                   _applySearch();
//                 },
//                 icon: const Icon(Icons.clear_rounded),
//                 label: const Text('Clear search'),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // REPORT CARD
// // ═══════════════════════════════════════════════════════════════
// class _ReportCard extends StatelessWidget {
//   final ThreeMonthReportModel report;
//   final VoidCallback onTap;
//   final bool isLoading;

//   const _ReportCard({
//     required this.report,
//     required this.onTap,
//     this.isLoading = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colors = theme.colorScheme;

//     final statusText = _statusText(report.status);
//     final statusColor = _statusColor(report.status, colors);
//     final period = _formatPeriod(report.periodStartDate, report.periodEndDate);

//     return Material(
//       color: colors.surface,
//       borderRadius: BorderRadius.circular(16),
//       clipBehavior: Clip.antiAlias,
//       child: InkWell(
//         onTap: isLoading ? null : onTap,
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: colors.outline.withValues(alpha: 0.06)),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ── Top row ───────────────────────────────
//               Row(
//                 children: [
//                   Container(
//                     width: 48,
//                     height: 48,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [
//                           colors.primaryContainer,
//                           colors.primaryContainer.withValues(alpha: 0.5),
//                         ],
//                       ),
//                       shape: BoxShape.circle,
//                     ),
//                     alignment: Alignment.center,
//                     child: Icon(
//                       Icons.picture_as_pdf_rounded,
//                       color: colors.onPrimaryContainer,
//                     ),
//                   ),
//                   const SizedBox(width: 14),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Three Month Report',
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.w700,
//                             color: colors.onSurface,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           period,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: theme.textTheme.bodySmall?.copyWith(
//                             color: colors.onSurfaceVariant,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   if (isLoading)
//                     const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     )
//                   else
//                     Icon(
//                       Icons.chevron_right_rounded,
//                       color: colors.onSurfaceVariant.withValues(alpha: 0.5),
//                       size: 24,
//                     ),
//                 ],
//               ),

//               const SizedBox(height: 12),

//               // ── Classroom ─────────────────────────────
//               Row(
//                 children: [
//                   Icon(
//                     Icons.class_outlined,
//                     size: 14,
//                     color: colors.onSurfaceVariant,
//                   ),
//                   const SizedBox(width: 6),
//                   Flexible(
//                     child: Text(
//                       report.classroom,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: colors.onSurfaceVariant,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 10),

//               // ── Status pill ───────────────────────────
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 5,
//                 ),
//                 decoration: BoxDecoration(
//                   color: statusColor.withValues(alpha: 0.1),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 6,
//                       height: 6,
//                       decoration: BoxDecoration(
//                         color: statusColor,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       statusText,
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: statusColor,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String _formatPeriod(String? start, String? end) {
//     if (start == null || end == null || start.isEmpty || end.isEmpty) {
//       return '';
//     }
//     return '${_shortDate(start)} – ${_shortDate(end)}';
//   }

//   String _shortDate(String raw) {
//     final dt = DateTime.tryParse(raw.replaceFirst(' ', 'T'));
//     if (dt == null) return raw;
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
//   }

//   String _statusText(String status) {
//     switch (status.toLowerCase()) {
//       case 'shared with parent':
//         return 'Shared';
//       case 'submitted':
//         return 'Complete';
//       case 'needs revision':
//         return 'Needs Revision';
//       case 'saved':
//         return 'In Progress';
//       case 'draft':
//         return 'Draft';
//       default:
//         return status;
//     }
//   }

//   Color _statusColor(String status, ColorScheme colors) {
//     switch (status.toLowerCase()) {
//       case 'shared with parent':
//         return Colors.green;
//       case 'submitted':
//         return Colors.blue;
//       case 'needs revision':
//         return Colors.orange;
//       case 'saved':
//         return Colors.orange;
//       case 'draft':
//         return Colors.grey;
//       default:
//         return colors.primary;
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:little_heroes_mobile/core/utils/url_helper.dart';
import 'package:little_heroes_mobile/core/widgets/document_viewer/document_viewer_page.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/three_month_report_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/three_month_report_repository.dart';
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

  /// Which report is currently fetching its PDF (shows spinner on that card).
  String? _loadingPdfFor;

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
        if (widget.studentId.isNotEmpty &&
            r.student.isNotEmpty &&
            r.student == widget.studentId) {
          return true;
        }
        return r.studentName.toLowerCase() == widget.studentName.toLowerCase();
      }).toList();

      // Newest first
      visible.sort((a, b) {
        final aDate = _parseDate(a.periodEndDate ?? a.creation);
        final bDate = _parseDate(b.periodEndDate ?? b.creation);
        return bDate.compareTo(aDate);
      });

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

  DateTime _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return DateTime(1970);
    return DateTime.tryParse(raw.replaceFirst(' ', 'T')) ?? DateTime(1970);
  }

  // ═════════════════════════════════════════════════════════════
  // SEARCH  (null-safe)
  // ═════════════════════════════════════════════════════════════
  void _applySearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredReports = _reports;
        return;
      }
      _filteredReports = _reports.where((r) {
        final student = r.studentName.toLowerCase();
        final classroom = r.classroom.toLowerCase();
        final name = r.name.toLowerCase();
        final status = r.status.toLowerCase();
        final start = (r.periodStartDate ?? '').toLowerCase();
        final end = (r.periodEndDate ?? '').toLowerCase();

        return student.contains(query) ||
            classroom.contains(query) ||
            name.contains(query) ||
            status.contains(query) ||
            start.contains(query) ||
            end.contains(query);
      }).toList();
    });
  }

  // ═════════════════════════════════════════════════════════════
  // OPEN PDF DIRECTLY
  // ═════════════════════════════════════════════════════════════
  Future<void> _openReportPdf(ThreeMonthReportModel report) async {
    if (_loadingPdfFor != null) return;

    setState(() => _loadingPdfFor = report.name);

    try {
      final repository = di.sl<ThreeMonthReportRepository>();
      final rawUrl = await repository.getThreeMonthReportPdf(report.name);
      final pdfUrl = UrlHelper.resolve(rawUrl);

      if (!mounted) return;

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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _buildSearchBar(theme, colors),
            ),
            Expanded(child: _buildContent(theme, colors)),
          ],
        ),
      ),
    );
  }

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
        final isLoadingThis = _loadingPdfFor == report.name;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ReportCard(
            report: report,
            isLoading: isLoadingThis,
            onTap: () => _openReportPdf(report),
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
// REPORT CARD  — now shows student name prominently
// ═══════════════════════════════════════════════════════════════
class _ReportCard extends StatelessWidget {
  final ThreeMonthReportModel report;
  final VoidCallback onTap;
  final bool isLoading;

  const _ReportCard({
    required this.report,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final statusText = _statusText(report.status);
    final statusColor = _statusColor(report.status, colors);
    final period = _formatPeriod(report.periodStartDate, report.periodEndDate);

    //    Fall back to a placeholder if the name is missing
    final studentName = report.studentName.trim().isNotEmpty
        ? report.studentName
        : 'Student';

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
              // ── Top row: avatar + name + period + chevron ──────
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
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
                      _initials(studentName),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //    Student name (bold, prominent)
                        Text(
                          studentName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        //    Period below the name
                        Text(
                          period.isEmpty ? 'Three Month Report' : period,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                      size: 24,
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Classroom ─────────────────────────────
              Row(
                children: [
                  Icon(
                    Icons.class_outlined,
                    size: 14,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
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
                  const Spacer(),
                  // ── Status pill ───────────────────────────
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

  // ═════════════════════════════════════════════════════════════
  // Helpers
  // ═════════════════════════════════════════════════════════════
  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
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
      case 'saved':
        return 'In Progress';
      case 'draft':
        return 'Draft';
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
      case 'saved':
        return Colors.orange;
      case 'draft':
        return Colors.grey;
      default:
        return colors.primary;
    }
  }
}
