import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// A page inside the demo's own [Navigator], deep enough to push and pop.
class _DemoPage extends StatelessWidget {
  const _DemoPage({required this.depth});

  final int depth;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return Scaffold(
      // Opaque, or the page behind shows through and the zoom-out is invisible.
      backgroundColor: depth.isEven ? colors.elevation50 : colors.elevation100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 24,
            children: [
              Topbar(
                lead: depth == 0
                    ? null
                    : NavigateBackButton(
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                middle: Text(
                  'Page $depth',
                  style: context.bitcrText.textMdMedium(),
                ),
              ),
              Text(
                depth == 0
                    ? 'Push a page to watch it slide in while this one zooms '
                          'out to $kPageScaleFactor×.'
                    : 'Swipe from the left edge to go back, or use the button.',
                style: context.bitcrText.textSmRegular(
                  color: colors.text200,
                ),
              ),
              Button(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _DemoPage(depth: depth + 1),
                  ),
                ),
                child: const Text('Push a page'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The transition [BitcrTheme] installs for every platform: a slide in from the
/// trailing edge, the page behind zooming out to [kPageScaleFactor], and a
/// 20px edge swipe-back.
///
/// This runs in its own nested [Navigator], so pushing here doesn't navigate
/// the catalog. Swipe-back needs a route that isn't the first, so it only works
/// from page 1 onwards.
@widgetbook.UseCase(name: 'Push and pop', type: BitcrPageTransitionsBuilder)
Widget pageTransitionsPushPop(BuildContext context) => ClipRect(
  child: Navigator(
    onGenerateRoute: (_) => MaterialPageRoute<void>(
      builder: (_) => const _DemoPage(depth: 0),
    ),
  ),
);

/// The warm-up renders one invisible cycle of the transition after the first
/// frame, so the engine compiles those GPU pipelines before the user's first
/// real navigation. At 1% opacity there's nothing to see — this use case only
/// confirms it completes and calls back.
@widgetbook.UseCase(name: 'Completes silently', type: TransitionWarmUp)
Widget transitionWarmUpDemo(BuildContext context) => const _WarmUpHarness();

class _WarmUpHarness extends StatefulWidget {
  const _WarmUpHarness();

  @override
  State<_WarmUpHarness> createState() => _WarmUpHarnessState();
}

class _WarmUpHarnessState extends State<_WarmUpHarness> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Text(
            _done ? 'warm-up complete' : 'warming up…',
            style: context.bitcrText.textMdMedium(),
          ),
        ),
        if (!_done)
          TransitionWarmUp(onComplete: () => setState(() => _done = true)),
      ],
    );
  }
}
