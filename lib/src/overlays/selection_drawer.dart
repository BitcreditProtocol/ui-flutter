import 'package:bitcr_ui/src/core/button.dart';
import 'package:bitcr_ui/src/core/search.dart';
import 'package:bitcr_ui/src/overlays/bottom_drawer.dart';
import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Above this many options on screen, [SelectionDrawer] builds its rows
/// lazily instead of all at once.
///
/// A `Column` builds every child whether or not it is in view, which is fine
/// for the language or date-format pickers and not for a currency list: 151
/// options measured 265ms to open and 80ms per keystroke, against 108ms and
/// 54ms for the same rows built lazily.
///
/// The threshold is applied to what is actually being shown rather than to the
/// whole option list, so a search that narrows a long list back down gets the
/// short-list behaviour again -- including a sheet that shrinks to its rows,
/// which is what a `Column` does and a `ListView` cannot.
const int kSelectionDrawerLazyThreshold = 30;

/// One option in a [SelectionDrawer].
///
/// Everything here is the app's: [label] and [secondaryLabel] are its copy or
/// its generated examples, and [value] is whatever it wants back from
/// [SelectionDrawer.onSelect].
class SelectionOption<T> {
  const SelectionOption({
    required this.value,
    required this.label,
    this.secondaryLabel,
    this.leading,
    this.searchTerms = const [],
  });

  final T value;
  final String label;
  final String? secondaryLabel;
  final Widget? leading;
  final List<String> searchTerms;
}

/// Enables the search field in a [SelectionDrawer], and carries the four
/// strings it needs.
class SelectionDrawerSearch {
  const SelectionDrawerSearch({
    required this.placeholder,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.clearLabel,
  });

  final String placeholder;
  final String emptyTitle;
  final String emptySubtitle;
  final String clearLabel;
}

/// A bottom drawer holding a list of options, one of them selected.
///
/// This is the shape shared by the currency, language, date-format and
/// decimal-format drawers. It owns the layout and the search filtering, and
/// nothing else: the app supplies the [options] with their translated labels,
/// the currently [selected] value, and what to do [onSelect].
///
/// Selecting does **not** dismiss the drawer. Persisting the choice is usually
/// async, and the app has to decide whether to pop before or after that
/// settles — so [onSelect] owns the dismissal.
class SelectionDrawer<T> extends StatefulWidget {
  const SelectionDrawer({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelect,
    this.closeSemanticLabel,
    this.search,
  });

  final String title;
  final List<SelectionOption<T>> options;
  final T? selected;
  final ValueChanged<T> onSelect;
  final String? closeSemanticLabel;
  final SelectionDrawerSearch? search;

  @override
  State<SelectionDrawer<T>> createState() => _SelectionDrawerState<T>();
}

class _SelectionDrawerState<T> extends State<SelectionDrawer<T>> {
  String _query = '';

  List<SelectionOption<T>> get _filtered {
    if (_query.isEmpty) return widget.options;

    final q = _query.toLowerCase();
    return widget.options.where((option) {
      return [
        option.label,
        ?option.secondaryLabel,
        ...option.searchTerms,
      ].any((term) => term.toLowerCase().contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final search = widget.search;
    final options = _filtered;

    SelectionRow rowAt(int index) {
      final option = options[index];

      return SelectionRow(
        label: option.label,
        secondaryLabel: option.secondaryLabel,
        leading: option.leading,
        selected: option.value == widget.selected,
        showDivider: index != options.length - 1,
        onTap: () => widget.onSelect(option.value),
      );
    }

    // A `Column` sizes the sheet to its rows; a `ListView` fills the height it
    // is offered. Short lists keep the `Column` so the sheet still hugs them,
    // and only a list long enough to fill the sheet anyway is built lazily --
    // which is why the swap is invisible. See
    // [kSelectionDrawerLazyThreshold].
    final list = options.length > kSelectionDrawerLazyThreshold
        ? ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: options.length,
            itemBuilder: (context, index) => rowAt(index),
          )
        : SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (var index = 0; index < options.length; index++)
                  rowAt(index),
              ],
            ),
          );

    return BottomDrawer(
      title: widget.title,
      closeSemanticLabel: widget.closeSemanticLabel,
      child: search == null
          ? list
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Search(
                  value: _query,
                  placeholder: search.placeholder,
                  size: SearchSize.sm,
                  // Filtering a list already in memory, so there's nothing to
                  // debounce.
                  enableDebounce: false,
                  onChange: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 16),
                if (options.isEmpty)
                  _SearchEmptyState(
                    search: search,
                    onClear: () => setState(() => _query = ''),
                  )
                else
                  Flexible(child: list),
              ],
            ),
    );
  }
}

/// One row of a [SelectionDrawer]: an optional [leading] widget, one or two
/// lines of text, and a check mark when [selected].
class SelectionRow extends StatelessWidget {
  const SelectionRow({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.secondaryLabel,
    this.leading,
    this.showDivider = true,
  });

  final String label;
  final String? secondaryLabel;
  final Widget? leading;
  final bool selected;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final secondary = secondaryLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 12)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        label,
                        style: context.bitcrText
                            .textMdMedium(color: colors.text300)
                            .copyWith(letterSpacing: 0),
                      ),
                      if (secondary != null)
                        Text(
                          secondary,
                          style: context.bitcrText.textSmRegular(
                            color: colors.text200,
                          ),
                        ),
                    ],
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 16),
                  Icon(
                    LucideIcons.check200,
                    size: 24,
                    color: colors.text300,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (showDivider) Container(height: 1, color: colors.divider75),
      ],
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({required this.search, required this.onClear});

  final SelectionDrawerSearch search;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              search.emptyTitle,
              textAlign: TextAlign.center,
              style: context.bitcrText.textMdMedium(color: colors.text300),
            ),
            const SizedBox(height: 4),
            Text(
              search.emptySubtitle,
              textAlign: TextAlign.center,
              style: context.bitcrText.textSmRegular(color: colors.text200),
            ),
            const SizedBox(height: 16),
            Button(
              variant: ButtonVariant.outline,
              buttonSize: ButtonSize.small,
              onPressed: onClear,
              child: Text(search.clearLabel),
            ),
          ],
        ),
      ),
    );
  }
}
