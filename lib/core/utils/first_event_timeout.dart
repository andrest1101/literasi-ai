import 'dart:async';

/// Batas waktu yang hanya berlaku sampai event pertama tiba.
///
/// `Stream.timeout` biasa memasang ulang timer setiap kali ada event. Pada
/// stream panjang seperti snapshot Firestore, timer itu akan menyala setiap
/// kali dokumen tidak berubah selama [limit] — padahal data terakhir masih
/// valid. Akibatnya UI yang menampilkan error untuk state tersebut terlihat
/// "kehilangan" progres/skor setiap 10 detik.
///
/// Helper ini mematikan timer begitu ada data/error pertama. Timeout hanya
/// berfungsi sebagai jaring pengaman agar skeleton tidak menggantung bila
/// stream benar-benar tidak pernah mengirim apa pun.
///
/// Subscription sumber sengaja tidak diputus saat timeout supaya event yang
/// datang terlambat (mis. jaringan pulih) tetap memulihkan UI.
Stream<T> timeoutFirstEvent<T>(
  Stream<T> source, {
  required Duration limit,
  required Object error,
}) {
  late final StreamController<T> controller;
  StreamSubscription<T>? subscription;
  Timer? timer;
  var receivedEvent = false;

  void cancelTimer() {
    timer?.cancel();
    timer = null;
  }

  void markEventReceived() {
    receivedEvent = true;
    cancelTimer();
  }

  controller = StreamController<T>(
    onListen: () {
      timer = Timer(limit, () {
        if (receivedEvent) return;
        timer = null;
        controller.addError(error);
      });
      subscription = source.listen(
        (value) {
          markEventReceived();
          controller.add(value);
        },
        onError: (Object sourceError, StackTrace stackTrace) {
          markEventReceived();
          controller.addError(sourceError, stackTrace);
        },
        onDone: () {
          cancelTimer();
          controller.close();
        },
      );
    },
    onCancel: () {
      cancelTimer();
      return subscription?.cancel();
    },
  );
  return controller.stream;
}
