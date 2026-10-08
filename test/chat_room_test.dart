import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/constants/app_strings.dart';
import 'package:literasi_ai/features/chat/data/datasources/chat_session_local_datasource.dart';
import 'package:literasi_ai/features/chat/domain/entities/chat_message.dart';
import 'package:literasi_ai/features/chat/domain/repositories/chat_repository.dart';
import 'package:literasi_ai/features/chat/presentation/providers/chat_providers.dart';
import 'package:literasi_ai/features/chat/presentation/screens/chat_screen.dart';
import 'package:literasi_ai/features/chat/presentation/widgets/chat_rich_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regresi chatroom profesional: rich-text aman, salin/tulis ulang,
/// hentikan jawaban, pemisah tanggal, dan arsip percakapan terakhir.
class _FakeChatRepository implements ChatRepository {
  _FakeChatRepository({this.delay});

  static const String answer = 'Jawaban uji AI.';
  final Duration? delay;
  int calls = 0;
  String lastMessage = '';

  @override
  Future<String> reply({
    required List<ChatMessage> history,
    required String message,
  }) async {
    calls++;
    lastMessage = message;
    final wait = delay;
    if (wait != null) await Future<void>.delayed(wait);
    return '$answer #$calls';
  }
}

void main() {
  group('Parser rich text jawaban AI', () {
    test('judul ## menjadi blok heading', () {
      final blocks = ChatRichTextParser.parse('## Cara Cek Hoaks');
      expect(blocks, hasLength(1));
      expect(blocks.first.heading, isTrue);
      expect(blocks.first.spans.first.text, 'Cara Cek Hoaks');
    });

    test('penekanan ** jadi bold tanpa marker mentah', () {
      final blocks = ChatRichTextParser.parse(
        'Cek **sumber resmi** sebelumPremier Applicable Sebarkan.',
      );
      final bold = blocks.first.spans.where((s) => s.bold);
      expect(bold, hasLength(1));
      expect(bold.first.text, 'sumber resmi');
      expect(
        blocks.first.spans.map((s) => s.text).join(),
        isNot(contains('*')),
      );
    });

    test('marker bintang ganjil tidak tampil mentah', () {
      final blocks = ChatRichTextParser.parse(
        'ai sometimes output ** bold seperti ini',
      );
      expect(
        blocks.first.spans.map((s) => s.text).join(),
        isNot(contains('**')),
      );
    });

    test('daftar -, *, dan 1. menjadi baris bertanda', () {
      final bullet = ChatRichTextParser.parse('- satu\n- dua');
      expect(bullet, hasLength(2));
      expect(bullet.first.bullet, '•');
      final star = ChatRichTextParser.parse('* satu');
      expect(star.first.bullet, '•');
      final ordered = ChatRichTextParser.parse('1. pertama');
      expect(ordered.first.bullet, '1.');
    });

    test('blok kosong aman dirender satu placeholder', () {
      expect(ChatRichTextParser.parse('   \n  '), hasLength(1));
      expect(ChatRichTextParser.parse(''), hasLength(1));
    });
  });

  group('ChatController: tulis ulang, hentikan, arsip', () {
    test('regenerate memakai seed yang sama dan mengganti teks', () async {
      final repo = _FakeChatRepository();
      final container = ProviderContainer(
        overrides: [chatRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      final notifier = container.read(chatControllerProvider.notifier);

      await notifier.send('Kenapa hoaks menyebar?');
      final before = container.read(chatControllerProvider).messages.last.text;
      await notifier.regenerate(
        container.read(chatControllerProvider).messages.last.id,
      );
      final after = container.read(chatControllerProvider);

      expect(repo.calls, 2);
      expect(repo.lastMessage, 'Kenapa hoaks menyebar?');
      expect(after.messages, hasLength(2));
      expect(after.messages.last.text, isNot(before));
      expect(after.messages.last.isFailed, isFalse);
    });

    test('stop membatalkan jawaban dan mengosongkan bubble mengetik', () async {
      final repo = _FakeChatRepository(delay: const Duration(seconds: 1));
      final container = ProviderContainer(
        overrides: [chatRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      final notifier = container.read(chatControllerProvider.notifier);

      final pending = notifier.send('Pertanyaan panjang untuk dihentikan.');
      await Future<void>.delayed(const Duration(milliseconds: 30));
      notifier.stop();

      final state = container.read(chatControllerProvider);
      expect(state.sending, isFalse);
      expect(
        state.messages.any((m) => m.role == ChatRole.ai && m.text.isEmpty),
        isFalse,
      );
      expect(state.messages.first.text, 'Pertanyaan panjang untuk dihentikan.');
      await pending;
    });

    test('clear mengarsipkan sesi lalu mengosongkan layar', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final repo = _FakeChatRepository();
      final container = ProviderContainer(
        overrides: [chatRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      final notifier = container.read(chatControllerProvider.notifier);

      await notifier.send('Tanya pertama untuk arsip.');
      notifier.clear();
      expect(container.read(chatControllerProvider).messages, isEmpty);

      final archive = await notifier.loadArchive();
      expect(archive, isNotNull);
      expect(archive!.messages.first.text, 'Tanya pertama untuk arsip.');
      expect(archive.messages.length, 2);

      notifier.restoreArchive(archive);
      expect(container.read(chatControllerProvider).messages, hasLength(2));

      await notifier.clearArchive();
      expect(await notifier.loadArchive(), isNull);
    });

    test('arsip korub dibaca sebagai null, bukan crash', () {
      expect(ChatSessionArchive.decode('bukan json'), isNull);
      expect(ChatSessionArchive.decode(null), isNull);
      expect(
        ChatSessionArchive.decode('{"savedAt":"x","messages":[]}'),
        isNull,
      );
    });
  });

  testWidgets('bar aksi AI: salin jawaban dan tulis ulang', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatRepositoryProvider.overrideWithValue(_FakeChatRepository()),
        ],
        child: const MaterialApp(home: ChatScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Apakah vaksin menyebabkan autisme?'));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.chatCopy), findsOneWidget);
    expect(find.text(AppStrings.chatRegenerate), findsOneWidget);

    await tester.tap(find.text(AppStrings.chatCopy));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(copied, contains('Jawaban uji AI.'));
    expect(find.text(AppStrings.chatCopied), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('jawaban AI merender heading dan daftar tanpa asterisk', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ChatRichText(
            text: '## Cek tiga hal\n- **Sumber** resmi\n- Tanggal terbit',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('##'), findsNothing);
    expect(find.textContaining('*'), findsNothing);
    expect(find.text('Cek tiga hal'), findsOneWidget);
    expect(find.textContaining('Sumber'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pemisah tanggal tampil di awal percakapan', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatRepositoryProvider.overrideWithValue(_FakeChatRepository()),
        ],
        child: const MaterialApp(home: ChatScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final suggestion = find.text('Cara verifikasi sumber berita?');
    await tester.ensureVisible(suggestion);
    await tester.pumpAndSettle();
    await tester.tap(suggestion);
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.chatToday), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tombol riwayat membuka arsip lalu bisa melanjutkan', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatRepositoryProvider.overrideWithValue(_FakeChatRepository()),
        ],
        child: const MaterialApp(home: ChatScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Belum ada arsip: toast jujur, bukan layar kosong.
    await tester.tap(find.byTooltip(AppStrings.chatHistoryTooltip));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(AppStrings.chatHistoryEmpty), findsOneWidget);

    // Buat percakapan lewat UI, lalu "Mulai baru" mengarsipkan sesi.
    final suggestion = find.text('Cara kenali judul clickbait?');
    await tester.ensureVisible(suggestion);
    await tester.pumpAndSettle();
    await tester.tap(suggestion);
    await tester.pumpAndSettle();
    expect(find.text('Jawaban uji AI. #1'), findsOneWidget);

    await tester.tap(find.byTooltip(AppStrings.chatClear));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.chatClear).last);
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.chatGreetingTitle), findsOneWidget);

    // Arsip tersedia lagi lewat tombol riwayat.
    await tester.tap(find.byTooltip(AppStrings.chatHistoryTooltip));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.chatHistoryTitle), findsOneWidget);
    // Pratinjau di dalam sheet (chip sapaan di belakang juga memuat teks ini).
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.textContaining('Cara kenali judul clickbait?'),
      ),
      findsOneWidget,
      reason: 'pratinjau arsip menampilkan pertanyaan pertama',
    );

    await tester.tap(find.text(AppStrings.chatHistoryContinue));
    await tester.pumpAndSettle();
    // Sheet tertutup dan percakapan lama kembali ke layar.
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('Jawaban uji AI. #1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tombol kirim berubah jadi hentikan saat AI menjawab', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatRepositoryProvider.overrideWithValue(
            _FakeChatRepository(delay: const Duration(seconds: 1)),
          ),
        ],
        child: const MaterialApp(home: ChatScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final suggestion = find.text('Cara kenali judul clickbait?');
    await tester.ensureVisible(suggestion);
    await tester.pumpAndSettle();
    await tester.tap(suggestion);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 30));

    expect(find.byTooltip(AppStrings.chatStop), findsOneWidget);
    await tester.tap(find.byTooltip(AppStrings.chatStop));
    // Majukan clock melewati reply yang masih jalan agar tidak ada timer
    // tertinggal saat widget dibongkar.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byTooltip(AppStrings.chatStop), findsNothing);
    expect(
      find.text('Cara kenali judul clickbait?'),
      findsOneWidget,
      reason: 'pesan user tetap ada setelah dihentikan',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('dense 360px: bubble + aksi tanpa overflow', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatRepositoryProvider.overrideWithValue(
            _FakeChatRepository(delay: const Duration(milliseconds: 200)),
          ),
        ],
        child: const MaterialApp(home: ChatScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final suggestion = find.text('Cara verifikasi sumber berita?');
    await tester.ensureVisible(suggestion);
    await tester.pumpAndSettle();
    await tester.tap(suggestion);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.chatCopy), findsOneWidget);
    expect(find.text(AppStrings.chatRegenerate), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
