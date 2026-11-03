import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/features/auth/presentation/screens/auth_screen.dart';
import 'package:literasi_ai/features/chat/domain/entities/chat_message.dart';
import 'package:literasi_ai/features/chat/domain/repositories/chat_repository.dart';
import 'package:literasi_ai/features/chat/presentation/providers/chat_providers.dart';
import 'package:literasi_ai/features/chat/presentation/screens/chat_screen.dart';
import 'package:literasi_ai/features/quick_check/presentation/screens/quick_check_home_tab.dart';
import 'package:literasi_ai/features/quick_check/presentation/screens/quick_check_session_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeChatRepository implements ChatRepository {
  @override
  Future<String> reply({
    required List<ChatMessage> history,
    required String message,
  }) async => 'Jawaban uji.';
}

void main() {
  Future<void> pumpAt(
    WidgetTester tester,
    Widget child, {
    required Size size,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: Scaffold(body: child)),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets('Quick Check landing tidak overflow di layar kecil', (
    tester,
  ) async {
    await pumpAt(
      tester,
      QuickCheckHomeTab(onOpenProfile: () {}),
      size: const Size(320, 568),
    );
  });

  testWidgets('Quick Check session gambar tidak overflow di layar kecil', (
    tester,
  ) async {
    await pumpAt(
      tester,
      const QuickCheckSessionScreen(initialMode: QuickCheckInitialMode.image),
      size: const Size(320, 568),
    );
  });

  testWidgets('Quick Check session URL tidak overflow di layar kecil', (
    tester,
  ) async {
    await pumpAt(
      tester,
      const QuickCheckSessionScreen(
        initialMode: QuickCheckInitialMode.url,
        initialUrl: 'https://contoh.id/berita-penting',
      ),
      size: const Size(320, 568),
    );
  });

  testWidgets('AuthScreen tidak overflow di layar kecil', (tester) async {
    await pumpAt(tester, const AuthScreen(), size: const Size(320, 568));
  });

  testWidgets('ChatScreen tidak overflow di layar kecil', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await pumpAt(
      tester,
      ProviderScope(
        overrides: [
          chatRepositoryProvider.overrideWithValue(_FakeChatRepository()),
        ],
        child: const ChatScreen(),
      ),
      size: const Size(320, 568),
    );
  });
}
