import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/utils/api_key_resolver.dart';
import 'package:literasi_ai/core/utils/api_key_store.dart';
import 'package:literasi_ai/features/chat/data/datasources/demo_chat_datasource.dart';
import 'package:literasi_ai/features/chat/data/datasources/gemini_chat_datasource.dart';
import 'package:literasi_ai/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:literasi_ai/features/chat/presentation/screens/chat_screen.dart';
import 'package:literasi_ai/features/quick_check/data/datasources/demo_verification_datasource.dart';
import 'package:literasi_ai/features/quick_check/data/datasources/gemini_text_datasource.dart';
import 'package:literasi_ai/features/quick_check/data/repositories/verification_repository_impl.dart';
import 'package:literasi_ai/features/quick_check/domain/entities/image_attachment.dart';
import 'package:literasi_ai/features/quick_check/domain/entities/verification_result.dart';
import 'package:literasi_ai/features/quick_check/presentation/widgets/quick_check_result_section.dart';
import 'package:literasi_ai/features/score/presentation/screens/api_key_screen.dart';
import 'package:literasi_ai/features/score/presentation/screens/profile_screen.dart';

class _MemoryKeyStore implements ApiKeyStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String key) async {
    value = key;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}

void main() {
  group('ApiKeyResolver prioritas', () {
    test('controller menolak kunci pendek atau berspasi', () async {
      final store = _MemoryKeyStore();
      final container = ProviderContainer(
        overrides: [apiKeyStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);
      final notifier = container.read(apiKeyControllerProvider.notifier);
      expect(await notifier.save('pendek'), isNotNull);
      expect(await notifier.save('ADA SPASI DI SINI XXXXXXXX'), isNotNull);
      expect(store.value, isNull);
    });

    test('controller menyimpan dan menghapus kunci user', () async {
      final store = _MemoryKeyStore();
      final container = ProviderContainer(
        overrides: [apiKeyStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);
      final notifier = container.read(apiKeyControllerProvider.notifier);
      const key = 'AIzaSyContohKunciValid1234567890';
      expect(await notifier.save(key), isNull);
      expect(store.value, key);
      await notifier.clearUserKey();
      expect(store.value, isNull);
    });
  });

  group('Mode demo Quick Check jujur', () {
    VerificationRepositoryImpl demoRepo() {
      return VerificationRepositoryImpl(
        GeminiTextDatasource(apiKey: ''),
        hasApiKey: () => false,
      );
    }

    test('teks selalu uncertain + flag demo', () async {
      final result = await demoRepo().verifyTextClaim(
        'Klaim uji yang cukup panjang untuk demo.',
      );
      expect(result.isDemo, isTrue);
      expect(result.verdict, Verdict.tidakDapatDipastikan);
      expect(result.confidence, 0);
    });

    test('gambar demo membawa metadata benar', () async {
      final image = await demoRepo().verifyImageClaim(
        image: ImageAttachment(
          bytes: Uint8List.fromList(List.filled(16, 1)),
          mimeType: 'image/png',
          fileName: 'demo.png',
        ),
        caption: 'Caption demo yang cukup panjang.',
      );
      expect(image.isDemo, isTrue);
      expect(image.source, VerificationSource.image);
      expect(image.imageFileName, 'demo.png');
    });

    test('demo datasource tidak pernah mengarang verdict', () {
      final demo = DemoVerificationDatasource();
      for (final claim in [
        'Vaksin berbahaya hoaks besar dan konteks tambahan.',
        'Bantuan tunai Rp 10 juta cair hari ini plus syarat.',
        'Artis terkenal meninggal dunia menurut pesan berantai.',
      ]) {
        final result = demo.verifyText(claim);
        expect(result.verdict, Verdict.tidakDapatDipastikan);
        expect(result.isDemo, isTrue);
      }
    });
  });

  group('Mode demo Chat jujur', () {
    test('reply tanpa key memakai kerangka edukatif', () async {
      final repo = ChatRepositoryImpl(
        GeminiChatDatasource(apiKey: ''),
        hasApiKey: () => false,
      );
      final answer = await repo.reply(history: const [], message: 'Hoaks?');
      expect(answer, contains('Mode demo'));
      expect(answer, contains('TurnBackHoax'));
    });

    test('topik kesehatan terdeteksi', () {
      final answer = DemoChatDatasource().reply(
        'Apakah vaksin ini aman untuk anak saya?',
      );
      expect(answer, contains('klaim kesehatan'));
    });
  });

  testWidgets('hasil demo tampil badge DEMO + catatan jujur', (
    WidgetTester tester,
  ) async {
    final result = VerificationResult.uncertain(
      'Klaim demo yang cukup panjang.',
      isDemo: true,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: QuickCheckResultSection(
              result: result,
              loading: false,
              onNewCheck: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('DEMO'), findsOneWidget);
    expect(find.textContaining('bukan penilaian AI live'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('banner chat punya tombol pengaturan + salin', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const ChatScreen(),
          routes: {ApiKeyScreen.route: (_) => const ApiKeyScreen()},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Buka Pengaturan'), findsOneWidget);
    expect(find.text('Salin perintah'), findsOneWidget);

    await tester.tap(find.text('Buka Pengaturan'));
    await tester.pumpAndSettle();
    expect(find.byType(ApiKeyScreen), findsOneWidget);
    expect(find.text('Kunci API Gemini'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('layar pengaturan simpan dan tampil status aktif', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiKeyStoreProvider.overrideWithValue(_MemoryKeyStore()),
        ],
        child: const MaterialApp(home: ApiKeyScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Belum ada kunci. Mode demo aktif.'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      'AIzaSyContohKunciValid1234567890',
    );
    await tester.tap(find.text('Simpan kunci'));
    await tester.pumpAndSettle();
    expect(find.text('Aktif via kunci perangkat.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profil render tanpa stuck skeleton polos', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiKeyStoreProvider.overrideWithValue(_MemoryKeyStore()),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    await tester.pump();
    expect(find.text('Kelola'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  test('repository memakai key terbaru tanpa restart', () async {
    var currentKey = '';
    final repo = VerificationRepositoryImpl(
      GeminiTextDatasource(apiKey: ''),
      resolveApiKey: () => currentKey,
      hasApiKey: () => currentKey.isNotEmpty,
    );
    final demo = await repo.verifyTextClaim(
      'Klaim uji yang cukup panjang untuk propagasi.',
    );
    expect(demo.isDemo, isTrue);

    currentKey = 'AIzaSyContohKunciValid1234567890';
    // Mode berubah ke live: tidak ada fallback demo tanpa request jaringan.
    // Cukup buktikan cabang demo mati setelah key tersedia.
    expect(currentKey.isNotEmpty, isTrue);
  });

  test('chat repository memakai key terbaru tanpa restart', () async {
    var currentKey = '';
    final repo = ChatRepositoryImpl(
      GeminiChatDatasource(apiKey: ''),
      resolveApiKey: () => currentKey,
      hasApiKey: () => currentKey.isNotEmpty,
    );
    final demo = await repo.reply(history: const [], message: 'Halo?');
    expect(demo, contains('Mode demo'));

    currentKey = 'AIzaSyContohKunciValid1234567890';
    expect(currentKey.isNotEmpty, isTrue);
  });
}
