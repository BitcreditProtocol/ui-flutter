import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

Widget _trigger(BuildContext context, String label) {
  final colors = BitcrColors.of(context);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: colors.elevation200,
      borderRadius: BorderRadius.circular(80),
      border: Border.all(color: colors.divider50),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Text(label, style: context.bitcrText.textSmMedium()),
        Icon(LucideIcons200.chevronDown, size: 16, color: colors.text200),
      ],
    ),
  );
}

Widget _top(Widget child) => Padding(
  padding: const EdgeInsets.all(20),
  child: Align(alignment: Alignment.topCenter, child: child),
);

@widgetbook.UseCase(name: 'Actions', type: Dropdown)
Widget dropdownActions(BuildContext context) => _top(
  Dropdown(
    items: [
      DropdownItem(
        leading: const Icon(LucideIcons200.images),
        onTap: () {},
        child: const Text('Photos'),
      ),
      DropdownItem(
        leading: const Icon(LucideIcons200.camera),
        onTap: () {},
        child: const Text('Camera'),
      ),
      DropdownItem(
        leading: const Icon(LucideIcons200.folder),
        onTap: () {},
        child: const Text('Files'),
      ),
    ],
    child: _trigger(context, 'Upload'),
  ),
);

@widgetbook.UseCase(name: 'Wide with footer', type: Dropdown)
Widget dropdownWideWithFooter(BuildContext context) {
  final colors = BitcrColors.of(context);

  return _top(
    Dropdown(
      width: 384,
      padding: const EdgeInsets.all(8),
      radius: BitcrRadius.md,
      items: [
        for (final (name, active) in [
          ('Ada Lovelace', true),
          ('Analytical Engines Ltd', false),
        ])
          DropdownItem(
            padding: const EdgeInsets.all(8),
            leading: Avatar(name: name),
            trailing: active
                ? const Icon(LucideIcons200.check, size: 20)
                : null,
            onTap: () {},
            child: Text(name, overflow: TextOverflow.ellipsis),
          ),
        const DropdownSeparator(),
        DropdownItem(
          padding: const EdgeInsets.symmetric(vertical: 8),
          onTap: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              Text(
                'Manage identities',
                style: context.bitcrText.textSmMedium(color: colors.brand200),
              ),
              Icon(LucideIcons200.settings, color: colors.brand200),
            ],
          ),
        ),
      ],
      child: _trigger(context, 'Ada Lovelace'),
    ),
  );
}

@widgetbook.UseCase(name: 'Disabled item', type: Dropdown)
Widget dropdownDisabledItem(BuildContext context) => _top(
  Dropdown(
    items: [
      DropdownItem(onTap: () {}, child: const Text('Available')),
      const DropdownItem(disabled: true, child: Text('Unavailable')),
    ],
    child: _trigger(context, 'Options'),
  ),
);

@widgetbook.UseCase(name: 'Playground', type: Dropdown)
Widget dropdownPlayground(BuildContext context) {
  final count = context.knobs.int.slider(
    label: 'Items',
    initialValue: 4,
    min: 1,
    max: 30,
  );

  return Padding(
    padding: const EdgeInsets.all(20),
    child: Align(
      alignment: context.knobs.object.dropdown(
        label: 'Trigger position',
        options: [
          Alignment.topLeft,
          Alignment.topCenter,
          Alignment.topRight,
          Alignment.bottomCenter,
        ],
        labelBuilder: (a) => switch (a) {
          Alignment.topLeft => 'top left',
          Alignment.topRight => 'top right',
          Alignment.bottomCenter => 'bottom center',
          _ => 'top center',
        },
      ),
      child: Dropdown(
        alignment: context.knobs.object.dropdown(
          label: 'Alignment',
          options: DropdownAlignment.values,
          labelBuilder: (a) => a.name,
        ),
        width: context.knobs.doubleOrNull.slider(
          label: 'Width',
          min: 128,
          max: 600,
        ),
        items: [
          for (var i = 1; i <= count; i++)
            DropdownItem(onTap: () {}, child: Text('Item $i')),
        ],
        child: _trigger(context, 'Open'),
      ),
    ),
  );
}
