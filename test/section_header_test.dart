import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/app/home_screen.dart';
import 'package:literasi_ai/core/constants/app_colors.dart';
import 'package:literasi_ai/features/chat/presentation/screens/chat_screen.dart';
import 'package:literasi_ai/features/quick_check/presentation/screens/quick_check_session_screen.dart';
import 'package:literasi_ai/shared/widgets/app_section_header.dart';

void main() {
  testWidgets('check tab owns wordmark, others use contextual titles', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.text('LiterasiAI'), findsOneWidget);
    expect(find.text('AI Aktif'), findsNothing);
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(AppSectionHeader), findsOneWidget);
    expect(find.text('Cek kebenaran'), findsOneWidget);
    expect(find.text('sebelum sebar.'), findsOneWidget);

    final accent = tester.widget<Text>(find.text('sebelum sebar.'));
    expect(accent.style?.fontStyle, FontStyle.italic);
    expect(accent.style?.color, AppColors.primary);

    await tester.tap(find.text('Riwayat'));
    await tester.pumpAndSettle();
    expect(find.text('LiterasiAI'), findsNothing);
    expect(find.text('Jejak'), findsOneWidget);
    expect(find.text('pemeriksaanmu.'), findsOneWidget);

    await tester.tap(find.text('Belajar'));
    await tester.pumpAndSettle();
    expect(find.text('LiterasiAI'), findsNothing);
    expect(find.text('Naikkan'), findsOneWidget);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('LiterasiAI'), findsNothing);
    expect(find.text('Kelola'), findsOneWidget);
    expect(find.text('Sumber poin'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('history is functional while future tabs remain honest', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Riwayat'));
    await tester.pumpAndSettle();
    expect(find.text('Jejak'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);

    await tester.tap(find.text('Belajar'));
    await tester.pumpAndSettle();
    expect(find.text('Modul segera hadir'), findsOneWidget);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Sumber poin'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chat and session have single titles, no appbar doubling', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ChatScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Asisten LiterasiAI'), findsOneWidget);
    expect(find.text('Siap membantu verifikasi'), findsOneWidget);
    expect(find.text('Mode pratinjau: kunci API belum tersambung'), findsOneWidget);
    expect(find.text('Salin perintah'), findsOneWidget);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: QuickCheckSessionScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.text('SESI FOKUS'), findsOneWidget);
    expect(find.text('Sesi pemeriksaan'), findsNothing);
    expect(find.text('Kembali'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('header fits narrow 360px viewport without overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AppSectionHeader(
              eyebrow: 'VERIFIKASI AI',
              titleLine1: 'Cek kebenaran',
              titleLine2: 'sebelum sebar.',
              subtitle: 'Subtitle uji header editorial.',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AppSectionHeader), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
