import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../errors/failures.dart';
import 'gemini_model_pool.dart';

/// Hasil satu tahap diagnostik konektivitas Gemini.
class GeminiProbeStep {
  const GeminiProbeStep({
    required this.name,
    required this.ok,
    required this.elapsed,
    this.detail = '',
  });

  final String name;
  final bool ok;
  final Duration elapsed;
  final String detail;
}

/// Kesimpulan diagnostik — tahap mana yang gagal + saran perbaikan.
class GeminiProbeReport {
  const GeminiProbeReport({required this.steps, required this.verdict});

  final List<GeminiProbeStep> steps;
  final GeminiProbeVerdict verdict;
}

enum GeminiProbeVerdict {
  /// Semua tahap OK — jaringan beres, masalah di kunci/model/kuota.
  healthy,

  /// DNS gagal — masalah jaringan lokal.
  dnsFailed,

  /// TCP 443 gagal — firewall/antivirus/VPN memblokir proses app.
  tcpBlocked,

  /// HTTPS gagal — TLS/proxy bermasalah.
  tlsFailed,

  /// API menolak kunci — kunci salah/dinonaktifkan.
  keyRejected,

  /// Server sibuk sementara (503/overloaded) — kunci dan jaringan beres,
  /// tinggal tunggu 1 menit. Bedakan dari apiStalled agar user tidak
  /// mengutak-atik kunci yang sebenarnya valid.
  busy,

  /// API menjawab tapi generate macet — model/kuota/safety.
  apiStalled,
}

/// Diagnostik konektivitas Gemini bertahap dari dalam proses app.
///
/// Mengapa tidak cukup mengandalkan timeout 30 detik? Timeout hanya bilang
/// "tidak ada respons" tanpa tahu macet di mana. Probe ini memecah jalur
/// menjadi 4 tahap murah (DNS → TCP 443 → HTTPS GET → generate 1 kata),
/// masing-masing dengan timeout sendiri, sehingga hasilnya menunjuk
/// penyebab persis: jaringan lokal, firewall proses, TLS/proxy, kunci,
/// atau model. Dipakai tombol Tes Koneksi di layar Pengaturan.
abstract final class GeminiConnectivityProbe {
  static const String host = 'generativelanguage.googleapis.com';

  static const Duration dnsTimeout = Duration(seconds: 8);
  static const Duration tcpTimeout = Duration(seconds: 8);
  static const Duration httpsTimeout = Duration(seconds: 12);
  static const Duration apiTimeout = Duration(seconds: 30);

  static Future<GeminiProbeReport> run({
    required String apiKey,
    required String modelName,
  }) async {
    // `modelName` = model utama yang diharapkan (dipakai pool sebagai
    // kandidat pertama lewat GeminiModelPool.defaultCandidates); tahap 4
    // sendiri memakai pool agar hasil tes sama dengan jalur aplikasi.
    assert(GeminiModelPool.defaultCandidates.contains(modelName));
    final steps = <GeminiProbeStep>[];

    // Tahap 1: DNS — gagal = Wi-Fi/data mati atau DNS dibajak.
    final dnsWatch = Stopwatch()..start();
    List<InternetAddress> addresses;
    try {
      addresses = await InternetAddress.lookup(host).timeout(dnsTimeout);
      dnsWatch.stop();
      if (addresses.isEmpty) throw const SocketException('DNS kosong');
      steps.add(
        GeminiProbeStep(
          name: 'DNS',
          ok: true,
          elapsed: dnsWatch.elapsed,
          detail: '${addresses.length} alamat',
        ),
      );
    } catch (e) {
      dnsWatch.stop();
      steps.add(
        GeminiProbeStep(
          name: 'DNS',
          ok: false,
          elapsed: dnsWatch.elapsed,
          detail: e.toString(),
        ),
      );
      return GeminiProbeReport(
        steps: steps,
        verdict: GeminiProbeVerdict.dnsFailed,
      );
    }

    // Tahap 2: TCP 443 ke alamat pertama — gagal = firewall/antivirus/VPN
    // memblokir PROSES app (bukan jaringan umum, karena browser bisa jalan).
    final tcpWatch = Stopwatch()..start();
    try {
      final socket = await Socket.connect(
        addresses.first,
        443,
        timeout: tcpTimeout,
      );
      tcpWatch.stop();
      socket.destroy();
      steps.add(
        GeminiProbeStep(
          name: 'TCP 443',
          ok: true,
          elapsed: tcpWatch.elapsed,
          detail: addresses.first.address,
        ),
      );
    } catch (e) {
      tcpWatch.stop();
      steps.add(
        GeminiProbeStep(
          name: 'TCP 443',
          ok: false,
          elapsed: tcpWatch.elapsed,
          detail: e.toString(),
        ),
      );
      return GeminiProbeReport(
        steps: steps,
        verdict: GeminiProbeVerdict.tcpBlocked,
      );
    }

    // Tahap 3: HTTPS GET daftar model — gagal = TLS/proxy intercept bermasalah.
    final httpsWatch = Stopwatch()..start();
    try {
      final client = HttpClient();
      client.connectionTimeout = httpsTimeout;
      try {
        final request = await client
            .getUrl(Uri.https(host, '/v1beta/models', {'key': apiKey}))
            .timeout(httpsTimeout);
        final response = await request.close().timeout(httpsTimeout);
        await response.drain<void>().timeout(httpsTimeout);
        httpsWatch.stop();
        if (response.statusCode == 400) {
          // 400 = server menjawab (kunci dummy/ditolak) → jalur HTTPS beres.
          steps.add(
            GeminiProbeStep(
              name: 'HTTPS',
              ok: true,
              elapsed: httpsWatch.elapsed,
              detail: 'HTTP ${response.statusCode} (server menjawab)',
            ),
          );
        } else if (response.statusCode == 200) {
          steps.add(
            GeminiProbeStep(
              name: 'HTTPS',
              ok: true,
              elapsed: httpsWatch.elapsed,
              detail: 'HTTP 200',
            ),
          );
        } else {
          steps.add(
            GeminiProbeStep(
              name: 'HTTPS',
              ok: false,
              elapsed: httpsWatch.elapsed,
              detail: 'HTTP ${response.statusCode}',
            ),
          );
          return GeminiProbeReport(
            steps: steps,
            verdict: GeminiProbeVerdict.tlsFailed,
          );
        }
      } finally {
        client.close();
      }
    } catch (e) {
      httpsWatch.stop();
      steps.add(
        GeminiProbeStep(
          name: 'HTTPS',
          ok: false,
          elapsed: httpsWatch.elapsed,
          detail: e.toString(),
        ),
      );
      return GeminiProbeReport(
        steps: steps,
        verdict: GeminiProbeVerdict.tlsFailed,
      );
    }

    // Tahap 4: generate 1 kata lewat pool (ikut failover antar model, sama
    // persis dengan jalur aplikasi) — gagal = kunci/kuota yang menyangkut
    // semua model cadangan.
    final apiWatch = Stopwatch()..start();
    try {
      final response = await GeminiModelPool.shared.generate(
        apiKey: apiKey,
        generationConfig: GenerationConfig(),
        contents: [Content.text('Balas hanya: ok')],
        context: 'probe',
        timeout: apiTimeout,
      );
      apiWatch.stop();
      final text = response.text?.trim() ?? '';
      steps.add(
        GeminiProbeStep(
          name: 'API generate',
          ok: true,
          elapsed: apiWatch.elapsed,
          detail: text.isEmpty ? 'kosong' : text,
        ),
      );
      return GeminiProbeReport(
        steps: steps,
        verdict: GeminiProbeVerdict.healthy,
      );
    } on TimeoutException catch (e) {
      apiWatch.stop();
      debugPrint('Gemini probe API timeout: $e');
      steps.add(
        GeminiProbeStep(
          name: 'API generate',
          ok: false,
          elapsed: apiWatch.elapsed,
          detail: 'timeout ${apiTimeout.inSeconds} dtk',
        ),
      );
      return GeminiProbeReport(
        steps: steps,
        verdict: GeminiProbeVerdict.apiStalled,
      );
    } on GenerativeAIException catch (e) {
      apiWatch.stop();
      final lower = e.message.toLowerCase();
      final rejected =
          e is InvalidApiKey || lower.contains('api key not valid');
      final busy = lower.contains('overloaded') ||
          lower.contains('high demand') ||
          lower.contains('503') ||
          lower.contains('try again later');
      steps.add(
        GeminiProbeStep(
          name: 'API generate',
          ok: false,
          elapsed: apiWatch.elapsed,
          detail: busy ? 'server sibuk (503)' : e.runtimeType.toString(),
        ),
      );
      debugPrint('Gemini probe API error (${e.runtimeType}): ${e.message}');
      return GeminiProbeReport(
        steps: steps,
        verdict: rejected
            ? GeminiProbeVerdict.keyRejected
            : busy
                ? GeminiProbeVerdict.busy
                : GeminiProbeVerdict.apiStalled,
      );
    } on Failure catch (e) {
      // Pool sudah mencoba seluruh kandidat model — pesan mapper memuat
      // kesimpulan akhirnya (semua model kena kuota, sibuk, timeout, dst).
      apiWatch.stop();
      final message = e.message;
      final lower = message.toLowerCase();
      final rejected = lower.contains('ditolak');
      final busy = lower.contains('sibuk');
      final detail = message.length > 90
          ? '${message.substring(0, 90)}…'
          : message;
      steps.add(
        GeminiProbeStep(
          name: 'API generate',
          ok: false,
          elapsed: apiWatch.elapsed,
          detail: detail,
        ),
      );
      debugPrint('Gemini probe API gagal di semua model: $message');
      return GeminiProbeReport(
        steps: steps,
        verdict: rejected
            ? GeminiProbeVerdict.keyRejected
            : busy
                ? GeminiProbeVerdict.busy
                : GeminiProbeVerdict.apiStalled,
      );
    } catch (e) {
      apiWatch.stop();
      debugPrint('Gemini probe API gagal: $e');
      steps.add(
        GeminiProbeStep(
          name: 'API generate',
          ok: false,
          elapsed: apiWatch.elapsed,
          detail: e.toString(),
        ),
      );
      return GeminiProbeReport(
        steps: steps,
        verdict: GeminiProbeVerdict.apiStalled,
      );
    } finally {
      apiWatch.stop();
    }
  }

  /// Saran perbaikan Bahasa Indonesia untuk tiap verdict.
  static String adviceFor(GeminiProbeVerdict verdict) {
    return switch (verdict) {
      GeminiProbeVerdict.healthy =>
        'Koneksi AI OK. Kunci dan jaringan beres.',
      GeminiProbeVerdict.dnsFailed =>
        'Perangkat tidak bisa menemukan server Google. Periksa Wi-Fi/data seluler, lalu coba lagi.',
      GeminiProbeVerdict.tcpBlocked =>
        'Koneksi diblokir di perangkat ini (firewall/antivirus/VPN). Izinkan aplikasi LiterasiAI di firewall/antivirus atau matikan VPN, lalu tes lagi.',
      GeminiProbeVerdict.tlsFailed =>
        'Koneksi aman (TLS/proxy) gagal. Matikan VPN, ad-block, atau proxy, lalu tes lagi.',
      GeminiProbeVerdict.keyRejected =>
        'Kunci API ditolak server. Salin ulang kunci dari Google AI Studio tanpa spasi, lalu simpan ulang.',
      GeminiProbeVerdict.busy =>
        'Server AI sedang sibuk (lonjakan pemakaian, biasanya sementara). Kunci dan jaringan beres — tunggu sekitar 1 menit lalu tes lagi.',
      GeminiProbeVerdict.apiStalled =>
        'Server menjawab tapi generate macet (model/kuota/filter). Tunggu sebentar lalu tes lagi; bila tetap, ganti kunci atau laporkan pesan ini.',
    };
  }
}
