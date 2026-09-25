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
