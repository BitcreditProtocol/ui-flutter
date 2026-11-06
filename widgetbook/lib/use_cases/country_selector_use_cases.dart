import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _countries = [
  CountryOption(code: 'AR', name: 'Argentina'),
  CountryOption(code: 'AT', name: 'Austria', searchTerms: ['Österreich']),
  CountryOption(code: 'BE', name: 'Belgium'),
  CountryOption(code: 'BR', name: 'Brazil'),
  CountryOption(code: 'CA', name: 'Canada'),
  CountryOption(code: 'CL', name: 'Chile'),
  CountryOption(code: 'FR', name: 'France'),
  CountryOption(code: 'DE', name: 'Germany', searchTerms: ['Deutschland']),
  CountryOption(code: 'IT', name: 'Italy'),
  CountryOption(code: 'JP', name: 'Japan'),
  CountryOption(code: 'MX', name: 'Mexico'),
  CountryOption(code: 'NL', name: 'Netherlands'),
  CountryOption(code: 'PT', name: 'Portugal'),
  CountryOption(code: 'ES', name: 'Spain'),
  CountryOption(code: 'CH', name: 'Switzerland', searchTerms: ['Schweiz']),
  CountryOption(code: 'UG', name: 'Uganda'),
  CountryOption(code: 'GB', name: 'United Kingdom'),
  CountryOption(code: 'US', name: 'United States'),
];

class _CountryHarness extends StatefulWidget {
  const _CountryHarness({
    super.key,
    required this.initial,
    required this.isRequired,
    required this.alignment,
  });

  final String initial;
  final bool isRequired;
  final Alignment alignment;

  @override
  State<_CountryHarness> createState() => _CountryHarnessState();
}

class _CountryHarnessState extends State<_CountryHarness> {
  late final _controller = TextEditingController(text: widget.initial);
  final _form = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Align(
      alignment: widget.alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _form,
          child: CountrySelector(
            controller: _controller,
            label: 'Country',
            countries: _countries,
            searchPlaceholder: 'Search for a country...',
            noResultsLabel: 'No country found.',
            clearLabel: 'Clear country',
            clearSearchLabel: 'Clear search',
            isRequired: widget.isRequired,
            validator: widget.isRequired
                ? (value) =>
                      (value ?? '').isEmpty ? 'Country is required' : null
                : null,
          ),
        ),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Empty', type: CountrySelector)
Widget countrySelectorEmpty(BuildContext context) => const _CountryHarness(
  initial: '',
  isRequired: true,
  alignment: Alignment.topCenter,
);

@widgetbook.UseCase(name: 'Selected', type: CountrySelector)
Widget countrySelectorSelected(BuildContext context) => const _CountryHarness(
  initial: 'AT',
  isRequired: true,
  alignment: Alignment.topCenter,
);

@widgetbook.UseCase(name: 'Near the bottom', type: CountrySelector)
Widget countrySelectorNearBottom(BuildContext context) => const _CountryHarness(
  initial: '',
  isRequired: false,
  alignment: Alignment.bottomCenter,
);

@widgetbook.UseCase(name: 'Playground', type: CountrySelector)
Widget countrySelectorPlayground(BuildContext context) {
  final initial = context.knobs.object.dropdown(
    label: 'Initial country',
    options: ['', ..._countries.map((country) => country.code)],
    labelBuilder: (code) => code.isEmpty ? 'None' : code,
  );
  final isRequired = context.knobs.boolean(
    label: 'Required',
    initialValue: true,
  );

  return _CountryHarness(
    key: ValueKey((initial, isRequired)),
    initial: initial,
    isRequired: isRequired,
    alignment: Alignment.topCenter,
  );
}
