import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Stands in for the app: folds the per-digit callbacks back into a value and
/// hands it to the form, which is the contract every real screen implements.
class _PasscodeHarness extends StatefulWidget {
  const _PasscodeHarness({
    this.initial = '',
    this.length = 4,
    this.autoFocus = false,
    this.clearWhenComplete = false,
  });

  final String initial;
  final int length;
  final bool autoFocus;

  /// Mimics a rejected PIN: once full, the app wipes the value and the form
  /// resets for another attempt.
  final bool clearWhenComplete;

  @override
  State<_PasscodeHarness> createState() => _PasscodeHarnessState();
}

class _PasscodeHarnessState extends State<_PasscodeHarness> {
  late String _value = widget.initial;
  int _attempts = 0;

  void _onChanged(int index, String digit) {
    final next = digit.isEmpty
        ? _value.substring(0, index)
        : _value.padRight(index).replaceRange(index, null, digit);

    setState(() => _value = next);

    if (widget.clearWhenComplete && next.length == widget.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _value = '';
            _attempts += 1;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: [
          PasscodeForm(
            value: _value,
            length: widget.length,
            autoFocus: widget.autoFocus,
            onChanged: _onChanged,
          ),
          Text(
            widget.clearWhenComplete
                ? 'rejected attempts: $_attempts'
                : 'value: "$_value"',
            style: context.bitcrText.textXsRegular(color: colors.text200),
          ),
        ],
      ),
    );
  }
}

/// Empty: the first slot is the active one, with the heavier border.
@widgetbook.UseCase(name: 'Empty', type: PasscodeForm)
Widget passcodeFormEmpty(BuildContext context) => const _PasscodeHarness();

/// Partly filled, so the filled dots, the active slot and the untouched ones
/// are all visible at once.
@widgetbook.UseCase(name: 'Partly filled', type: PasscodeForm)
Widget passcodeFormPartlyFilled(BuildContext context) =>
    const _PasscodeHarness(initial: '12');

/// Complete — no slot is active once every digit is in.
@widgetbook.UseCase(name: 'Complete', type: PasscodeForm)
Widget passcodeFormComplete(BuildContext context) =>
    const _PasscodeHarness(initial: '1234');

/// A six-digit PIN. The wallet only uses four, but the length is a parameter
/// rather than baked into the dot row.
@widgetbook.UseCase(name: 'Six digits', type: PasscodeForm)
Widget passcodeFormSixDigits(BuildContext context) =>
    const _PasscodeHarness(length: 6);

/// What a wrong PIN looks like: the app clears the value on completion and the
/// form resets, ready for the next attempt.
@widgetbook.UseCase(name: 'Rejected attempt', type: PasscodeForm)
Widget passcodeFormRejected(BuildContext context) =>
    const _PasscodeHarness(clearWhenComplete: true);

@widgetbook.UseCase(name: 'Playground', type: PasscodeForm)
Widget passcodeFormPlayground(BuildContext context) => _PasscodeHarness(
  length: context.knobs.int
      .slider(label: 'Length', initialValue: 4, min: 3, max: 8)
      .toInt(),
  // Off by default: on desktop the keyboard request is a no-op, and it steals
  // focus from the knobs panel.
  autoFocus: context.knobs.boolean(label: 'Auto focus'),
  clearWhenComplete: context.knobs.boolean(label: 'Reject when complete'),
);
