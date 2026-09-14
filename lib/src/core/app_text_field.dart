import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/radii.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The standard text input: elevation surface, 8pt corners, focus and error
/// borders, a floating label and an optional clear button.
///
/// While the field is empty and unfocused, [label] sits on the text line at
/// full size, standing in for the hint. On focus — or as soon as there's a
/// value — it shrinks and rises to its own line above the text. The field
/// itself never moves; only the label animates.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.hasError = false,
    this.isRequired = false,
    this.icon,
    this.trailing,
    this.showClearButton = true,
    this.clearSemanticLabel,
    this.onClear,
    this.onPaste,
    this.pasteSemanticLabel,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.maxLength,
    this.minLines,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.semanticsLabel,
    this.identifier,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool hasError;
  final bool isRequired;
  final IconData? icon;
  final Widget? trailing;
  final bool showClearButton;
  final String? clearSemanticLabel;
  final VoidCallback? onClear;
  final VoidCallback? onPaste;
  final String? pasteSemanticLabel;
  final FocusNode? focusNode;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final String? semanticsLabel;

  /// A stable identifier for end-to-end tests to find this field by, exposed
  /// on the same semantics node as the text field itself.
  ///
  /// It has to sit here rather than on a wrapper at the call site: an
  /// identifier on an ancestor names a node the driver cannot type into.
  final String? identifier;

  static const double minHeight = 52;

  static const EdgeInsets _contentPadding = EdgeInsets.symmetric(
    horizontal: 15,
    vertical: 6,
  );

  static const double _labelHeight = 18;
  static const double _fieldLineHeight = 20;
  static const double _restingLabelHeight = _fieldLineHeight;

  static const double _restingLabelTop =
      (_labelHeight + _fieldLineHeight - _restingLabelHeight) / 2;

  static const Duration _labelDuration = Duration(milliseconds: 150);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  FocusNode? _ownedFocusNode;

  bool _isFocused = false;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _isFocused = _focusNode.hasFocus;
    _focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownedFocusNode)?.removeListener(_onFocusChanged);
      _focusNode.addListener(_onFocusChanged);
      _isFocused = _focusNode.hasFocus;
    }

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    (widget.focusNode ?? _ownedFocusNode)?.removeListener(_onFocusChanged);
    widget.controller.removeListener(_onTextChanged);
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!mounted) return;
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final textStyles = context.bitcrText;
    final hasValue = widget.controller.text.isNotEmpty;
    final isInvalid = widget.hasError || widget.errorText != null;

    final borderColor = isInvalid
        ? colors.signalError
        : _isFocused
        ? colors.divider300
        : colors.divider50;

    final editable = widget.enabled && !widget.readOnly;
    final trailingActions = <Widget>[
      if (editable && widget.showClearButton && hasValue)
        _IconButton(
          icon: LucideIcons.x200,
          color: colors.text300,
          semanticsLabel: widget.clearSemanticLabel,
          onTap: () {
            widget.controller.clear();
            widget.onChanged?.call('');
            widget.onClear?.call();
          },
        ),
      if (editable && widget.onPaste != null && !hasValue)
        _IconButton(
          icon: LucideIcons.clipboard200,
          color: colors.text300,
          semanticsLabel: widget.pasteSemanticLabel,
          onTap: widget.onPaste!,
        ),
      ?widget.trailing,
    ];

    final subtext = widget.errorText ?? widget.helperText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppTextField.minHeight),
          child: Container(
            padding: AppTextField._contentPadding,
            decoration: BoxDecoration(
              color: colors.elevation200,
              borderRadius: BorderRadius.circular(BitcrRadius.md),
              border: Border.all(color: borderColor),
            ),
            child: Semantics(
              identifier: widget.identifier,
              label: widget.semanticsLabel ?? widget.label,
              textField: true,
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _focusNode.requestFocus,
                      child: Icon(widget.icon, size: 20, color: colors.text300),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: _labelledField(
                      context,
                      colors: colors,
                      textStyles: textStyles,
                      isFloating: _isFocused || hasValue,
                    ),
                  ),
                  if (trailingActions.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: trailingActions,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (subtext != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
            child: Text(
              subtext,
              style: textStyles.textXsMedium(
                color: widget.errorText != null
                    ? colors.signalError
                    : colors.text200,
              ),
            ),
          ),
      ],
    );
  }

  /// The field with its floating label stacked over it.
  ///
  /// The label's line is reserved above the field whether or not it's floating,
  /// and the label is drawn in a [Stack] on top: floated it sits in that
  /// reserved line, resting it drops onto the field's own first line. Only the
  /// label moves, so nothing reflows.
  Widget _labelledField(
    BuildContext context, {
    required BitcrColors colors,
    required BitcrTextStyles textStyles,
    required bool isFloating,
  }) {
    final label = widget.label;
    if (label == null) return _field(context, showHint: true);

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppTextField._labelHeight),
            _field(context, showHint: false),
          ],
        ),
        AnimatedPositioned(
          duration: AppTextField._labelDuration,
          curve: Curves.easeOut,
          left: 0,
          right: 0,
          top: isFloating ? 0 : AppTextField._restingLabelTop,
          child: IgnorePointer(
            child: AnimatedDefaultTextStyle(
              duration: AppTextField._labelDuration,
              curve: Curves.easeOut,
              style: isFloating
                  ? textStyles.textXsRegular(color: colors.text200)
                  : textStyles.textSmMedium(color: colors.text200),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              child: Text(widget.isRequired ? '$label*' : label),
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(BuildContext context, {required bool showHint}) {
    final colors = BitcrColors.of(context);
    final textStyles = context.bitcrText;

    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      maxLength: widget.maxLength,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onEditingComplete: widget.onEditingComplete,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      buildCounter: (
        _, {
        required currentLength,
        required isFocused,
        maxLength,
      }) => null,
      cursorColor: colors.text300,
      style: textStyles.textSmMedium(
        color: widget.enabled ? colors.text300 : colors.text200,
      ),
      decoration: InputDecoration(
        hintText: showHint ? widget.hint : null,
        hintStyle: textStyles.textSmMedium(color: colors.text200),
        isDense: true,
        isCollapsed: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.color,
    required this.semanticsLabel,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String? semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      onTap: onTap,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
