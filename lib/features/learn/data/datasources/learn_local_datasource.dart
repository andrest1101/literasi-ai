import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/course_progress.dart';

/// Local progress for anonymous users. It is deliberately separate from the
/// cloud score ledger: guests keep learning progress on this device, but do
/// not receive points that cannot be synced to an account.
class LearnLocalDatasource {
  LearnLocalDatasource([Future<SharedPreferences>? preferences])
    : _preferencesFuture = preferences;

  static const _completedKey = 'learn.guest.completed_modules';
  static const _quizBestKey = 'learn.guest.quiz_best';

  final Future<SharedPreferences>? _preferencesFuture;
  SharedPreferences? _preferences;
  final Map<String, Object> _memory = {};

  Future<void> _ensurePreferences() async {
    final pending = _preferencesFuture;
    if (_preferences == null && pending != null) {
      try {
        _preferences = await pending;
        final localCompleted = _memory[_completedKey] as List<String>?;
        if (localCompleted != null) {
          await _preferences!.setStringList(_completedKey, localCompleted);
        }
        final localBest = _memory[_quizBestKey] as String?;
        if (localBest != null) {
          await _preferences!.setString(_quizBestKey, localBest);
        }
        _memory.clear();
      } catch (_) {
        // Use in-memory fallback if the platform store is unavailable.
      }
    }
  }

  /// Immediate cache snapshot used to keep the screen out of a loading
  /// shimmer while the platform preferences plugin initializes.
  CourseProgress readCachedProgress() {
    final completed = List<String>.from(
      _memory[_completedKey] as List<String>? ?? const [],
    );
    final encodedBest = _memory[_quizBestKey] as String?;
    final best = <String, int>{};
    if (encodedBest != null) {
      try {
        final decoded = jsonDecode(encodedBest);
        if (decoded is Map<String, dynamic>) {
          for (final entry in decoded.entries) {
            final score = entry.value;
            if (score is num && score > 0) best[entry.key] = score.toInt();
          }
        }
      } on FormatException {
        // Ignore malformed cache data.
      }
    }
    return CourseProgress(completedModuleIds: completed, quizBest: best);
  }

  Future<CourseProgress> readProgress() async {
    await _ensurePreferences();
    final completed =
        _preferences?.getStringList(_completedKey) ??
        List<String>.from(_memory[_completedKey] as List<String>? ?? const []);
    final encodedBest =
        _preferences?.getString(_quizBestKey) ??
        _memory[_quizBestKey] as String?;
    final best = <String, int>{};
    if (encodedBest != null) {
      try {
        final decoded = jsonDecode(encodedBest);
        if (decoded is Map<String, dynamic>) {
          for (final entry in decoded.entries) {
            final score = entry.value;
            if (score is num && score > 0) best[entry.key] = score.toInt();
          }
        }
      } on FormatException {
        // Corrupted local cache should not block access to the learning area.
      }
    }
    return CourseProgress(completedModuleIds: completed, quizBest: best);
  }

  Future<void> completeModule(String moduleId) async {
    await _ensurePreferences();
    final completed =
        ((_preferences?.getStringList(_completedKey) ??
                List<String>.from(
                  _memory[_completedKey] as List<String>? ?? const [],
                )))
            .toSet()
          ..add(moduleId);
    if (_preferences == null) {
      _memory[_completedKey] = completed.toList();
    } else {
      await _preferences!.setStringList(_completedKey, completed.toList());
    }
  }

  Future<int> submitQuiz(String moduleId, int correctCount) async {
    await _ensurePreferences();
    final progress = await readProgress();
    final previousBest = progress.bestFor(moduleId);
    if (correctCount <= previousBest) return 0;
    final best = Map<String, int>.from(progress.quizBest)
      ..[moduleId] = correctCount;
    final encoded = jsonEncode(best);
    if (_preferences == null) {
      _memory[_quizBestKey] = encoded;
    } else {
      await _preferences!.setString(_quizBestKey, encoded);
    }
    return correctCount - previousBest;
  }
}
