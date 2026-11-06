import 'package:bitcr_ui/src/core/button.dart';
import 'package:bitcr_ui/src/core/separator.dart';
import 'package:bitcr_ui/src/core/spinner.dart';
import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/fonts.dart';
import 'package:bitcr_ui/src/theme/radii.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/material.dart';

class SignatureDrawerLabels {
  const SignatureDrawerLabels({
    required this.by,
    required this.onBehalfOf,
    required this.placeAndDate,
    required this.date,
    required this.confirm,
    required this.cancel,
  });

  final String by;
  final String onBehalfOf;
  final String placeAndDate;
  final String date;
  final String confirm;
  final String cancel;
}

Future<bool> showSignatureDrawer(
  BuildContext context, {
  required String title,
  required SignatureDrawerLabels labels,
  required String signerName,
  required String date,
  String? location,
  String? companyName,
  bool isAnonymous = false,
  Future<bool> Function()? onConfirm,
}) async {
  final isConfirmed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    builder: (context) => SignatureDrawer(
      title: title,
      labels: labels,
      signerName: signerName,
      date: date,
      location: location,
      companyName: companyName,
      isAnonymous: isAnonymous,
      onConfirm: onConfirm,
    ),
  );

  return isConfirmed ?? false;
}

class SignatureDrawer extends StatefulWidget {
  const SignatureDrawer({
    super.key,
    required this.title,
    required this.labels,
    required this.signerName,
    required this.date,
    this.location,
    this.companyName,
    this.isAnonymous = false,
    this.onConfirm,
  });

  final String title;
  final SignatureDrawerLabels labels;
  final String signerName;
  final String date;
  final String? location;
  final String? companyName;
  final bool isAnonymous;
  final Future<bool> Function()? onConfirm;

  @override
  State<SignatureDrawer> createState() => _SignatureDrawerState();
}

class _SignatureDrawerState extends State<SignatureDrawer> {
  var _isPending = false;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final text = context.bitcrText;
    final labels = widget.labels;

    final caption = text.textSmRegular(color: colors.text200);
    final value = text.textMdRegular(color: colors.text300);

    final date = widget.date;
    final location = widget.location;
    final place = location == null || location.isEmpty
        ? date
        : '$location, $date';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        24,
        20,
        32 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title, style: text.textLgMedium(color: colors.text300)),
          const SizedBox(height: 24),
          if (widget.companyName case final company?) ...[
            Text(labels.onBehalfOf, style: caption),
            const SizedBox(height: 4),
            Text(
              company,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: value,
            ),
            const SizedBox(height: 16),
            Separator(color: colors.divider50),
            const SizedBox(height: 16),
          ],
          Text(labels.by, style: caption),
          const SizedBox(height: 4),
          Text(
            widget.signerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: BitcrFonts.handwriting,
              fontSize: 32,
              height: 1,
              fontWeight: FontWeight.w400,
              color: colors.text300,
            ),
          ),
          const SizedBox(height: 16),
          Separator(color: colors.divider50),
          const SizedBox(height: 16),
          Text(
            widget.isAnonymous ? labels.date : labels.placeAndDate,
            style: caption,
          ),
          const SizedBox(height: 4),
          Text(
            widget.isAnonymous ? date : place,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: value,
          ),
          const SizedBox(height: 24),
          Button(
            disabled: _isPending,
            onPressed: _confirm,
            child: _isPending
                ? Spinner(color: colors.text300)
                : Text(labels.confirm),
          ),
          const SizedBox(height: 12),
          Button(
            variant: ButtonVariant.outline,
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BitcrRadius.md),
                  side: BorderSide(color: colors.divider300),
                ),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(labels.cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm() async {
    if (_isPending) return;

    final navigator = Navigator.of(context);
    final onConfirm = widget.onConfirm;

    if (onConfirm == null) return navigator.pop(true);

    setState(() => _isPending = true);

    final isConfirmed = await onConfirm();

    if (!mounted) return;

    if (isConfirmed) return navigator.pop(true);

    setState(() => _isPending = false);
  }
}
