import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Owns the [TextEditingController] the field needs, so use cases don't create
/// one per rebuild and leak it. Shared with the drawer use cases.
class FieldHarness extends StatefulWidget {
  const FieldHarness({
    super.key,
    this.initialText = '',
    required this.builder,
  });

  final String initialText;
  final Widget Function(BuildContext context, TextEditingController controller)
  builder;

  @override
  State<FieldHarness> createState() => _FieldHarnessState();
}

class _FieldHarnessState extends State<FieldHarness> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialText,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controller);
}

Widget _field(
  BuildContext context, {
  String initialText = '',
  required Widget Function(TextEditingController controller) build,
}) => Padding(
  padding: const EdgeInsets.all(24),
  child: Align(
    alignment: Alignment.topCenter,
    child: FieldHarness(
      initialText: initialText,
      builder: (context, controller) => build(controller),
    ),
  ),
);

@widgetbook.UseCase(name: 'Empty', type: AppTextField)
Widget appTextFieldEmpty(BuildContext context) => _field(
  context,
  build: (controller) => AppTextField(
    controller: controller,
    label: 'Recipient',
    clearSemanticLabel: 'Clear',
  ),
);

/// No label, so `hint` is what fills the line. This is the only arrangement
/// where a hint is shown — a labelled field's label occupies that line itself.
@widgetbook.UseCase(name: 'Hint, no label', type: AppTextField)
Widget appTextFieldHintOnly(BuildContext context) => _field(
  context,
  build: (controller) => AppTextField(
    controller: controller,
    hint: 'Name or address',
    clearSemanticLabel: 'Clear',
  ),
);

/// With a value, so the clear button is present.
@widgetbook.UseCase(name: 'Filled', type: AppTextField)
Widget appTextFieldFilled(BuildContext context) => _field(
  context,
  initialText: 'Alice Andersson',
  build: (controller) => AppTextField(
    controller: controller,
    label: 'Recipient',
    clearSemanticLabel: 'Clear',
  ),
);

/// The floating label's two positions at once: empty on the left, with a value
/// on the right. Tap into the empty one to watch the label shrink and rise.
@widgetbook.UseCase(name: 'Label states', type: AppTextField)
Widget appTextFieldLabelStates(BuildContext context) => Padding(
  padding: const EdgeInsets.all(24),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 16,
    children: [
      Expanded(
        child: FieldHarness(
          builder: (context, controller) => AppTextField(
            controller: controller,
            label: 'Recipient',
            clearSemanticLabel: 'Clear',
          ),
        ),
      ),
      Expanded(
        child: FieldHarness(
          initialText: 'Alice Andersson',
          builder: (context, controller) => AppTextField(
            controller: controller,
            label: 'Recipient',
            clearSemanticLabel: 'Clear',
          ),
        ),
      ),
    ],
  ),
);

@widgetbook.UseCase(name: 'Error', type: AppTextField)
Widget appTextFieldError(BuildContext context) => _field(
  context,
  initialText: 'not-an-address',
  build: (controller) => AppTextField(
    controller: controller,
    label: 'Recipient',
    errorText: "That doesn't look like a valid address.",
    clearSemanticLabel: 'Clear',
  ),
);

/// Empty and with an `onPaste` handler, which is when the paste button shows
/// instead of the clear one.
@widgetbook.UseCase(name: 'Paste button', type: AppTextField)
Widget appTextFieldPaste(BuildContext context) => _field(
  context,
  build: (controller) => AppTextField(
    controller: controller,
    label: 'Recovery phrase',
    icon: LucideIcons.keyRound300,
    onPaste: () => controller.text = 'abandon ability able about above absent',
    pasteSemanticLabel: 'Paste',
    clearSemanticLabel: 'Clear',
  ),
);

@widgetbook.UseCase(name: 'Disabled and read-only', type: AppTextField)
Widget appTextFieldDisabled(BuildContext context) => Padding(
  padding: const EdgeInsets.all(24),
  child: Column(
    spacing: 16,
    children: [
      FieldHarness(
        initialText: 'Locked value',
        builder: (context, controller) => AppTextField(
          controller: controller,
          label: 'Disabled',
          enabled: false,
        ),
      ),
      FieldHarness(
        initialText: 'Read-only value',
        builder: (context, controller) => AppTextField(
          controller: controller,
          label: 'Read only',
          readOnly: true,
        ),
      ),
    ],
  ),
);

/// Multi-line: the field grows past its 52px minimum, and the label stays put.
@widgetbook.UseCase(name: 'Multiline', type: AppTextField)
Widget appTextFieldMultiline(BuildContext context) => _field(
  context,
  initialText: 'Dinner on Tuesday, split three ways between Alice, Bob and me.',
  build: (controller) => AppTextField(
    controller: controller,
    label: 'Note',
    minLines: 3,
    maxLines: 5,
    clearSemanticLabel: 'Clear',
  ),
);

@widgetbook.UseCase(name: 'Playground', type: AppTextField)
Widget appTextFieldPlayground(BuildContext context) {
  final hasError = context.knobs.boolean(label: 'Error');

  return _field(
    context,
    initialText: 'Alice Andersson',
    build: (controller) => AppTextField(
      controller: controller,
      label: context.knobs.stringOrNull(label: 'Label') ?? 'Recipient',
      helperText: context.knobs.stringOrNull(label: 'Helper text'),
      errorText: hasError ? 'Something is wrong with this value.' : null,
      isRequired: context.knobs.boolean(label: 'Required'),
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
      readOnly: context.knobs.boolean(label: 'Read only'),
      obscureText: context.knobs.boolean(label: 'Obscure text'),
      showClearButton: context.knobs.boolean(
        label: 'Clear button',
        initialValue: true,
      ),
      icon: context.knobs.boolean(label: 'Leading icon')
          ? LucideIcons.user300
          : null,
      clearSemanticLabel: 'Clear',
    ),
  );
}
