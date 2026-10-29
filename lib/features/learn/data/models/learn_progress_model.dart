import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/course_progress.dart';

/// Mapping progres belajar: toleran dokumen hilang/korup.
class LearnProgressModel {
  const LearnProgressModel._();

  static CourseProgress fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return fromMap(doc.data() ?? const <String, dynamic>{});
  }

  static CourseProgress fromMap(Map<String, dynamic> data) {
    final modules = data['completedModules'];
    final best = data['quizBest'];
    final bestMap = <String, int>{};
    if (best is Map) {
      for (final entry in best.entries) {
        final raw = entry.value;
        final score = raw is num ? raw.toInt() : 0;
        if (entry.key.toString().isNotEmpty && score > 0) {
          bestMap[entry.key.toString()] = score;
        }
      }
    }
    // Older builds wrote dotted field names through `set()`, which stores
    // those names literally rather than nesting them under `quizBest`.
    // Continue reading that shape so users' already-saved progress is not
    // lost while new writes use the proper nested map.
    for (final entry in data.entries) {
      const prefix = 'quizBest.';
      if (!entry.key.startsWith(prefix)) continue;
      final moduleId = entry.key.substring(prefix.length);
      final score = entry.value;
      if (moduleId.isNotEmpty && score is num && score > 0) {
        final legacyScore = score.toInt();
        if (legacyScore > (bestMap[moduleId] ?? 0)) {
          bestMap[moduleId] = legacyScore;
        }
      }
    }
    return CourseProgress(
      completedModuleIds: modules is List
          ? modules
                .map((e) => e?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toList(growable: false)
          : const [],
      quizBest: bestMap,
    );
  }
}
