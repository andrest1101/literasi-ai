import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/utils/gemini_connectivity_probe.dart';

void main() {
  group('GeminiConnectivityProbe.adviceFor — saran per tahap gagal', () {
    test('healthy → koneksi OK', () {
      expect(
        GeminiConnectivityProbe.adviceFor(GeminiProbeVerdict.healthy),
        contains('Koneksi AI OK'),
      );
    });

    test('dnsFailed → periksa Wi-Fi/data', () {
      expect(
        GeminiConnectivityProbe.adviceFor(GeminiProbeVerdict.dnsFailed),
        contains('Wi-Fi'),
      );
    });

    test('tcpBlocked → firewall/antivirus/VPN', () {
      final advice = GeminiConnectivityProbe.adviceFor(
        GeminiProbeVerdict.tcpBlocked,
      );
      expect(advice, contains('firewall'));
      expect(advice, contains('VPN'));
    });

    test('tlsFailed → VPN/ad-block/proxy', () {
      final advice = GeminiConnectivityProbe.adviceFor(
        GeminiProbeVerdict.tlsFailed,
      );
      expect(advice, contains('VPN'));
      expect(advice, contains('proxy'));
    });

    test('keyRejected → salin ulang kunci', () {
      expect(
        GeminiConnectivityProbe.adviceFor(GeminiProbeVerdict.keyRejected),
        contains('AI Studio'),
      );
    });

    test('busy → server sibuk, kunci beres, tunggu 1 menit', () {
      final advice = GeminiConnectivityProbe.adviceFor(
        GeminiProbeVerdict.busy,
      );
      expect(advice, contains('sibuk'));
      expect(advice, contains('1 menit'));
      expect(advice, contains('beres'));
    });

    test('apiStalled → tunggu/ganti kunci/lapor', () {
      final advice = GeminiConnectivityProbe.adviceFor(
        GeminiProbeVerdict.apiStalled,
      );
      expect(advice, contains('Tunggu'));
    });
  });

  group('GeminiProbeStep/Report — struktur data', () {
    test('step menyimpan nama, status, durasi, detail', () {
      const step = GeminiProbeStep(
        name: 'DNS',
        ok: true,
        elapsed: Duration(milliseconds: 16),
        detail: '8 alamat',
      );
      expect(step.name, 'DNS');
      expect(step.ok, isTrue);
      expect(step.elapsed.inMilliseconds, 16);
      expect(step.detail, '8 alamat');
    });

    test('report menyimpan steps + verdict', () {
      const report = GeminiProbeReport(
        steps: [
          GeminiProbeStep(
            name: 'DNS',
            ok: false,
            elapsed: Duration(seconds: 8),
          ),
        ],
        verdict: GeminiProbeVerdict.dnsFailed,
      );
      expect(report.steps, hasLength(1));
      expect(report.verdict, GeminiProbeVerdict.dnsFailed);
    });
  });
}
