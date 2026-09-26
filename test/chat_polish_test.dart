import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/utils/api_key_resolver.dart';
import 'package:literasi_ai/core/utils/api_key_store.dart';
import 'package:literasi_ai/features/chat/domain/entities/chat_message.dart';
import 'package:literasi_ai/features/chat/domain/repositories/chat_repository.dart';
import 'package:literasi_ai/features/chat/presentation/providers/chat_providers.dart';
import 'package:literasi_ai/features/chat/presentation/screens/chat_screen.dart';

/// Regresi polish chat C1-C4 + header tanpa avatar: subtitle kontekstual
/// jujur, disclaimer compact, hero 80px, AppBar panah polos 24px tanpa
/// shield (identitas milik bubble AI + hero empty-state).
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

class _FakeChatRepository implements ChatRepository {
  @override
  Future<String> reply({
    required List<ChatMessage> history,
    required String message,
  }) async =>
      'Jawaban uji.';
}

Future<void> _pumpChat(
  WidgetTester tester, {
  String? storedKey,
  List<Override> extra = const [],
}) async {
  final store = _MemoryKeyStore()..value = storedKey;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        apiKeyStoreProvider.overrideWithValue(store),
        chatRepositoryProvider.overrideWithValue(_FakeChatRepository()),
        ...extra,
      ],
      child: const MaterialApp(home: ChatScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

/// Container terdekat di atas ikon: pembungkus avatar gradien.
Finder _avatarBoxOf(WidgetTester tester, IconData icon) {
  Element? current = tester.element(find.byIcon(icon));
  while (current != null) {
    Element? parent;
    current.visitAncestorElements((e) {
      parent = e;
      return false;
    });
    if (parent?.widget is Container) {
      return find.byWidget(parent!.widget as Container);
    }
    current = parent;
  }
  throw StateError('Pembungkus avatar untuk $icon tidak ditemukan');
}

void main() {
  group('Subtitle kontekstual C1 (jujur, tanpa dot palsu)', () {
    testWidgets('tanpa kunci: Mode pratinjau', (tester) async {
      await _pumpChat(tester);
      expect(find.text('Asisten LiterasiAI'), findsOneWidget);
      expect(find.text('Mode pratinjau'), findsOneWidget);
      expect(find.text('AI live · Siap menjawab'), findsNothing);
      expect(find.text('Siap membantu verifikasi'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dengan kunci: AI live Siap menjawab', (tester) async {
      await _pumpChat(
        tester,
        storedKey: 'AIzaSyUjiKunciValidUntukTest1234567890',
      );
      expect(find.text('AI live · Siap menjawab'), findsOneWidget);
      expect(find.text('Mode pratinjau'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('Disclaimer compact C2', () {
    testWidgets('tampil di empty state', (tester) async {
      await _pumpChat(tester);
      expect(
        find.text(
          'Didukung Gemini AI · Jawaban bisa keliru, cek ulang info penting.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('Hero C3 + AppBar C4', () {
    testWidgets('avatar hero 80px dan CTA tetap buka sesi kirim', (
      tester,
    ) async {
      await _pumpChat(tester);
      expect(
        tester.getSize(
          _avatarBoxOf(tester, Icons.auto_awesome_rounded),
        ),
        const Size(80, 80),
      );
      expect(find.text('Halo, aku asisten literasimu.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AppBar back lingkaran + tanpa avatar header', (
      tester,
    ) async {
      await _pumpChat(tester);
      // Tombol kembali lingkaran tonal 40px (jarak napas ke teks),
      // dan shield TIDAK ada di AppBar: identitas milik bubble AI +
      // hero empty-state.
      expect(find.byTooltip('Kembali ke Beranda'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.verified_user_rounded),
        ),
        findsNothing,
      );
      expect(find.text('Asisten LiterasiAI'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('bubble AI tetap membawa avatar shield', (tester) async {
      await _pumpChat(tester);
      await tester.tap(find.text('Apakah vaksin menyebabkan autisme?'));
      await tester.pumpAndSettle();
      // Avatar shield muncul di daftar pesan (bubble AI), bukan di AppBar.
      expect(find.byIcon(Icons.verified_user_rounded), findsWidgets);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.verified_user_rounded),
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('hero render penuh di 360×800 tanpa overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await _pumpChat(tester);
      expect(find.text('Halo, aku asisten literasimu.'), findsOneWidget);
      expect(
        find.text('Apakah vaksin menyebabkan autisme?'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
