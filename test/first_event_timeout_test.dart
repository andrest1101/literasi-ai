import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/utils/first_event_timeout.dart';

void main() {
  group('timeoutFirstEvent', () {
    test('error hanya bila belum ada event sampai batas waktu', () async {
      final source = StreamController<int>();
      addTearDown(source.close);
      final stream = timeoutFirstEvent(
        source.stream,
        limit: const Duration(milliseconds: 30),
        error: TimeoutException('lambat'),
      );

      await expectLater(stream, emitsError(isA<TimeoutException>()));
    });

    test('setelah event pertama, stream boleh diam tanpa error', () async {
      final source = StreamController<int>();
      addTearDown(source.close);
      final values = <int>[];
      final errors = <Object>[];
      var done = false;
      final sub = timeoutFirstEvent(
        source.stream,
        limit: const Duration(milliseconds: 30),
        error: TimeoutException('lambat'),
      ).listen(values.add, onError: errors.add, onDone: () => done = true);
      addTearDown(sub.cancel);

      source.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 120));

      expect(values, [1]);
      expect(errors, isEmpty, reason: 'timer harus mati setelah event pertama');
      expect(done, isFalse, reason: 'stream sumber masih hidup');

      source.add(2);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(values, [1, 2]);
    });

    test('error sumber diteruskan apa adanya tanpa timeout tambahan', () async {
      final source = StreamController<int>();
      addTearDown(source.close);
      final errors = <Object>[];
      final sub = timeoutFirstEvent(
        source.stream,
        limit: const Duration(milliseconds: 30),
        error: TimeoutException('lambat'),
      ).listen((_) {}, onError: errors.add);
      addTearDown(sub.cancel);

      source.addError(StateError('putus'));
      await Future<void>.delayed(const Duration(milliseconds: 120));

      expect(errors, hasLength(1));
      expect(errors.single, isA<StateError>());
    });

    test('data terlambat tetap diteruskan setelah timeout', () async {
      final source = StreamController<int>();
      addTearDown(source.close);
      final values = <int>[];
      final errors = <Object>[];
      final sub = timeoutFirstEvent(
        source.stream,
        limit: const Duration(milliseconds: 20),
        error: TimeoutException('lambat'),
      ).listen(values.add, onError: errors.add);
      addTearDown(sub.cancel);

      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(errors, hasLength(1));

      source.add(7);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(values, [7], reason: 'koneksi pulih harus memulihkan UI');
    });

    test('done sumber menutup stream turunan', () async {
      final source = StreamController<int>();
      final done = expectLater(
        timeoutFirstEvent(
          source.stream,
          limit: const Duration(seconds: 5),
          error: TimeoutException('lambat'),
        ),
        emitsDone,
      );

      await source.close();
      await done;
    });
  });
}
