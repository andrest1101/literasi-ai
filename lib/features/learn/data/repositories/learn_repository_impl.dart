import '../../domain/entities/course_module.dart';
import '../../domain/entities/course_progress.dart';
import '../../domain/repositories/learn_repository.dart';
import '../datasources/learn_content_datasource.dart';
import '../datasources/learn_remote_datasource.dart';
import '../models/learn_progress_model.dart';

class LearnRepositoryImpl implements LearnRepository {
  LearnRepositoryImpl(this._remote, {LearnContentDatasource? content})
    : _content = content ?? LearnContentDatasource();

  final LearnRemoteDatasource _remote;
  final LearnContentDatasource _content;

  @override
  List<CourseModule> modules() => _content.modules();

  @override
  CourseModule? moduleById(String id) => _content.byId(id);

  @override
  Stream<CourseProgress> watchProgress(String userId) =>
      _remote.watch(userId).map(LearnProgressModel.fromDocument);

  @override
  Future<bool> completeModule(String userId, String moduleId) async {
    // Idempoten dijamin arrayUnion; deteksi pertama-kali butuh baca cepat
    // agar poin +20 tidak diklaim ulang. Gagal baca = anggap belum selesai
    // (lebih baik beri poin sekali lebih daripada menolak yang berhak).
    var already = false;
    try {
      final current = await _remote
          .watch(userId)
          .map(LearnProgressModel.fromDocument)
          .first;
      already = current.isCompleted(moduleId);
    } catch (_) {
      already = false;
    }
    await _remote.completeModule(userId, moduleId);
    return !already;
  }

  @override
  Future<int> submitQuiz(String userId, String moduleId, int correctCount) async {
    var previous = 0;
    try {
      final current = await _remote
          .watch(userId)
          .map(LearnProgressModel.fromDocument)
          .first;
      previous = current.bestFor(moduleId);
    } catch (_) {
      previous = 0;
    }
    if (correctCount <= previous) return 0;
    await _remote.submitQuizBest(userId, moduleId, correctCount);
    return correctCount - previous;
  }
}
