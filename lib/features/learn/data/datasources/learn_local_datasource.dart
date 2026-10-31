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

  /// Snapshot terakhir yang sudah diketahui, dipakai [readCachedProgress]
  /// agar invalidasi provider tidak sempat mengirim progres kosong.
  CourseProgress? _lastProgress;

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
  ///
  /// Selalu mengembalikan progres terakhir yang diketahui. Nilai kosong hanya
  /// dipakai saat sesi benar-benar belum pernah membaca/menulis progres.
  CourseProgress readCachedProgress() {
    final cached = _lastProgress;
    if (cached != null) return cached;
    final completed = List<String>.from(
      _memory[_completedKey] as List<String>? ?? const [],
    );
    final best = _decodeBest(_memory[_quizBestKey] as String?);
    return CourseProgress(completedModuleIds: completed, quizBest: best);
  }

  static Map<String, int> _decodeBest(String? encodedBest) {
    final best = <String, int>{};
    if (encodedBest == null) return best;
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
    return best;
  }

  Future<CourseProgress> readProgress() async {
    await _ensurePreferences();
    final completed =
        _preferences?.getStringList(_completedKey) ??
        List<String>.from(_memory[_completedKey] as List<String>? ?? const []);
    final encodedBest =
        _preferences?.getString(_quizBestKey) ??
        _memory[_quizBestKey] as String?;
    final progress = CourseProgress(
      completedModuleIds: completed,
      quizBest: _decodeBest(encodedBest),
    );
    _lastProgress = progress;
    return progress;
  }

  Future<void> completeModule(String moduleId) async {
    await _ensurePreferences();
    final progress = await readProgress();
    final completed = {...progress.completedModuleIds, moduleId}.toList();
    if (_preferences == null) {
      _memory[_completedKey] = completed;
    } else {
      await _preferences!.setStringList(_completedKey, completed);
    }
    _lastProgress = CourseProgress(
      completedModuleIds: completed,
      quizBest: progress.quizBest,
    );
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
    _lastProgress = CourseProgress(
      completedModuleIds: progress.completedModuleIds,
      quizBest: best,
    );
    return correctCount - previousBest;
  }
}
