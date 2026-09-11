import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/radii.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Utility: visual width
bool _isWideCodePoint(int cp) =>
    (cp >= 0x1100 && cp <= 0x115f) ||
    (cp >= 0x2329 && cp <= 0x232a) ||
    (cp >= 0x2600 && cp <= 0x27bf) ||
    (cp >= 0x2e80 && cp <= 0xa4cf) ||
    (cp >= 0xac00 && cp <= 0xd7a3) ||
    (cp >= 0xf900 && cp <= 0xfaff) ||
    (cp >= 0xfe10 && cp <= 0xfe19) ||
    (cp >= 0xfe30 && cp <= 0xfe6f) ||
    (cp >= 0xff00 && cp <= 0xff60) ||
    (cp >= 0xffe0 && cp <= 0xffe6) ||
    (cp >= 0x1f300 && cp <= 0x1faff) ||
    (cp >= 0x20000 && cp <= 0x3fffd);

/// Counts double-width code points as two columns, so a CJK or emoji string
/// isn't truncated to twice the intended width.
int visualWidth(String value) {
  int total = 0;
  for (final rune in value.runes) {
    total += _isWideCodePoint(rune) ? 2 : 1;
  }
  return total;
}

/// Utility: RTL detection
final _rtlPattern = RegExp(r'[֐-ࣿיִ-﷽ﹰ-ﻼ]');

bool containsRtl(String value) => _rtlPattern.hasMatch(value);

/// Utility: node-ID heuristic  (bitcr1…)
final _nodeIdPattern = RegExp(
  r'^bitcr1[023456789acdefghjklmnpqrstuvwxyz]{20,}$',
  caseSensitive: false,
);

bool isLikelyNodeId(String value) => _nodeIdPattern.hasMatch(value.trim());

/// Truncation helpers
List<String> _graphemes(String value) {
  /// Dart doesn't expose Intl.Segmenter, so we split by runes (close enough
  /// for the characters this app handles; multi-codepoint emoji still work
  /// because we iterate runes and re-encode them).
  return value.runes.map(String.fromCharCode).toList();
}

String _truncateEnd(String value, int maxLength) {
  final chars = _graphemes(value);
  if (chars.length <= maxLength) return value;
  final keep = (maxLength - 1).clamp(1, maxLength).toInt();
  return '${chars.take(keep).join()}…'; // …
}

String _truncateMiddle(String value, int maxLength) {
  final chars = _graphemes(value);
  if (chars.length <= maxLength) return value;
  if (maxLength <= 1) return '…';
  if (maxLength <= 3) return '${chars.take(maxLength - 1).join()}…';

  final keepCount = maxLength - 1;
  final headCount = (keepCount / 2).ceil();
  final tailCount = (keepCount / 2).floor();

  return '${chars.take(headCount).join()}…${chars.skip(chars.length - tailCount).join()}';
}

String _truncateWithSafeguard(String line, int maxLength, _TruncMode mode) {
  if (line.length <= maxLength && visualWidth(line) <= maxLength) return line;

  final useEnd = mode == _TruncMode.end || containsRtl(line);
  var effective = maxLength;
  var candidate = useEnd
      ? _truncateEnd(line, effective)
      : _truncateMiddle(line, effective);

  while (visualWidth(candidate) > maxLength && effective > 1) {
    effective -= 1;
    candidate = useEnd
        ? _truncateEnd(line, effective)
        : _truncateMiddle(line, effective);
  }

  return candidate;
}

enum _TruncMode { end, middle }

/// Public API
enum TruncationMode { auto, end, middle }

/// A text widget that truncates long strings and reveals the full content in a
/// dialog on tap.
///
/// - `TruncationMode.middle`  — always truncate in the middle.
/// - `TruncationMode.end`     — always truncate at the end.
/// - `TruncationMode.auto`    — middle for node IDs, end for ASCII-only text
///   with an explicit [maxLength]; for everything else the OS text-overflow
///   ellipsis is used and the dialog is shown only when the text actually
///   overflows its layout box.
///
/// With [showCopyButton], the widget writes to the clipboard itself and calls
/// [onCopied] — show the confirmation toast there, so the app decides how a
/// copy is confirmed.
class TruncatedTextPopover extends StatefulWidget {
  const TruncatedTextPopover({
    super.key,
    required this.text,
    this.maxLength,
    this.style,
    this.showCopyButton = false,
    this.copyLabel,
    this.onCopied,
    this.truncationMode = TruncationMode.auto,
    this.maxLines = 1,
    this.underlineOnTruncate = true,
    this.copyButtonSpacing = 6,
  }) : assert(
         !showCopyButton || copyLabel != null,
         'showCopyButton needs copyLabel: the library ships no strings of its '
         'own, so the app has to supply the translated label.',
       );

  final String text;

  /// Character budget for computed truncation. When omitted, defaults to 24
  /// for explicit modes; in `auto` mode the widget falls back to layout-based
  /// overflow detection.
  final int? maxLength;

  final TextStyle? style;
  final bool showCopyButton;

  /// Tooltip on the trigger's copy button, and the visible label on the
  /// dialog's. Required when [showCopyButton] is set.
  final String? copyLabel;

  /// Called after the text has been written to the clipboard.
  final VoidCallback? onCopied;

  final TruncationMode truncationMode;

  /// Maximum lines shown in the trigger. Defaults to 1.
  final int maxLines;

  /// Whether the trigger text gets a dashed underline when truncated.
  final bool underlineOnTruncate;

  /// Horizontal gap between the trigger text and the copy button.
  final double copyButtonSpacing;

  @override
  State<TruncatedTextPopover> createState() => _TruncatedTextPopoverState();
}

class _TruncatedTextPopoverState extends State<TruncatedTextPopover> {
  static const _minMaxLength = 4;

  bool _hasLayoutOverflow = false;

  late String _displayText;
  late bool _hasComputedTruncation;
  late bool _usesMaxLengthTruncation;
  late int _currentMaxLength;

  @override
  void initState() {
    super.initState();
    _currentMaxLength = widget.maxLength ?? 24;
    _compute();
  }

  @override
  void didUpdateWidget(TruncatedTextPopover old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text ||
        old.maxLength != widget.maxLength ||
        old.truncationMode != widget.truncationMode) {
      _currentMaxLength = widget.maxLength ?? 24;
      _compute();
    }
  }

  void _compute() {
    final effectiveMaxLength = _currentMaxLength;
    final line = widget.text;

    String computed;
    var usesMaxLength = true;

    switch (widget.truncationMode) {
      case TruncationMode.middle:
        computed = _truncateWithSafeguard(
          line,
          effectiveMaxLength,
          _TruncMode.middle,
        );
      case TruncationMode.end:
        computed = _truncateWithSafeguard(
          line,
          effectiveMaxLength,
          _TruncMode.end,
        );
      case TruncationMode.auto:
        if (isLikelyNodeId(line)) {
          computed = _truncateWithSafeguard(
            line,
            effectiveMaxLength,
            _TruncMode.middle,
          );
        } else if (widget.maxLength != null &&
            !containsRtl(line) &&
            visualWidth(line) == line.length &&
            (line.length > effectiveMaxLength ||
                visualWidth(line) > effectiveMaxLength)) {
          computed = _truncateWithSafeguard(
            line,
            effectiveMaxLength,
            _TruncMode.end,
          );
        } else {
          computed = line;
          usesMaxLength = false;
        }
    }

    _displayText = computed;
    _hasComputedTruncation = computed != line;
    _usesMaxLengthTruncation = usesMaxLength;
  }

  bool get _shouldShowPopover => _hasComputedTruncation || _hasLayoutOverflow;

  void _onTap() {
    if (!_shouldShowPopover) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => _FullTextDialog(
        text: widget.text,
        showCopyButton: widget.showCopyButton,
        copyLabel: widget.copyLabel,
        onCopied: widget.onCopied,
        style: widget.style,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textWidget = LayoutBuilder(
      builder: (context, constraints) {
        final textDirection = Directionality.of(context);
        // Measure with what the Text below actually renders with, not with
        // `widget.style` alone: the family (Geist) comes from the ambient
        // DefaultTextStyle, and the user's text scale from the MediaQuery.
        // Measuring without either compares Geist-at-scale layout against
        // fallback-font-at-1x metrics, so the overflow check misfires.
        final measuredStyle = DefaultTextStyle.of(
          context,
        ).style.merge(widget.style);
        final textScaler = MediaQuery.textScalerOf(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final tp = TextPainter(
            text: TextSpan(text: _displayText, style: measuredStyle),
            maxLines: widget.maxLines,
            textDirection: textDirection,
            textScaler: textScaler,
          )..layout(maxWidth: constraints.maxWidth);
          final overflows =
              tp.didExceedMaxLines || tp.width > constraints.maxWidth + 0.5;

          // Character-count truncation assumes a roughly fixed glyph width,
          // which varies by platform font metrics. If the computed string
          // still doesn't fit the real layout, shrink it further so Flutter's
          // own ellipsis never has to clip on top of our "…" and double up.
          if (_usesMaxLengthTruncation &&
              overflows &&
              _currentMaxLength > _minMaxLength) {
            setState(() {
              _currentMaxLength -= 1;
              _compute();
            });
            return;
          }

          if (!_usesMaxLengthTruncation && overflows != _hasLayoutOverflow) {
            setState(() => _hasLayoutOverflow = overflows);
          }
        });

        return Text(
          _displayText,
          style: _shouldShowPopover && widget.underlineOnTruncate
              ? (widget.style ?? const TextStyle()).copyWith(
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dashed,
                )
              : widget.style,
          maxLines: widget.maxLines,
          overflow: TextOverflow.ellipsis,
        );
      },
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: _shouldShowPopover
              ? GestureDetector(
                  onTap: _onTap,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: textWidget,
                  ),
                )
              : textWidget,
        ),
        if (widget.showCopyButton) ...[
          SizedBox(width: widget.copyButtonSpacing),
          _CopyButton(
            value: widget.text,
            label: widget.copyLabel!,
            onCopied: widget.onCopied,
          ),
        ],
      ],
    );
  }
}

/// Full-text dialog
class _FullTextDialog extends StatelessWidget {
  const _FullTextDialog({
    required this.text,
    required this.showCopyButton,
    required this.copyLabel,
    required this.onCopied,
    this.style,
  });

  final String text;
  final bool showCopyButton;
  final String? copyLabel;
  final VoidCallback? onCopied;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return Dialog(
      backgroundColor: colors.elevation50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BitcrRadius.lg),
        side: BorderSide(color: colors.divider75),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 320, maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: SelectableText(
                    text,
                    textAlign: TextAlign.center,
                    // Deliberately overrides the trigger's style: the dialog
                    // shows the value plainly, without the dashed underline
                    // that marks it as truncated.
                    style: (style ?? const TextStyle()).copyWith(
                      fontSize: 14,
                      color: colors.text300,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
              if (showCopyButton) ...[
                const SizedBox(height: 12),
                _CopyButton(
                  value: text,
                  label: copyLabel!,
                  onCopied: onCopied,
                  labeled: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Copy button
class _CopyButton extends StatelessWidget {
  const _CopyButton({
    required this.value,
    required this.label,
    required this.onCopied,
    this.labeled = false,
  });

  final String value;
  final String label;
  final VoidCallback? onCopied;
  final bool labeled;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 16,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      tooltip: label,
      icon: labeled
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.copy200, size: 16),
                const SizedBox(width: 4),
                Text(label, style: const TextStyle(fontSize: 13)),
              ],
            )
          : const Icon(LucideIcons.copy200),
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: value));
        onCopied?.call();
      },
    );
  }
}
