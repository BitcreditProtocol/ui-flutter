import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Stands in for the app's own fetch: a refresh that takes a moment and then
/// reports that it happened, so the spinner's full cycle is visible.
class _RefreshHarness extends StatefulWidget {
  const _RefreshHarness({
    required this.childScrolls,
    this.delay = const Duration(seconds: 1),
  });

  final bool childScrolls;
  final Duration delay;

  @override
  State<_RefreshHarness> createState() => _RefreshHarnessState();
}

class _RefreshHarnessState extends State<_RefreshHarness> {
  int _refreshes = 0;

  Future<void> _refresh() async {
    await Future<void>.delayed(widget.delay);
    if (mounted) setState(() => _refreshes++);
  }

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final text = context.bitcrText;

    final label = Text(
      _refreshes == 0 ? 'Pull down to refresh' : 'Refreshed $_refreshes×',
      style: text.textSmMedium(color: colors.text300),
    );

    return PullToRefresh(
      onRefresh: _refresh,
      childScrolls: widget.childScrolls,
      child: widget.childScrolls
          ? ListView(
              padding: const EdgeInsets.all(20),
              children: [
                label,
                const SizedBox(height: 16),
                for (var i = 1; i <= 25; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Row $i',
                      style: text.textSmRegular(color: colors.text200),
                    ),
                  ),
              ],
            )
          : Center(child: label),
    );
  }
}

/// The ordinary case: the screen already has a list, so the pull rides on it.
@widgetbook.UseCase(name: 'Scrolling screen', type: PullToRefresh)
Widget pullToRefreshScrolling(BuildContext context) =>
    const _RefreshHarness(childScrolls: true);

/// A screen with nothing to scroll. Without `childScrolls: false` the gesture
/// would have no overscroll to ride on and would quietly do nothing.
@widgetbook.UseCase(name: 'Short screen', type: PullToRefresh)
Widget pullToRefreshShort(BuildContext context) =>
    const _RefreshHarness(childScrolls: false);

@widgetbook.UseCase(name: 'Playground', type: PullToRefresh)
Widget pullToRefreshPlayground(BuildContext context) => _RefreshHarness(
  childScrolls: context.knobs.boolean(
    label: 'Child scrolls',
    initialValue: true,
  ),
  delay: Duration(
    milliseconds: context.knobs.int
        .slider(
          label: 'Refresh duration (ms)',
          initialValue: 1000,
          min: 200,
          max: 5000,
        )
        .toInt(),
  ),
);
