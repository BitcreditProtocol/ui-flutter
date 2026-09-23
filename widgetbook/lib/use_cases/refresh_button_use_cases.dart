import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Stands in for the app: the button never owns the in-flight flag, so the
/// catalog has to fake a request to show the spin.
class _RefreshHarness extends StatefulWidget {
  const _RefreshHarness({
    this.label,
    this.tooltip,
    this.size = RefreshButtonSize.md,
    this.disabled = false,
    this.spinDuration = const Duration(seconds: 1),
    this.duration = const Duration(seconds: 2),
  });

  final String? label;
  final String? tooltip;
  final RefreshButtonSize size;
  final bool disabled;
  final Duration spinDuration;
  final Duration duration;

  @override
  State<_RefreshHarness> createState() => _RefreshHarnessState();
}

class _RefreshHarnessState extends State<_RefreshHarness> {
  bool _loading = false;
  int _refreshes = 0;

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future<void>.delayed(widget.duration);
    if (mounted) {
      setState(() {
        _loading = false;
        _refreshes += 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          RefreshButton(
            label: widget.label,
            tooltip: widget.tooltip,
            size: widget.size,
            disabled: widget.disabled,
            spinDuration: widget.spinDuration,
            isLoading: _loading,
            onPressed: _refresh,
          ),
          Text(
            'refreshes: $_refreshes',
            style: context.bitcrText.textXsRegular(color: colors.text200),
          ),
        ],
      ),
    );
  }
}

/// Icon only — the compact form, for sitting next to a heading.
@widgetbook.UseCase(name: 'Icon only', type: RefreshButton)
Widget refreshButtonIconOnly(BuildContext context) => const _RefreshHarness();

/// With a label, which is what the e-bill frontend's version shows.
@widgetbook.UseCase(name: 'With label', type: RefreshButton)
Widget refreshButtonWithLabel(BuildContext context) =>
    const _RefreshHarness(label: 'Refresh');

/// With a tooltip — the reference only renders one when given copy for it.
@widgetbook.UseCase(name: 'With tooltip', type: RefreshButton)
Widget refreshButtonWithTooltip(BuildContext context) => const _RefreshHarness(
  label: 'Refresh',
  tooltip: 'Check the mint for updates',
);

/// Parked in the spinning state, so the motion can be inspected on its own.
@widgetbook.UseCase(name: 'Loading (held)', type: RefreshButton)
Widget refreshButtonLoading(BuildContext context) =>
    const Center(child: RefreshButton(label: 'Refreshing', isLoading: true));

/// The whole point of the component sitting in a design system: it is not the
/// topbar button. Both are here to be told apart.
@widgetbook.UseCase(name: 'Next to TopbarActionButton', type: RefreshButton)
Widget refreshButtonVersusTopbar(BuildContext context) => const Center(
  child: Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 24,
    children: [
      RefreshButton(label: 'Refresh', isLoading: true),
      TopbarActionButton(icon: LucideIcons.refreshCw300, isLoading: true),
    ],
  ),
);

/// Every size, spinning, so the icon/label ratio can be compared at a glance.
@widgetbook.UseCase(name: 'Sizes', type: RefreshButton)
Widget refreshButtonSizes(BuildContext context) => Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    spacing: 20,
    children: [
      for (final size in RefreshButtonSize.values)
        RefreshButton(label: size.name, size: size, isLoading: true),
    ],
  ),
);

/// Disabled is not loading: greyed out and inert, for a refresh that isn't
/// available yet rather than one already in flight.
@widgetbook.UseCase(name: 'Disabled', type: RefreshButton)
Widget refreshButtonDisabled(BuildContext context) => const Center(
  child: Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 24,
    children: [
      RefreshButton(label: 'Enabled'),
      RefreshButton(label: 'Disabled', disabled: true),
    ],
  ),
);

/// The colour is a parameter, so a call site can put the button on a signal
/// colour or a muted one instead of the brand.
@widgetbook.UseCase(name: 'Colors', type: RefreshButton)
Widget refreshButtonColors(BuildContext context) {
  final colors = BitcrColors.of(context);

  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        const RefreshButton(label: 'brand200 (default)'),
        RefreshButton(label: 'text200', color: colors.text200),
        RefreshButton(label: 'signalError', color: colors.signalError),
        RefreshButton(label: 'signalSuccess', color: colors.signalSuccess),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Playground', type: RefreshButton)
Widget refreshButtonPlayground(BuildContext context) => _RefreshHarness(
  label: context.knobs.stringOrNull(label: 'Label', initialValue: 'Refresh'),
  tooltip: context.knobs.stringOrNull(label: 'Tooltip'),
  size: context.knobs.object.dropdown(
    label: 'Size',
    options: RefreshButtonSize.values,
    initialOption: RefreshButtonSize.md,
    labelBuilder: (s) => s.name,
  ),
  disabled: context.knobs.boolean(label: 'Disabled'),
  spinDuration: Duration(
    milliseconds: context.knobs.int
        .slider(
          label: 'One turn takes (ms)',
          initialValue: 1000,
          min: 200,
          max: 4000,
        )
        .toInt(),
  ),
  duration: Duration(
    milliseconds: context.knobs.int
        .slider(
          label: 'Request takes (ms)',
          initialValue: 2000,
          min: 200,
          max: 8000,
        )
        .toInt(),
  ),
);
