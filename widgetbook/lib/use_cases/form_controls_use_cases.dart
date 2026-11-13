import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class _Toggle extends StatefulWidget {
  const _Toggle();

  @override
  State<_Toggle> createState() => _ToggleState();
}

class _ToggleState extends State<_Toggle> {
  var _value = false;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => setState(() => _value = !_value),
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          AppCheckbox(value: _value),
          Text(
            'I have written down my recovery phrase',
            style: context.bitcrText.textSmRegular(
              color: BitcrColors.of(context).text300,
            ),
          ),
        ],
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'States', type: AppCheckbox)
Widget appCheckboxStates(BuildContext context) => const Center(
  child: Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 16,
    children: [AppCheckbox(value: false), AppCheckbox(value: true)],
  ),
);

@widgetbook.UseCase(name: 'With a label', type: AppCheckbox)
Widget appCheckboxWithLabel(BuildContext context) =>
    const Center(child: _Toggle());

@widgetbook.UseCase(name: 'States', type: AppRadio)
Widget appRadioStates(BuildContext context) => const Center(
  child: Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 16,
    children: [AppRadio(selected: false), AppRadio(selected: true)],
  ),
);

class _RadioHarness extends StatefulWidget {
  const _RadioHarness({required this.withLeading});

  final bool withLeading;

  @override
  State<_RadioHarness> createState() => _RadioHarnessState();
}

class _RadioHarnessState extends State<_RadioHarness> {
  String? _value;

  Widget Function(bool)? _icon(IconData icon) => widget.withLeading
      ? (selected) => Icon(
          icon,
          size: 20,
          color: selected ? Colors.white : BitcrColors.of(context).text300,
        )
      : null;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Align(
      alignment: Alignment.topCenter,
      child: RadioOptionGroup<String>(
        value: _value,
        onChanged: (value) => setState(() => _value = value),
        options: [
          RadioOption(
            value: 'personal',
            label: 'Personal',
            description: 'Sign bills with your name and address.',
            leading: _icon(LucideIcons200.user),
          ),
          RadioOption(
            value: 'incognito',
            label: 'Incognito',
            description: 'Use a pseudonym with limited functionality.',
            leading: _icon(LucideIcons200.venetianMask),
          ),
        ],
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Identity type', type: RadioOptionGroup)
Widget radioOptionGroupIdentity(BuildContext context) =>
    const _RadioHarness(withLeading: true);

@widgetbook.UseCase(name: 'Without icons', type: RadioOptionGroup)
Widget radioOptionGroupPlain(BuildContext context) =>
    const _RadioHarness(withLeading: false);
