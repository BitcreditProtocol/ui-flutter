import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons_200.dart';

class EmailBadge extends StatelessWidget {
  const EmailBadge({
    super.key,
    required this.isVerified,
    required this.verifiedLabel,
    required this.notVerifiedLabel,
  });

  final bool isVerified;
  final String verifiedLabel;
  final String notVerifiedLabel;

  @override
  Widget build(BuildContext context) {
    if (isVerified) {
      return SvgPicture.asset(
        'assets/icons/badge_check.svg',
        package: 'bitcr_ui',
        width: 20,
        height: 20,
        semanticsLabel: verifiedLabel,
      );
    }

    return Tooltip(
      message: notVerifiedLabel,
      triggerMode: TooltipTriggerMode.tap,
      child: Icon(
        LucideIcons200.badgeAlert,
        size: 20,
        color: BitcrColors.of(context).text300,
      ),
    );
  }
}
