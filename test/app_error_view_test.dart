import 'dart:async';

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app.dart';

Future<void> _pumpError(
  WidgetTester tester, {
  FutureOr<void> Function()? onRetry,
  void Function(Object, StackTrace)? onRetryError,
}) => pumpInApp(
  tester,
  AppErrorView(
    message: 'Could not load',
    retryLabel: 'Try again',
    onRetry: onRetry,
    onRetryError: onRetryError,
  ),
);

bool _isSpinning(WidgetTester tester) =>
    tester.widget<RefreshButton>(find.byType(RefreshButton)).isLoading;

void main() {
  testWidgets('without a retry there is no button', (tester) async {
    await _pumpError(tester);

    expect(find.text('Could not load'), findsOneWidget);
    expect(find.byType(RefreshButton), findsNothing);
  });

  testWidgets('shows the given label', (tester) async {
    await _pumpError(tester, onRetry: () {});

    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('the icon spins until the retry settles', (tester) async {
    final retry = Completer<void>();

    await _pumpError(tester, onRetry: () => retry.future);

    expect(_isSpinning(tester), isFalse);

    await tester.tap(find.byType(RefreshButton));
    await tester.pump();

    expect(_isSpinning(tester), isTrue);

    retry.complete();
    await tester.pumpAndSettle();

    expect(_isSpinning(tester), isFalse);
  });

  testWidgets('a retry that throws ends the spin and reports the error', (
    tester,
  ) async {
    final errors = <Object>[];

    await _pumpError(
      tester,
      onRetry: () async => throw StateError('offline'),
      onRetryError: (error, _) => errors.add(error),
    );

    await tester.tap(find.byType(RefreshButton));
    await tester.pumpAndSettle();

    expect(_isSpinning(tester), isFalse);
    expect(errors.single, isA<StateError>());
  });

  testWidgets('a retry that throws is safe without an error callback', (
    tester,
  ) async {
    await _pumpError(tester, onRetry: () async => throw StateError('offline'));

    await tester.tap(find.byType(RefreshButton));
    await tester.pumpAndSettle();

    expect(_isSpinning(tester), isFalse);
    expect(tester.takeException(), isNull);
  });
}
