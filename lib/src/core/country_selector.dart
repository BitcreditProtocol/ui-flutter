import 'dart:math' as math;

import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons_200.dart';

const _panelBorder = Color(0x4D1B0F00);
const _checkColor = Color(0xFF006F29);

const _itemHeight = 40.0;
const _itemGap = 4.0;

class CountryOption {
  const CountryOption({
    required this.code,
    required this.name,
    this.searchTerms = const [],
  });

  final String code;
  final String name;
  final List<String> searchTerms;
}

class CountrySelector extends StatefulWidget {
  const CountrySelector({
    super.key,
    required this.controller,
    required this.label,
    required this.countries,
    required this.searchPlaceholder,
    required this.noResultsLabel,
    this.clearLabel,
    this.clearSearchLabel,
    this.isRequired = false,
    this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final List<CountryOption> countries;
  final String searchPlaceholder;
  final String noResultsLabel;
  final String? clearLabel;
  final String? clearSearchLabel;
  final bool isRequired;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  @override
  State<CountrySelector> createState() => _CountrySelectorState();
}

class _CountrySelectorState extends State<CountrySelector>
    with WidgetsBindingObserver {
  final _field = GlobalKey<FormFieldState<String>>();
  final _trigger = GlobalKey();
  final _link = LayerLink();
  final _portal = OverlayPortalController();
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  final _tapGroup = Object();

  ({bool isBelow, double maxHeight, double width})? _position;

  static const _roomBelow = 220.0;
  static const _topBarClearance = 56.0;

  static bool get _isPhone =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.addListener(_syncField);
  }

  @override
  void didUpdateWidget(CountrySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncField);
      widget.controller.addListener(_syncField);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.removeListener(_syncField);
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (_portal.isShowing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _keepVisible());
    }
  }

  void _keepVisible() {
    final trigger = _trigger.currentContext;
    if (!mounted || trigger == null) return;

    Scrollable.ensureVisible(
      trigger,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
    );
    _makeRoomBelow();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reposition());
  }

  void _makeRoomBelow() {
    if (!_isPhone) return;

    final trigger = _trigger.currentContext;
    final box = trigger?.findRenderObject() as RenderBox?;
    if (trigger == null || box == null || !box.attached) return;

    final position = Scrollable.maybeOf(trigger)?.position;
    if (position == null) return;

    final window = MediaQueryData.fromView(View.of(context));
    final viewBottom =
        window.size.height -
        math.max(window.viewInsets.bottom, window.padding.bottom);
    final bottom = box.localToGlobal(Offset.zero).dy + box.size.height;
    final missing = _roomBelow - (viewBottom - 16 - bottom);

    if (missing <= 0) return;

    position.jumpTo(
      math.min(position.pixels + missing + 16, position.maxScrollExtent),
    );
  }

  void _syncField() {
    final field = _field.currentState;
    if (field != null && field.value != widget.controller.text) {
      field.didChange(widget.controller.text);
    }
  }

  void _select(String code) {
    widget.controller.text = code;
    _field.currentState?.didChange(code);
    widget.onChanged?.call(code);
  }

  void _toggle() => _portal.isShowing ? _close() : _open();

  void _open() {
    final trigger = _trigger.currentContext;
    if (trigger == null) return;

    Scrollable.ensureVisible(trigger, alignment: 0.5);
    _reposition();
    setState(_portal.show);
    _searchFocus.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _makeRoomBelow();
      WidgetsBinding.instance.addPostFrameCallback((_) => _reposition());
    });
  }

  void _close() {
    if (!_portal.isShowing) return;

    _searchFocus.unfocus();
    setState(_portal.hide);
  }

  void _reposition() {
    if (!mounted) return;
    final box = _trigger.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;

    final rect = box.localToGlobal(Offset.zero) & box.size;
    final window = MediaQueryData.fromView(View.of(context));
    final viewBottom =
        window.size.height -
        math.max(window.viewInsets.bottom, window.padding.bottom);
    final above = math.max(
      0.0,
      rect.top - window.padding.top - _topBarClearance - 16,
    );
    final below = math.max(0.0, viewBottom - rect.bottom - 16);
    final isBelow = below >= (_isPhone ? _roomBelow : 240) || below >= above;
    final room = (isBelow ? below : above).floorToDouble();
    final position = (
      isBelow: isBelow,
      maxHeight: math.min(room, 400.0),
      width: math.max(rect.width, 300.0),
    );

    if (position != _position) setState(() => _position = position);
  }

  String? _nameOf(String code) {
    final upper = code.toUpperCase();

    for (final country in widget.countries) {
      if (country.code.toUpperCase() == upper) return country.name;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_portal.isShowing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: FormField<String>(
        key: _field,
        initialValue: widget.controller.text,
        validator: widget.validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        builder: (field) {
          final colors = BitcrColors.of(context);
          final code = field.value ?? '';
          final errorText = field.errorText;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              TapRegion(
                groupId: _tapGroup,
                child: CompositedTransformTarget(
                  link: _link,
                  child: OverlayPortal(
                    controller: _portal,
                    overlayChildBuilder: _buildPanel,
                    child: _Trigger(
                      key: _trigger,
                      label: widget.label,
                      name: code.isEmpty ? '' : _nameOf(code) ?? '',
                      hasValue: code.isNotEmpty,
                      isRequired: widget.isRequired,
                      isOpen: _portal.isShowing,
                      hasError: errorText != null,
                      clearLabel: widget.clearLabel,
                      onTap: _toggle,
                      onClear: () => _select(''),
                    ),
                  ),
                ),
              ),
              if (errorText != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Text(
                    errorText,
                    style: context.bitcrText
                        .textXsRegular(color: colors.signalError)
                        .copyWith(height: 16 / 12),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPanel(BuildContext context) {
    final position = _position;
    if (position == null) return const SizedBox.shrink();

    final anchor = position.isBelow
        ? (Alignment.bottomCenter, Alignment.topCenter, const Offset(0, 6))
        : (Alignment.topCenter, Alignment.bottomCenter, const Offset(0, -6));

    return Align(
      alignment: Alignment.topLeft,
      child: CompositedTransformFollower(
        link: _link,
        targetAnchor: anchor.$1,
        followerAnchor: anchor.$2,
        offset: anchor.$3,
        child: TapRegion(
          groupId: _tapGroup,
          onTapOutside: (_) => _close(),
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.escape): _close,
            },
            child: SizedBox(
              width: position.width,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: position.maxHeight),
                child: Semantics(
                  container: true,
                  explicitChildNodes: true,
                  child: _Panel(
                    value: widget.controller.text.toUpperCase(),
                    countries: widget.countries,
                    search: _search,
                    searchFocus: _searchFocus,
                    searchPlaceholder: widget.searchPlaceholder,
                    noResultsLabel: widget.noResultsLabel,
                    clearSearchLabel: widget.clearSearchLabel,
                    onSelect: (code) {
                      _select(code);
                      _close();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Trigger extends StatelessWidget {
  const _Trigger({
    super.key,
    required this.label,
    required this.name,
    required this.hasValue,
    required this.isRequired,
    required this.isOpen,
    required this.hasError,
    required this.clearLabel,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final String name;
  final bool hasValue;
  final bool isRequired;
  final bool isOpen;
  final bool hasError;
  final String? clearLabel;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final text = context.bitcrText;
    const duration = Duration(milliseconds: 200);

    final labelStyle = hasValue
        ? text.textXsRegular(color: colors.text200).copyWith(height: 16 / 12)
        : text.textSmMedium(color: colors.text300);

    return Semantics(
      button: true,
      expanded: isOpen,
      label: isRequired ? '$label *' : label,
      value: name,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: colors.elevation200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasError ? colors.signalError : colors.divider50,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons200.earth,
                        size: 20,
                        color: colors.text300,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: duration,
                              curve: Curves.easeInOut,
                              style: labelStyle,
                              child: Text.rich(
                                TextSpan(
                                  text: label,
                                  children: [
                                    if (isRequired)
                                      TextSpan(
                                        text: '*',
                                        style: TextStyle(
                                          color: hasValue
                                              ? colors.text200
                                              : colors.signalError,
                                        ),
                                      ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasValue)
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.textSmMedium(color: colors.text300),
                              ),
                          ],
                        ),
                      ),
                      if (hasValue) const SizedBox(width: 24),
                      SizedBox(
                        width: 24,
                        child: Icon(
                          isOpen
                              ? LucideIcons200.chevronUp
                              : LucideIcons200.chevronDown,
                          size: 16,
                          color: colors.text300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (hasValue)
              Positioned(
                right: 40,
                top: 0,
                bottom: 0,
                child: Semantics(
                  button: true,
                  label: clearLabel,
                  excludeSemantics: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onClear,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        LucideIcons200.x,
                        size: 16,
                        color: colors.text300,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatefulWidget {
  const _Panel({
    required this.value,
    required this.countries,
    required this.search,
    required this.searchFocus,
    required this.searchPlaceholder,
    required this.noResultsLabel,
    required this.clearSearchLabel,
    required this.onSelect,
  });

  final String value;
  final List<CountryOption> countries;
  final TextEditingController search;
  final FocusNode searchFocus;
  final String searchPlaceholder;
  final String noResultsLabel;
  final String? clearSearchLabel;
  final ValueChanged<String> onSelect;

  @override
  State<_Panel> createState() => _PanelState();
}

class _PanelState extends State<_Panel> {
  final _scroll = ScrollController();
  late List<(CountryOption, String)> _options = _index(widget.countries);
  int _highlighted = 0;

  static List<(CountryOption, String)> _index(List<CountryOption> countries) =>
      [
        for (final country in countries)
          (
            country,
            [
              country.name,
              ...country.searchTerms,
              country.code,
            ].join(' ').toLowerCase(),
          ),
      ];

  @override
  void initState() {
    super.initState();
    widget.search.addListener(_onSearch);
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealSelected());
  }

  @override
  void didUpdateWidget(_Panel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.countries, widget.countries)) {
      _options = _index(widget.countries);
    }
  }

  @override
  void dispose() {
    widget.search.removeListener(_onSearch);
    _scroll.dispose();
    super.dispose();
  }

  void _onSearch() => setState(() => _highlighted = 0);

  bool _isSelected(CountryOption country) =>
      country.code.toUpperCase() == widget.value;

  void _revealSelected() {
    final index = _filtered.indexWhere(_isSelected);
    if (index < 0 || !_scroll.hasClients) return;

    final position = _scroll.position;
    final itemBottom =
        _itemGap + index * (_itemHeight + _itemGap) + _itemHeight;
    final offset = itemBottom - position.viewportDimension;
    if (offset > position.pixels) {
      _scroll.jumpTo(offset.clamp(0.0, position.maxScrollExtent));
    }
  }

  List<CountryOption> get _filtered {
    final query = widget.search.text.toLowerCase();

    return [
      for (final (country, searchable) in _options)
        if (searchable.contains(query)) country,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final textStyle = context.bitcrText.textSmRegular(color: colors.text300);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchBackground = isDark ? colors.elevation200 : colors.elevation50;
    final filtered = _filtered;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.elevation50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _panelBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              offset: Offset(0, 4),
              blurRadius: 6,
              spreadRadius: -1,
            ),
            BoxShadow(
              color: Color(0x1A000000),
              offset: Offset(0, 2),
              blurRadius: 4,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: searchBackground,
                border: const Border(bottom: BorderSide(color: _panelBorder)),
              ),
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextField(
                    controller: widget.search,
                    focusNode: widget.searchFocus,
                    style: textStyle,
                    cursorColor: colors.text300,
                    decoration: InputDecoration(
                      hintText: widget.searchPlaceholder,
                      hintStyle: textStyle,
                      filled: false,
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.fromLTRB(16, 16, 40, 16),
                    ),
                  ),
                  if (widget.search.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Semantics(
                        button: true,
                        label: widget.clearSearchLabel,
                        excludeSemantics: true,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: widget.search.clear,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: searchBackground,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              LucideIcons200.x,
                              size: 16,
                              color: colors.text300,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  widget.noResultsLabel,
                  textAlign: TextAlign.center,
                  style: textStyle,
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  controller: _scroll,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(4),
                  itemExtent: _itemHeight + _itemGap,
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final country = filtered[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: _itemGap),
                      child: _Item(
                        name: country.name,
                        isSelected: _isSelected(country),
                        isHighlighted: index == _highlighted,
                        onHover: () => setState(() => _highlighted = index),
                        onTap: () => widget.onSelect(country.code),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.name,
    required this.isSelected,
    required this.isHighlighted,
    required this.onHover,
    required this.onTap,
  });

  final String name;
  final bool isSelected;
  final bool isHighlighted;
  final VoidCallback onHover;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return Semantics(
      button: true,
      selected: isSelected,
      child: MouseRegion(
        onEnter: (_) => onHover(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => onHover(),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isHighlighted ? colors.elevation250 : null,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Opacity(
                  opacity: isSelected ? 1 : 0,
                  child: const Icon(
                    LucideIcons200.check,
                    size: 16,
                    color: _checkColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.bitcrText.textSmMedium(
                      color: colors.text300,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
