import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/material.dart';

class AppRadio extends StatelessWidget {
  const AppRadio({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.elevation200,
        border: Border.all(
          color: selected ? colors.brand200 : colors.divider75,
        ),
      ),
      child: selected
          ? Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.brand200,
              ),
            )
          : null,
    );
  }
}

class RadioOption<T> {
  const RadioOption({
    required this.value,
    required this.label,
    this.description,
    this.leading,
  });

  final T value;
  final String label;
  final String? description;
  final Widget Function(bool selected)? leading;
}

class RadioOptionGroup<T> extends StatelessWidget {
  const RadioOptionGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.spacing = 12,
  });

  final List<RadioOption<T>> options;
  final T? value;
  final ValueChanged<T> onChanged;
  final double spacing;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: spacing,
    children: [
      for (final option in options)
        RadioCard(
          label: option.label,
          description: option.description,
          leading: option.leading,
          selected: option.value == value,
          onTap: () => onChanged(option.value),
        ),
    ],
  );
}

class RadioCard extends StatelessWidget {
  const RadioCard({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.description,
    this.leading,
  });

  final String label;
  final String? description;
  final Widget Function(bool selected)? leading;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final text = context.bitcrText;
    final leading = this.leading;
    final description = this.description;

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: selected ? colors.elevation200 : null,
            border: Border.all(color: colors.divider50),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? colors.black : colors.elevation200,
                  ),
                  child: leading(selected),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: text.textMdMedium(color: colors.text300),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: text.textXsRegular(color: colors.text200),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AppRadio(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}
