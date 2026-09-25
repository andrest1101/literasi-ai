import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/constants/app_styles.dart';

/// Regresi U1: font Inter HARUS terbundel sebagai file TTF lokal.
///
/// Sebelumnya `AppStyles.fontFamily = 'Inter'` dideklarasikan tanpa file
/// biner sehingga Flutter diam-diam fallback ke font sistem: layar
/// terlihat "default". Test ini gagal keras bila salah satu weight
/// hilang atau bukan TTF valid.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Bundel font Inter (offline-safe)', () {
    test('AppStyles memakai family Inter di tema', () {
      expect(AppStyles.fontFamily, 'Inter');
      expect(
        AppStyles.theme.textTheme.bodyMedium?.fontFamily,
        'Inter',
      );
    });

    for (final weight in [400, 500, 700, 800]) {
      test('Inter-$weight.ttf ada, TTF valid, ukuran wajar', () async {
        final data = await rootBundle.load(
          'assets/fonts/Inter-$weight.ttf',
        );
        expect(
          data.lengthInBytes,
          greaterThan(10000),
          reason: 'Inter-$weight.ttf terlalu kecil: file rusak?',
        );
        final magic = data.buffer.asUint8List(0, 4);
        expect(
          magic,
          [0x00, 0x01, 0x00, 0x00],
          reason: 'Inter-$weight.ttf bukan file TTF valid',
        );
      });
    }
  });
}
