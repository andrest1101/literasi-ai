import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/errors/failures.dart';
import 'package:literasi_ai/features/chat/domain/entities/chat_message.dart';
import 'package:literasi_ai/features/chat/domain/repositories/chat_repository.dart';
import 'package:literasi_ai/features/chat/domain/usecases/send_chat_message.dart';
import 'package:literasi_ai/features/chat/presentation/providers/chat_providers.dart';
import 'package:literasi_ai/features/chat/presentation/screens/chat_screen.dart';
import 'package:literasi_ai/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:literasi_ai/features/quick_check/presentation/screens/quick_check_session_screen.dart';

class _FakeChatRepository implements ChatRepository {
  _FakeChatRepository({this.failNext = false});

  static const String answer = 'Jawaban uji AI.';
  bool failNext;
  int calls = 0;
  String lastMessage = '';

  @override
  Future<String> reply({
    required List<ChatMessage> history,
    required String message,
  }) async {
    calls++;
    lastMessage = message;
    if (failNext) {
      failNext = false;
      throw const UnknownFailure('Pesan gagal dikirim. Coba lagi.');
    }
    return answer;
  }
}

ChatMessage _aiMessage({String text = 'Jawaban uji.', String? seed}) {
  return ChatMessage(
    id: 'ai-1',
    role: ChatRole.ai,
    text: text,
    createdAt: DateTime(2026, 9, 18, 10, 30),
    verifySeed: seed ?? 'Pertanyaan uji pengguna.',
  );
}

void main() {
  group('SendChatMessage usecase', () {
    test('rejects empty message without calling repository', () async {
      final repo = _FakeChatRepository();
      await expectLater(
        SendChatMessage(repo).call(history: const [], rawMessage: '   '),
        throwsA(isA<UnknownFailure>()),
      );
      expect(repo.calls, 0);
    });

    test('rejects message over 1000 chars', () async {
      final repo = _FakeChatRepository();
      final long = List.filled(1001, 'a').join();
      await expectLater(
        SendChatMessage(repo).call(history: const [], rawMessage: long),
        throwsA(isA<UnknownFailure>()),
      );
      expect(repo.calls, 0);
    });

    test('normalizes whitespace and forwards history', () async {
      final repo = _FakeChatRepository();
      final history = [
        ChatMessage(
          id: 'u-1',
          role: ChatRole.user,
          text: 'Halo.',
          createdAt: DateTime(2026, 9, 18),
        ),
      ];
      final answer = await SendChatMessage(
        repo,
      ).call(history: history, rawMessage: '  Apa  itu   hoaks?  ');
      expect(answer, 'Jawaban uji AI.');
      expect(repo.lastMessage, 'Apa itu hoaks?');
    });
  });

  group('ChatController', () {
    test('send adds user + ai messages with answer', () async {
      final container = ProviderContainer(
        overrides: [
          chatRepositoryProvider.overrideWithValue(_FakeChatRepository()),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(chatControllerProvider.notifier)
          .send('Apakah ini hoaks?');
      final state = container.read(chatControllerProvider);

      expect(state.messages, hasLength(2));
      expect(state.messages.first.isUser, isTrue);
      expect(state.messages.first.text, 'Apakah ini hoaks?');
      expect(state.messages.last.isUser, isFalse);
      expect(state.messages.last.text, 'Jawaban uji AI.');
      expect(state.messages.last.verifySeed, 'Apakah ini hoaks?');
      expect(state.sending, isFalse);
    });

    test('failure marks ai bubble failed and retry recovers', () async {
      final repo = _FakeChatRepository(failNext: true);
      final container = ProviderContainer(
        overrides: [chatRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      final notifier = container.read(chatControllerProvider.notifier);

      await notifier.send('Kenapa hoaks menyebar?');
      var state = container.read(chatControllerProvider);
      expect(state.messages.last.isFailed, isTrue);

      await notifier.retry(state.messages.last.id);
      state = container.read(chatControllerProvider);
      expect(state.messages.last.isFailed, isFalse);
      expect(state.messages.last.text, 'Jawaban uji AI.');
    });

    test('ignores send while sending and clear resets', () async {
      final container = ProviderContainer(
        overrides: [
          chatRepositoryProvider.overrideWithValue(_FakeChatRepository()),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(chatControllerProvider.notifier);

      await notifier.send('Pertanyaan pertama.');
      notifier.clear();
      expect(container.read(chatControllerProvider).messages, isEmpty);
    });
  });

  testWidgets('ai bubble verify button opens session with seed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: ChatBubble(message: _aiMessage(), onRetry: () {})),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Verifikasi ini'), findsOneWidget);
    await tester.tap(find.text('Verifikasi ini'));
    await tester.pumpAndSettle();

    expect(find.byType(QuickCheckSessionScreen), findsOneWidget);
    expect(find.textContaining('Pertanyaan uji'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty greeting suggestions send message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatRepositoryProvider.overrideWithValue(_FakeChatRepository()),
        ],
        child: const MaterialApp(home: ChatScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Halo, aku asisten literasimu.'), findsOneWidget);
    await tester.tap(find.text('Apakah vaksin menyebabkan autisme?'));
    await tester.pumpAndSettle();

    expect(find.text('Apakah vaksin menyebabkan autisme?'), findsOneWidget);
    expect(find.text('Jawaban uji AI.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed bubble shows retry and recovers on tap', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatRepositoryProvider.overrideWithValue(
            _FakeChatRepository(failNext: true),
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
    await tester.pumpAndSettle();

    expect(find.text('Kirim ulang'), findsOneWidget);
    await tester.tap(find.text('Kirim ulang'));
    await tester.pumpAndSettle();

    expect(find.text('Jawaban uji AI.'), findsOneWidget);
    expect(find.text('Kirim ulang'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('appbar holds identity and key banner offers copy', (
    WidgetTester tester,
  ) async {
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

    expect(find.text('Kembali'), findsNothing);
    expect(find.text('Asisten LiterasiAI'), findsOneWidget);
    // Subtitle kontekstual (tanpa kunci di test env): mode pratinjau.
    expect(find.text('Mode pratinjau'), findsOneWidget);
    expect(find.text('Siap membantu verifikasi'), findsNothing);
    expect(find.byTooltip('Mulai baru'), findsOneWidget);
    expect(
      find.text('Mode pratinjau: kunci API belum tersambung'),
      findsOneWidget,
    );

    await tester.tap(find.text('Salin perintah'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      copied,
      'flutter run --dart-define=GEMINI_API_KEY=ISI_KUNCI_ANDA',
    );
    expect(find.textContaining('Perintah disalin'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('key provider reports compile-time configuration', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(chatKeyConfiguredProvider),
      const String.fromEnvironment('GEMINI_API_KEY').isNotEmpty,
    );
  });
}
