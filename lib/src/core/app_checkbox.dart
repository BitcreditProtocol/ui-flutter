import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons_200.dart';

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({super.key, required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: value ? colors.brand50 : colors.elevation200,
        border: Border.all(color: value ? colors.brand200 : colors.divider75),
        borderRadius: BorderRadius.circular(6),
      ),
      child: value
          ? Icon(LucideIcons200.check, size: 14, color: colors.brand200)
          : null,
    );
  }
}
