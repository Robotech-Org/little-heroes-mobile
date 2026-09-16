import 'package:hive/hive.dart';
import 'package:little_heroes_mobile/features/home/data/models/daily_report_draft_model.dart';

class DailyReportDraftService {
  static const String _boxName = 'daily_report_drafts';

  Future<Box<Map>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<Map>(_boxName);
    }
    return await Hive.openBox<Map>(_boxName);
  }

  /// Save / update a draft. Each draft is keyed by its [draftKey]
  /// so multiple students can each have their own draft.
  Future<void> saveDraft(DailyReportDraftModel draft) async {
    final box = await _getBox();
    await box.put(draft.draftKey, draft.toMap());
  }

  /// Get a draft by key
  Future<DailyReportDraftModel?> getDraft(String key) async {
    final box = await _getBox();
    final raw = box.get(key);
    if (raw == null) return null;
    return DailyReportDraftModel.fromMap(Map<String, dynamic>.from(raw));
  }

  /// Delete a draft by key
  Future<void> deleteDraft(String key) async {
    final box = await _getBox();
    await box.delete(key);
  }

  /// List all drafts, newest first
  Future<List<DailyReportDraftModel>> listAllDrafts() async {
    final box = await _getBox();
    final list = box.values
        .map((e) => DailyReportDraftModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    list.sort((a, b) => b.savedAt.compareTo(a.savedAt)); // newest first
    return list;
  }

  /// Check if a draft exists for a given student (used when student is picked)
  Future<bool> hasDraftForStudent(String studentId) async {
    final box = await _getBox();
    return box.containsKey('student_$studentId');
  }

  /// Delete all drafts (e.g., on logout)
  Future<void> clearAll() async {
    final box = await _getBox();
    await box.clear();
  }
}
