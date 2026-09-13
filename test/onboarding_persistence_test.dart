import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:literasi_ai/features/auth/data/datasources/onboarding_local_datasource.dart';
import 'package:literasi_ai/features/auth/domain/repositories/onboarding_repository.dart';
import 'package:literasi_ai/features/auth/presentation/providers/onboarding_provider.dart';
import 'package:literasi_ai/features/auth/presentation/screens/auth_screen.dart';
import 'package:literasi_ai/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:literasi_ai/main.dart';

class _FakeOnboardingRepository implements OnboardingRepository {
  _FakeOnboardingRepository({this.completed = false});

  bool completed;

  @override
  Future<bool> isCompleted() async => completed;

  @override
  Future<void> markCompleted() async {
    completed = true;
  }
}

void main() {
  test('datasource persists onboarding completion locally', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final datasource = OnboardingLocalDatasource(prefs);

    expect(datasource.isCompleted(), isFalse);
    await datasource.markCompleted();
    expect(datasource.isCompleted(), isTrue);
  });

  test('controller exposes completion and can complete it', () async {
    final container = ProviderContainer(
      overrides: [
        onboardingRepositoryProvider.overrideWith(
          (ref) => _FakeOnboardingRepository(completed: false),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(await container.read(onboardingControllerProvider.future), isFalse);
    await container.read(onboardingControllerProvider.notifier).complete();
    expect(await container.read(onboardingControllerProvider.future), isTrue);
  });

  testWidgets('splash goes to onboarding when flag is missing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWith(
            (ref) => _FakeOnboardingRepository(completed: false),
          ),
        ],
        child: const LiterasiAIApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Cek Hoaks Instan dengan AI'), findsOneWidget);
  });

  testWidgets('splash skips onboarding when flag is completed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWith(
            (ref) => _FakeOnboardingRepository(completed: true),
          ),
        ],
        child: const LiterasiAIApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Masuk ke LiterasiAI'), findsOneWidget);
    expect(find.text('Cek Hoaks Instan dengan AI'), findsNothing);
  });

  testWidgets('skipping onboarding persists completion', (
    WidgetTester tester,
  ) async {
    final repository = _FakeOnboardingRepository(completed: false);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWith((ref) => repository),
        ],
        child: MaterialApp(
          home: const OnboardingScreen(),
          routes: {AuthScreen.route: (_) => const AuthScreen()},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();

    expect(repository.completed, isTrue);
    expect(find.text('Masuk ke LiterasiAI'), findsOneWidget);
  });
}
