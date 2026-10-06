import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:flutter/material.dart';

/// The 36×20 toggle used in settings rows.
/// A null [onChanged] is the disabled state — it dims the switch and stops
/// reporting taps, so callers don't need a separate flag.
class SettingsSwitch extends StatelessWidget {
  const SettingsSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.identifier,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? identifier;

  static const Duration _duration = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final disabled = onChanged == null;

    return MergeSemantics(
      child: Semantics(
        identifier: identifier,
        toggled: value,
        enabled: !disabled,
        child: Opacity(
          opacity: disabled ? 0.5 : 1,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: disabled ? null : () => onChanged!(!value),
            child: AnimatedContainer(
              duration: _duration,
              width: 36,
              height: 20,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: value ? colors.brand200 : colors.divider200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: AnimatedAlign(
                duration: _duration,
                curve: Curves.easeOut,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
