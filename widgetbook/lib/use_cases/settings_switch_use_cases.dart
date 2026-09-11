import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Holds the switch's own state so the use case animates on tap — a knob-only
/// version can't show the 150ms slide.
class _SwitchHarness extends StatefulWidget {
  const _SwitchHarness({required this.initialValue, required this.enabled});

  final bool initialValue;
  final bool enabled;

  @override
  State<_SwitchHarness> createState() => _SwitchHarnessState();
}

class _SwitchHarnessState extends State<_SwitchHarness> {
  late bool _value = widget.initialValue;

  @override
  Widget build(BuildContext context) => SettingsSwitch(
    value: _value,
    onChanged: widget.enabled
        ? (next) => setState(() => _value = next)
        : null,
  );
}

@widgetbook.UseCase(name: 'Interactive', type: SettingsSwitch)
Widget settingsSwitchInteractive(BuildContext context) =>
    const _SwitchHarness(initialValue: false, enabled: true);

@widgetbook.UseCase(name: 'Disabled', type: SettingsSwitch)
Widget settingsSwitchDisabled(BuildContext context) => Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 16,
  children: const [
    SettingsSwitch(value: false),
    SettingsSwitch(value: true),
  ],
);

@widgetbook.UseCase(name: 'Playground', type: SettingsSwitch)
Widget settingsSwitchPlayground(BuildContext context) => _SwitchHarness(
  initialValue: context.knobs.boolean(label: 'Initially on'),
  enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
);
