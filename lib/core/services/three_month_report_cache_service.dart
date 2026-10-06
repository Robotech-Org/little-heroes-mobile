import 'dart:convert';

import 'package:little_heroes_mobile/core/services/storage_service.dart';
import 'package:little_heroes_mobile/features/home/data/models/three_month_report_model.dart';

/// Offline cache for 3-month report metadata (the JSON list).
/// PDFs are cached separately by DocumentCacheService.
class ThreeMonthReportCacheService {
  ThreeMonthReportCacheService._();
  static final ThreeMonthReportCacheService instance =
      ThreeMonthReportCacheService._();

  static const String _keyParent = 'cache_3mr_parent';
  static const String _keyTimestamp = 'cache_3mr_timestamp';

  final _storage = StorageService.instance;

  // ══════════════════════════════════════════════════
  // SAVE
  // ══════════════════════════════════════════════════

  Future<void> save(List<ThreeMonthReportModel> reports) async {
    try {
      final raw = reports.map(_toJson).toList();
      await _storage.saveString(_keyParent, jsonEncode(raw));
      await _storage.saveString(
        _keyTimestamp,
        DateTime.now().toIso8601String(),
      );
    } catch (_) {
      // Best-effort
    }
  }

  // ══════════════════════════════════════════════════
  // LOAD
  // ══════════════════════════════════════════════════

  List<ThreeMonthReportModel>? load() {
    try {
      final raw = _storage.getString(_keyParent);
      if (raw == null || raw.isEmpty) return null;

      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;

      return decoded
          .whereType<Map>()
          .map((m) => _fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  DateTime? lastUpdated() {
    final raw = _storage.getString(_keyTimestamp);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> clear() async {
    await _storage.saveString(_keyParent, '');
    await _storage.saveString(_keyTimestamp, '');
  }

  // ══════════════════════════════════════════════════
  // SERIALIZATION — adjust field names to match your model
  // ══════════════════════════════════════════════════

  Map<String, dynamic> _toJson(ThreeMonthReportModel r) => {
    'name': r.name,
    'student': r.student,
    'student_name': r.studentName,
    'classroom': r.classroom,
    'status': r.status,
    'period_start_date': r.periodStartDate,
    'period_end_date': r.periodEndDate,
    'creation': r.creation,
    // add other fields your model exposes
  };

  ThreeMonthReportModel _fromJson(Map<String, dynamic> j) {
    // Use your model's existing fromJson if it has one — this is a fallback.
    // If your model has a static fromJson, replace the body with:
    //   return ThreeMonthReportModel.fromJson(j);
    return ThreeMonthReportModel(
      name: (j['name'] ?? '').toString(),
      student: (j['student'] ?? '').toString(),
      studentName: (j['student_name'] ?? '').toString(),
      classroom: (j['classroom'] ?? '').toString(),
      status: (j['status'] ?? '').toString(),
      periodStartDate: j['period_start_date']?.toString(),
      periodEndDate: j['period_end_date']?.toString(),
      creation: (j['creation'] ?? '').toString(), teacher: '', modified: '',
    );
  }
}
