import 'package:hive/hive.dart';

import '../models/pending_scan.dart';

class GateQueueService {
  static const _box = 'gate_queue';
  static const _morningKey = 'morning_scans';
  static const _eveningKey = 'evening_scans';

  Future<Box> _open() async {
    if (Hive.isBoxOpen(_box)) return Hive.box(_box);
    return Hive.openBox(_box);
  }

  // ── MORNING QUEUE ──────────────────────────────
  Future<List<PendingScan>> getMorning() async {
    final box = await _open();
    final raw = box.get(_morningKey) as List? ?? [];
    return raw
        .map((e) => PendingScan.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> addMorning(PendingScan scan) async {
    final list = await getMorning();
    final updated = List<PendingScan>.from(list)
      ..removeWhere((s) => s.studentId == scan.studentId)
      ..add(scan);
    final box = await _open();
    await box.put(_morningKey, updated.map((s) => s.toMap()).toList());
  }

  Future<void> clearMorning() async {
    final box = await _open();
    await box.delete(_morningKey);
  }

  // ── EVENING QUEUE ──────────────────────────────
  Future<List<PendingScan>> getEvening() async {
    final box = await _open();
    final raw = box.get(_eveningKey) as List? ?? [];
    return raw
        .map((e) => PendingScan.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> addEvening(PendingScan scan) async {
    final list = await getEvening();
    final updated = List<PendingScan>.from(list)
      ..removeWhere((s) => s.studentId == scan.studentId)
      ..add(scan);
    final box = await _open();
    await box.put(_eveningKey, updated.map((s) => s.toMap()).toList());
  }

  Future<void> clearEvening() async {
    final box = await _open();
    await box.delete(_eveningKey);
  }

  Future<void> clearAll() async {
    final box = await _open();
    await box.clear();
  }
}
