import 'dart:async';

import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/radii.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum SearchSize { xs, sm, md, lg }

/// The search input: a leading magnifier, a clear button that fades in once
/// there's text, and hover/focus states on the border.
///
/// Works controlled or uncontrolled. Pass [value] and the field mirrors it —
/// the app owns the query. Leave it null and the field keeps its own text.
///
/// [onChange] fires on every keystroke; [onSearch] is the debounced one to
/// hang an actual query off, and it flushes immediately on submit and on
/// clear so those feel instant.
class Search extends StatefulWidget {
  const Search({
    super.key,
    this.value,
    required this.placeholder,
    this.size = SearchSize.md,
    this.onChange,
    this.onFocus,
    this.onBlur,
    this.onSearch,
    this.enableDebounce = true,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.autofocus = false,
  });

  final String? value;
  final String placeholder;
  final SearchSize size;
  final ValueChanged<String>? onChange;
  final VoidCallback? onFocus;
  final VoidCallback? onBlur;
  final ValueChanged<String>? onSearch;
  final bool enableDebounce;
  final Duration debounceDuration;

  /// Takes focus on first build. For a surface that exists to be searched --
  /// a picker over a long list -- reaching for the pointer first defeats it.
  final bool autofocus;

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isFocused = false;
  bool _isHovered = false;
  Brightness? _lastBrightness;
  Timer? _debounceTimer;

  bool get _isControlled => widget.value != null;

  String get _currentValue => _isControlled ? widget.value! : _controller.text;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
    _focusNode = FocusNode()
      ..addListener(() {
        setState(() => _isFocused = _focusNode.hasFocus);
        if (_focusNode.hasFocus) {
          widget.onFocus?.call();
        } else {
          widget.onBlur?.call();
        }
      });
  }

  @override
  void didUpdateWidget(Search oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isControlled && widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value!,
        selection: TextSelection.collapsed(offset: widget.value!.length),
      );
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateValue(String next) {
    if (!_isControlled) {
      _controller.text = next;
    }
    widget.onChange?.call(next);
    _scheduleSearch(next);
  }

  void _scheduleSearch(String query) {
    if (!widget.enableDebounce) {
      widget.onSearch?.call(query);
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onSearch?.call(query);
    });
  }

  void _flushDebounce(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    widget.onSearch?.call(query);
  }

  void _clearValue() {
    _updateValue('');
    if (widget.enableDebounce) {
      _flushDebounce('');
    }
  }

  EdgeInsets get _padding => switch (widget.size) {
    SearchSize.xs => const EdgeInsets.all(8),
    SearchSize.sm => const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    SearchSize.md => const EdgeInsets.all(16),
    SearchSize.lg => const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
  };

  double get _searchIconSize => widget.size == SearchSize.xs ? 16 : 20;

  double get _clearIconSize => widget.size == SearchSize.xs ? 12 : 16;

  TextStyle _textStyle(BuildContext context, Color color) {
    final text = context.bitcrText;
    final style = widget.size == SearchSize.xs
        ? text.textXsMedium(color: color)
        : text.textSmMedium(color: color);

    return style.copyWith(letterSpacing: 0);
  }

  Color _backgroundColor(BitcrColors colors) {
    if (_isFocused || _isHovered) return colors.elevation250;
    return colors.elevation50;
  }

  Color _borderColor(BitcrColors colors) {
    if (_isFocused) return colors.divider300;
    if (_isHovered) return colors.divider50;
    return colors.divider75;
  }

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final hasValue = _currentValue.isNotEmpty;
    final style = _textStyle(context, colors.text300);

    // Skip the color transition on a theme flip: animating between the two
    // palettes reads as a lag rather than as a state change.
    final brightness = Theme.of(context).brightness;
    final themeBrightnessChanged =
        _lastBrightness != null && _lastBrightness != brightness;
    _lastBrightness = brightness;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.text,
      child: AnimatedContainer(
        duration: themeBrightnessChanged
            ? Duration.zero
            : const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: _padding,
        decoration: BoxDecoration(
          color: _backgroundColor(colors),
          borderRadius: BorderRadius.circular(BitcrRadius.md),
          border: Border.all(color: _borderColor(colors)),
        ),
        child: Row(
          children: [
            Icon(
              LucideIcons.search,
              size: _searchIconSize,
              color: colors.text300,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                style: style,
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: style,
                  isDense: true,
                  isCollapsed: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                textInputAction: TextInputAction.search,
                onChanged: (v) {
                  if (!_isControlled) setState(() {});
                  widget.onChange?.call(v);
                  _scheduleSearch(v);
                },
                onSubmitted: _flushDebounce,
                onTapOutside: (_) => _focusNode.unfocus(),
                keyboardType: TextInputType.text,
                onEditingComplete: () {
                  _flushDebounce(_currentValue);
                  _focusNode.unfocus();
                },
              ),
            ),
            const SizedBox(width: 6),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              opacity: hasValue ? 1 : 0,
              child: IgnorePointer(
                ignoring: !hasValue,
                child: GestureDetector(
                  onTap: _clearValue,
                  behavior: HitTestBehavior.opaque,
                  child: Icon(
                    LucideIcons.x,
                    size: _clearIconSize,
                    color: colors.text300,
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
