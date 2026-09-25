import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/constants/app_colors.dart';
import 'package:literasi_ai/features/quick_check/domain/entities/verification_result.dart';
import 'package:literasi_ai/features/quick_check/presentation/widgets/quick_check_result_section.dart';

/// Regresi U3: spine aksen verdict sebagai signature visual kartu hasil.
///
/// Satu garis 6px warna verdict di tepi kiri (merah HOAKS / hijau VALID /
/// kuning PERLU DICEK / abu TIDAK PASTI). Diimplementasi sebagai lapisan
/// di belakang isi agar sudut membulat rapi.
void main() {
  VerificationResult resultFor(Verdict verdict) => VerificationResult(
    claim: 'Klaim uji spine yang cukup panjang untuk validasi.',
    verdict: verdict,
    confidence: 88,
    explanation: 'Penjelasan uji.',
    suggestion: 'Saran uji.',
    checkedAt: DateTime(2026, 9, 26),
  );

  Future<void> pumpResult(WidgetTester tester, Verdict verdict) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: QuickCheckResultSection(
              result: resultFor(verdict),
              loading: false,
              onNewCheck: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Color? spineColor(WidgetTester tester) {
    BoxDecoration? decorationOf(Widget? widget) {
      if (widget is ExcludeSemantics) {
        return decorationOf(widget.child);
      }
      if (widget is Container) {
        final decoration = widget.decoration;
        if (decoration is BoxDecoration) return decoration;
      }
      return null;
    }

    final stacks = find
        .byWidgetPredicate(
          (w) =>
              w is Stack &&
              w.children.length == 2 &&
              w.children.first is Positioned,
        )
        .evaluate();
    for (final element in stacks) {
      final stack = element.widget as Stack;
      final back = stack.children.first as Positioned;
      final decoration = decorationOf(back.child);
      if (decoration != null && decoration.color != null) {
        return decoration.color;
      }
    }
    return null;
  }

  group('Signature verdict spine U3', () {
    testWidgets('spine HOAKS merah menempel di kiri kartu', (
      WidgetTester tester,
    ) async {
      await pumpResult(tester, Verdict.hoaks);
      expect(spineColor(tester), AppColors.danger);
      expect(tester.takeException(), isNull);
    });

    testWidgets('spine VALID hijau, PERLU DICEK kuning', (
      WidgetTester tester,
    ) async {
      await pumpResult(tester, Verdict.valid);
      expect(spineColor(tester), AppColors.success);

      await pumpResult(tester, Verdict.perluDicek);
      expect(spineColor(tester), AppColors.verdictAmber);
      expect(tester.takeException(), isNull);
    });

    testWidgets('kartu tetap render lengkap di dua lebar layar', (
      WidgetTester tester,
    ) async {
      for (final width in [360.0, 412.0]) {
        tester.view.physicalSize = Size(width, 915);
        tester.view.devicePixelRatio = 1.0;
        await pumpResult(tester, Verdict.hoaks);
        expect(find.text('Informasi ini tidak benar'), findsOneWidget);
        expect(find.text('88%'), findsOneWidget);
      }
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      expect(tester.takeException(), isNull);
    });

    testWidgets('headline status definitif, bukan perintah perilaku', (
      WidgetTester tester,
    ) async {
      await pumpResult(tester, Verdict.hoaks);
      expect(find.text('Informasi ini tidak benar'), findsOneWidget);

      await pumpResult(tester, Verdict.valid);
      expect(find.text('Informasi ini benar'), findsOneWidget);

      await pumpResult(tester, Verdict.perluDicek);
      expect(find.text('Kebenarannya belum pasti'), findsOneWidget);

      await pumpResult(tester, Verdict.tidakDapatDipastikan);
      expect(find.text('Belum bisa dipastikan'), findsOneWidget);

      // Frasa perintah lama tidak boleh muncul di mana pun.
      expect(find.text('Jangan disebar'), findsNothing);
      expect(find.text('Aman dengan konteks'), findsNothing);
      expect(find.text('Cek sumber lain dulu'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
