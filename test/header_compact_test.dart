import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:literasi_ai/core/utils/api_key_resolver.dart';
import 'package:literasi_ai/core/utils/api_key_store.dart';
import 'package:literasi_ai/features/history/presentation/providers/history_providers.dart';
import 'package:literasi_ai/features/score/domain/entities/literacy_score.dart';
import 'package:literasi_ai/features/score/domain/repositories/score_repository.dart';
import 'package:literasi_ai/features/score/presentation/providers/score_providers.dart';
import 'package:literasi_ai/features/score/presentation/widgets/score_check_chip.dart';

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

class _FixedScoreRepository implements ScoreRepository {
  @override
  Stream<LiteracyScore> watch(String userId) =>
      Stream.value(const LiteracyScore());

  @override
  Future<void> awardVerification(String userId) async {}

  @override
  Future<void> awardModule(String userId, String moduleId) async {}

  @override
  Future<void> awardQuiz(String userId, {required bool correct}) async {}
}

/// Regresi U2: header status compact tab Cek.
///
/// Dua pil full-width (skor + status kunci) digabung satu baris: ring
/// progres level + label/poin di kiri, dot status AI di kanan, dengan
/// divider pemisah dan dua zona tap terpisah (Profil vs Pengaturan).
void main() {
  /// Pump dengan kunci kosong (mode demo) + skor lokal nol — tanpa
  /// Firebase maupun secure storage asli.
  Future<void> pumpChip(WidgetTester tester, {Widget? child}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiKeyStoreProvider.overrideWithValue(_MemoryKeyStore()),
          historyUserIdProvider.overrideWithValue(null),
          scoreRepositoryProvider.overrideWithValue(
            _FixedScoreRepository(),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: child ?? const ScoreCheckChip()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Header compact U2 — satu baris skor + status AI', () {
    testWidgets('ring progres + label level + poin tampil', (
      WidgetTester tester,
    ) async {
      await pumpChip(tester);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Guest jujur: Pemula, 0 poin, sisa 50 ke Waspada.
      expect(find.text('Pemula'), findsOneWidget);
      expect(find.textContaining('0 poin'), findsOneWidget);
      expect(find.textContaining('Waspada'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dot status demo tampil saat tanpa kunci', (
      WidgetTester tester,
    ) async {
      await pumpChip(tester);
      expect(find.text('Demo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tap zona skor dan zona kunci memicu callback sendiri', (
      WidgetTester tester,
    ) async {
      var profileTaps = 0;
      var keyTaps = 0;
      await pumpChip(
        tester,
        child: ScoreCheckChip(
          onOpenProfile: () => profileTaps++,
          onOpenKeySettings: () => keyTaps++,
        ),
      );

      await tester.tap(find.text('Demo'));
      await tester.pumpAndSettle();
      expect(keyTaps, 1);
      expect(profileTaps, 0);

      await tester.tap(find.text('Pemula'));
      await tester.pumpAndSettle();
      expect(profileTaps, 1);
      expect(keyTaps, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tidak ada teks header lama yang bertumpuk', (
      WidgetTester tester,
    ) async {
      await pumpChip(tester);
      expect(find.text('Status AI'), findsNothing);
      expect(find.text('Pemula - 0 poin'), findsNothing);
      expect(find.text('Mode demo aktif'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
