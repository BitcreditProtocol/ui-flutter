import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/radii.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Recovery-phrase entry: one numbered field per word in a two-column grid.
///
/// The caller owns [controllers] and [focusNodes], one per word. A space or
/// the keyboard's next action moves on, backspace in an empty field moves
/// back, and a whole phrase pasted into any field spreads across it and the
/// fields after it. Each field carries the semantics identifier
/// `'$identifierPrefix$index'` for UI tests.
class SeedPhraseInput extends StatelessWidget {
  const SeedPhraseInput({
    super.key,
    required this.controllers,
    required this.focusNodes,
    this.onChanged,
    this.identifierPrefix = 'seed-word-',
  }) : assert(controllers.length == focusNodes.length);

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final VoidCallback? onChanged;
  final String identifierPrefix;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controllers.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 16,
        mainAxisExtent: 46,
      ),
      itemBuilder: (context, index) => _WordField(
        index: index,
        controller: controllers[index],
        focusNode: focusNodes[index],
        isLast: index == controllers.length - 1,
        identifier: '$identifierPrefix$index',
        onChanged: (value) => _handleChanged(context, index, value),
        onBackspaceWhenEmpty: index > 0
            ? focusNodes[index - 1].requestFocus
            : null,
        onAdvance: () => _advance(context, index),
      ),
    );
  }

  void _advance(BuildContext context, int index) {
    if (index < focusNodes.length - 1) {
      focusNodes[index + 1].requestFocus();
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  void _handleChanged(BuildContext context, int index, String value) {
    final words = value.trim().split(RegExp(r'\s+'));

    if (words.length > 1) {
      final last = (index + words.length).clamp(0, controllers.length);
      for (var i = index; i < last; i++) {
        controllers[i].text = words[i - index];
      }
      onChanged?.call();
      _advance(context, last - 1);
      return;
    }

    if (value.endsWith(' ') && value.trim().isNotEmpty) {
      final word = value.trim();
      controllers[index].value = TextEditingValue(
        text: word,
        selection: TextSelection.collapsed(offset: word.length),
      );
      _advance(context, index);
    }

    onChanged?.call();

    if (value.isEmpty && index > 0) focusNodes[index - 1].requestFocus();
  }
}

class _WordField extends StatelessWidget {
  const _WordField({
    required this.index,
    required this.controller,
    required this.focusNode,
    required this.isLast,
    required this.identifier,
    required this.onChanged,
    required this.onBackspaceWhenEmpty,
    required this.onAdvance,
  });

  final int index;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLast;
  final String identifier;
  final ValueChanged<String> onChanged;
  final VoidCallback? onBackspaceWhenEmpty;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          color: colors.elevation200,
          borderRadius: BorderRadius.circular(BitcrRadius.md),
          border: Border.all(
            color: focusNode.hasFocus ? colors.divider300 : colors.divider50,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: child,
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.elevation300,
              borderRadius: BorderRadius.circular(BitcrRadius.xs),
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.text300,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Focus(
              onKeyEvent: (_, event) {
                final back = onBackspaceWhenEmpty;
                if (back != null &&
                    event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.backspace &&
                    controller.text.isEmpty) {
                  back();
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: Semantics(
                identifier: identifier,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  textInputAction: isLast
                      ? TextInputAction.done
                      : TextInputAction.next,
                  textAlignVertical: TextAlignVertical.center,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: TextStyle(fontSize: 14, color: colors.text300),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: onChanged,
                  onEditingComplete: onAdvance,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
