// How a toast comes down: on its own after [duration], on a close tap, on an
// action tap, or when the app dismisses it through the returned controller.

import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps a host with a real [Overlay] (via [MaterialApp]) and hands back the
/// context a caller would use to raise a toast.
Future<BuildContext> pumpHost(WidgetTester tester) async {
  late BuildContext hostContext;
  await tester.pumpWidget(
    MaterialApp(
      theme: BitcrTheme.light,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            hostContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
  return hostContext;
}

void main() {
  group('auto-dismiss', () {
    testWidgets('a plain toast goes away after its duration', (tester) async {
      final context = await pumpHost(tester);

      showToast(context, message: 'Payment sent');
      await tester.pump();
      expect(find.text('Payment sent'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(find.text('Payment sent'), findsNothing);
    });

    testWidgets('a toast with a close button never auto-dismisses', (
      tester,
    ) async {
      final context = await pumpHost(tester);

      showToast(
        context,
        message: 'Recovery phrase saved',
        showCloseButton: true,
      );
      await tester.pump();

      // Well past the default duration, it is still there.
      await tester.pump(const Duration(seconds: 30));
      expect(find.text('Recovery phrase saved'), findsOneWidget);
    });

    testWidgets('tapping close takes it down', (tester) async {
      final context = await pumpHost(tester);

      showToast(context, message: 'Heads up', showCloseButton: true);
      await tester.pump();

      await tester.tap(find.byIcon(LucideIcons.x));
      await tester.pump();
      expect(find.text('Heads up'), findsNothing);
    });
  });

  group('the controller', () {
    testWidgets('dismisses a pending toast before its duration', (
      tester,
    ) async {
      final context = await pumpHost(tester);

      final controller = showToast(
        context,
        message: 'Checking payment…',
        duration: const Duration(seconds: 30),
      )!;
      await tester.pump();
      expect(find.text('Checking payment…'), findsOneWidget);
      expect(controller.isDismissed, isFalse);

      controller.dismiss();
      await tester.pump();
      expect(find.text('Checking payment…'), findsNothing);
      expect(controller.isDismissed, isTrue);
    });

    testWidgets('dismiss is safe to call twice, and after auto-dismiss', (
      tester,
    ) async {
      final context = await pumpHost(tester);

      final controller = showToast(context, message: 'Done')!;
      await tester.pump();

      controller.dismiss();
      await tester.pump();
      // The second call must not try to remove an entry that is already gone.
      expect(controller.dismiss, returnsNormally);

      // And the auto-dismiss timer firing afterwards must not either.
      await tester.pump(const Duration(seconds: 5));
      expect(tester.takeException(), isNull);
    });

    testWidgets('returns null when there is no overlay to insert into', (
      tester,
    ) async {
      late BuildContext bare;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            bare = context;
            return const SizedBox.shrink();
          },
        ),
      );

      expect(showToast(bare, message: 'nowhere to go'), isNull);
    });
  });

  group('the action', () {
    testWidgets('runs its callback and dismisses the toast', (tester) async {
      final context = await pumpHost(tester);
      var undone = false;

      showToast(
        context,
        message: 'Contact deleted',
        duration: const Duration(seconds: 30),
        action: ToastAction(label: 'Undo', onPressed: () => undone = true),
      );
      await tester.pump();

      await tester.tap(find.text('Undo'));
      await tester.pump();

      expect(undone, isTrue);
      expect(find.text('Contact deleted'), findsNothing);
    });
  });

  group('the card', () {
    testWidgets('renders the description as a second line', (tester) async {
      final context = await pumpHost(tester);

      showToast(
        context,
        message: 'Payment failed',
        variant: ToastVariant.error,
        description: 'Your funds are untouched.',
      );
      await tester.pump();

      expect(find.text('Payment failed'), findsOneWidget);
      expect(find.text('Your funds are untouched.'), findsOneWidget);

      // Let the auto-dismiss timer run out, so it is not still pending when
      // the tree is torn down.
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('each variant draws its own icon', (tester) async {
      const expected = {
        ToastVariant.info: LucideIcons.info300,
        ToastVariant.success: LucideIcons.circleCheck300,
        ToastVariant.warning: LucideIcons.triangleAlert300,
        ToastVariant.error: LucideIcons.circleX300,
      };

      for (final entry in expected.entries) {
        await tester.pumpWidget(
          MaterialApp(
            theme: BitcrTheme.light,
            home: Scaffold(
              body: Toast(message: 'x', variant: entry.key),
            ),
          ),
        );
        expect(
          find.byIcon(entry.value),
          findsOneWidget,
          reason: 'variant ${entry.key.name}',
        );
      }
    });

    testWidgets('shows no close button when onClose is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Toast(message: 'no close')),
        ),
      );

      expect(find.byIcon(LucideIcons.x), findsNothing);
    });
  });
}
