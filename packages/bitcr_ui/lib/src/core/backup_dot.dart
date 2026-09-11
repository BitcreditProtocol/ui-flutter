import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:flutter/widgets.dart';

/// A small filled dot used as an attention marker — on the settings entry
/// while the recovery phrase is still unbacked, and as the unread badge on
/// navigation items.
class BackupDot extends StatelessWidget {
  const BackupDot({super.key, this.size = 8, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? BitcrColors.of(context).signalErrorLight,
        shape: BoxShape.circle,
      ),
    );
  }
}
