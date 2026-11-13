import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:material_ui/material_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

class FieldInfoButton extends StatelessWidget {
  const FieldInfoButton({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: message,
    triggerMode: TooltipTriggerMode.tap,
    showDuration: const Duration(seconds: 3),
    child: Semantics(
      button: true,
      label: message,
      child: Icon(
        LucideIcons300.info,
        size: 20,
        color: BitcrColors.of(context).text200,
      ),
    ),
  );
}
