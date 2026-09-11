import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Owns the index the way a tab-bar screen does, so both directions are
/// exercised: swiping updates the tabs, tapping a tab animates the pager.
class _PagerHarness extends StatefulWidget {
  const _PagerHarness();

  static const _labels = ['Payments', 'Requests', 'Contacts'];

  @override
  State<_PagerHarness> createState() => _PagerHarnessState();
}

class _PagerHarnessState extends State<_PagerHarness> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var i = 0; i < _PagerHarness._labels.length; i++)
              TextButton(
                onPressed: () => setState(() => _index = i),
                child: Text(
                  _PagerHarness._labels[i],
                  style: context.bitcrText.textSmMedium(
                    color: i == _index ? colors.brand200 : colors.text200,
                  ),
                ),
              ),
          ],
        ),
        Expanded(
          child: SwipeableViews(
            index: _index,
            onIndexChanged: (next) => setState(() => _index = next),
            children: [
              for (final label in _PagerHarness._labels)
                Center(
                  child: Text(label, style: context.bitcrText.displayXsMedium()),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

@widgetbook.UseCase(name: 'Three pages', type: SwipeableViews)
Widget swipeableViewsThreePages(BuildContext context) => const _PagerHarness();
