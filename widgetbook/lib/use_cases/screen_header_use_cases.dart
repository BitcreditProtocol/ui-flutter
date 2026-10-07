import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _gradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFFFA72E), Color(0xFFED8910)],
);

Widget _page(Widget child) =>
    Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: child);

List<Widget> _actions() => [
  TopbarActionButton(
    icon: LucideIcons.download300,
    semanticLabel: 'Export',
    onPressed: () {},
  ),
  const Avatar(name: 'Personal', size: AvatarSize.nav, gradient: _gradient),
];

@widgetbook.UseCase(name: 'Title only', type: ScreenHeader)
Widget screenHeaderTitleOnly(BuildContext context) =>
    _page(const ScreenHeader(title: 'Settings'));

@widgetbook.UseCase(name: 'With actions', type: ScreenHeader)
Widget screenHeaderWithActions(BuildContext context) =>
    _page(ScreenHeader(title: 'Payments', actions: _actions()));

/// The ellipsis case: a title long enough to collide with the actions.
@widgetbook.UseCase(name: 'Overflowing title', type: ScreenHeader)
Widget screenHeaderOverflowing(BuildContext context) => _page(
  ScreenHeader(
    title: 'A screen title far too long to fit on one line',
    actions: _actions(),
  ),
);

/// Drag the slider to scrub the large title into the collapsed one.
@widgetbook.UseCase(name: 'Playground', type: ScreenHeader)
Widget screenHeaderPlayground(BuildContext context) {
  final hasActions = context.knobs.boolean(
    label: 'Show actions',
    initialValue: true,
  );

  return _page(
    ScreenHeader(
      title: context.knobs.string(label: 'Title', initialValue: 'Payments'),
      collapse: context.knobs.double.slider(
        label: 'Collapse',
        initialValue: 0,
        min: 0,
        max: 1,
      ),
      actions: hasActions ? _actions() : const [],
    ),
  );
}

/// The full layout: scroll the list and the header collapses, the tabs stay
/// and the search folds away.
@widgetbook.UseCase(name: 'Large title layout', type: LargeTitleLayout)
Widget largeTitleLayout(BuildContext context) => const _LargeTitleDemo();

class _LargeTitleDemo extends StatefulWidget {
  const _LargeTitleDemo();

  @override
  State<_LargeTitleDemo> createState() => _LargeTitleDemoState();
}

class _LargeTitleDemoState extends State<_LargeTitleDemo> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return LargeTitleLayout(
      title: 'Payments',
      actions: _actions(),
      pinned: TabSwitch(
        items: const [
          TabSwitchItem(label: 'Activity', showChevron: true),
          TabSwitchItem(label: 'Balances', showChevron: true),
        ],
        selectedIndex: _tab,
        onTap: (index) => setState(() => _tab = index),
      ),
      collapsible: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          const Search(placeholder: 'Search...', size: SearchSize.topbar),
          FilterBadge(label: 'Last 30 days', onRemove: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        itemCount: 40,
        itemBuilder: (context, index) => SizedBox(
          height: 54,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Payment ${index + 1}',
              style: context.bitcrText.textMdMedium(),
            ),
          ),
        ),
      ),
    );
  }
}
