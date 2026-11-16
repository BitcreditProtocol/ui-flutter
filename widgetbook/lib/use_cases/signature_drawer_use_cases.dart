import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _labels = SignatureDrawerLabels(
  by: 'By',
  onBehalfOf: 'On behalf of',
  placeAndDate: 'Place, date:',
  date: 'Date:',
  confirm: 'Confirm signature',
  cancel: 'Cancel',
);

Widget _inSheet(BuildContext context, Widget drawer) => Align(
  alignment: Alignment.bottomCenter,
  child: DecoratedBox(
    decoration: BoxDecoration(
      color: BitcrColors.of(context).elevation50,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(BitcrRadius.xxl),
      ),
    ),
    child: drawer,
  ),
);

@widgetbook.UseCase(name: 'Personal', type: SignatureDrawer)
Widget signatureDrawerPersonal(BuildContext context) => _inSheet(
  context,
  const SignatureDrawer(
    title: 'Signed',
    labels: _labels,
    signerName: 'Ada Lovelace',
    date: '05 Nov 2026',
    location: 'Vienna (AT)',
  ),
);

@widgetbook.UseCase(name: 'On behalf of a company', type: SignatureDrawer)
Widget signatureDrawerCompany(BuildContext context) => _inSheet(
  context,
  const SignatureDrawer(
    title: 'Signed',
    labels: _labels,
    signerName: 'Ada Lovelace',
    date: '05 Nov 2026',
    location: 'Vienna (AT)',
    companyName: 'Acme Ltd',
  ),
);

@widgetbook.UseCase(name: 'Anonymous', type: SignatureDrawer)
Widget signatureDrawerAnonymous(BuildContext context) => _inSheet(
  context,
  const SignatureDrawer(
    title: 'Signed',
    labels: _labels,
    signerName: 'satoshi',
    date: '05 Nov 2026',
    isAnonymous: true,
  ),
);

@widgetbook.UseCase(name: 'Open as a modal sheet', type: SignatureDrawer)
Widget signatureDrawerModal(BuildContext context) {
  final succeeds = context.knobs.boolean(
    label: 'Confirmation succeeds',
    initialValue: true,
  );

  return Center(
    child: Button(
      onPressed: () async {
        final signed = await showSignatureDrawer(
          context,
          title: 'Signed',
          labels: _labels,
          signerName: 'Ada Lovelace',
          date: '05 Nov 2026',
          location: 'Vienna (AT)',
          onConfirm: () async {
            await Future<void>.delayed(const Duration(seconds: 2));
            return succeeds;
          },
        );

        if (!context.mounted) return;

        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text(signed ? 'Signed' : 'Not signed')),
        );
      },
      child: const Text('Sign'),
    ),
  );
}

@widgetbook.UseCase(name: 'Playground', type: SignatureDrawer)
Widget signatureDrawerPlayground(BuildContext context) => _inSheet(
  context,
  SignatureDrawer(
    title: context.knobs.string(label: 'Title', initialValue: 'Signed'),
    labels: _labels,
    signerName: context.knobs.string(
      label: 'Signer',
      initialValue: 'Ada Lovelace',
    ),
    date: context.knobs.string(label: 'Date', initialValue: '05 Nov 2026'),
    location: context.knobs.string(
      label: 'Location',
      initialValue: 'Vienna (AT)',
    ),
    companyName: context.knobs.stringOrNull(label: 'Company'),
    isAnonymous: context.knobs.boolean(label: 'Anonymous'),
  ),
);

@widgetbook.UseCase(name: 'Default', type: Spinner)
Widget spinnerDefault(BuildContext context) => Center(
  child: Spinner(
    size: context.knobs.double.slider(
      label: 'Size',
      initialValue: 16,
      min: 12,
      max: 48,
    ),
  ),
);
