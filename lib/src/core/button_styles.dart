import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/radii.dart';
import 'package:flutter/material.dart';

ButtonStyle outlineButtonStyle(BuildContext context) => ButtonStyle(
  shape: WidgetStatePropertyAll(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(BitcrRadius.md),
      side: BorderSide(color: BitcrColors.of(context).divider300),
    ),
  ),
);

const smallButtonStyle = ButtonStyle(
  minimumSize: WidgetStatePropertyAll(Size.fromHeight(44)),
  padding: WidgetStatePropertyAll(
    EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  ),
);
