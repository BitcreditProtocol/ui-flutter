import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Owns the controllers and focus nodes, as the restore screens do.
class _SeedPhraseInputHarness extends StatefulWidget {
  const _SeedPhraseInputHarness({this.initial = const []});

  final List<String> initial;

  @override
  State<_SeedPhraseInputHarness> createState() =>
      _SeedPhraseInputHarnessState();
}

class _SeedPhraseInputHarnessState extends State<_SeedPhraseInputHarness> {
  late final _controllers = List.generate(
    12,
    (i) => TextEditingController(
      text: i < widget.initial.length ? widget.initial[i] : '',
    ),
  );
  final _focusNodes = List.generate(12, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: SeedPhraseInput(
      controllers: _controllers,
      focusNodes: _focusNodes,
      onChanged: () => setState(() {}),
    ),
  );
}

/// Type a word and press space to move on; paste a whole phrase into any
/// field to spread it across the grid.
@widgetbook.UseCase(name: 'Empty', type: SeedPhraseInput)
Widget seedPhraseInputEmpty(BuildContext context) =>
    const _SeedPhraseInputHarness();

@widgetbook.UseCase(name: 'Partly filled', type: SeedPhraseInput)
Widget seedPhraseInputPartlyFilled(BuildContext context) =>
    const _SeedPhraseInputHarness(
      initial: ['abandon', 'ability', 'able', 'about', 'above'],
    );
