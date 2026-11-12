import 'dart:math' as math;

import 'package:bitcr_ui/src/core/separator.dart';
import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/radii.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/material.dart';

const List<BoxShadow> _menuShadows = [
  BoxShadow(
    color: Color.fromRGBO(27, 15, 0, 0.03),
    offset: Offset(0, 4),
    blurRadius: 6,
    spreadRadius: -2,
  ),
  BoxShadow(
    color: Color.fromRGBO(27, 15, 0, 0.08),
    offset: Offset(0, 12),
    blurRadius: 16,
    spreadRadius: -4,
  ),
];

// position where the menu lines up against its trigger
enum DropdownAlignment { start, center, end }

class Dropdown extends StatefulWidget {
  const Dropdown({
    super.key,
    required this.items,
    required this.child,
    this.alignment = DropdownAlignment.center,
    this.width,
    this.maxHeight = 360,
    this.offset = 4,
    this.padding = const EdgeInsets.all(4),
    this.radius = BitcrRadius.sm,
    this.disabled = false,
    this.semanticLabel,
    this.onOpenChanged,
  });

  final List<Widget> items;
  final Widget child;
  final DropdownAlignment alignment;
  final double? width;
  final double maxHeight;
  final double offset;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool disabled;
  final String? semanticLabel;
  final ValueChanged<bool>? onOpenChanged;

  static const double minWidth = 128;
  static const double screenMargin = 8;

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  final _controller = OverlayPortalController();

  var _open = false;

  void _setOpen(bool open) {
    if (!mounted || open == _open) return;

    setState(() => _open = open);

    open ? _controller.show() : _controller.hide();

    widget.onOpenChanged?.call(open);
  }

  @override
  void didUpdateWidget(Dropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.disabled && _open) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _setOpen(false));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.disabled) return widget.child;

    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: _buildOverlay,
      child: Semantics(
        button: true,
        expanded: _open,
        label: widget.semanticLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _setOpen(!_open),
          child: widget.child,
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final trigger = this.context.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;

    if (trigger == null || !trigger.hasSize || overlay == null) {
      return const SizedBox.shrink();
    }

    final anchor =
        trigger.localToGlobal(Offset.zero, ancestor: overlay) & trigger.size;

    return _DropdownScope(
      close: () => _setOpen(false),
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _setOpen(false),
            ),
          ),
          Positioned.fill(
            child: CustomSingleChildLayout(
              delegate: _DropdownLayout(
                anchor: anchor,
                alignment: widget.alignment,
                textDirection: Directionality.of(context),
                width: widget.width,
                maxHeight: widget.maxHeight,
                offset: widget.offset,
                safeArea: MediaQuery.paddingOf(context),
              ),
              child: _DropdownPanel(
                items: widget.items,
                padding: widget.padding,
                radius: widget.radius,
                fitsItems: widget.width == null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownScope extends InheritedWidget {
  const _DropdownScope({required this.close, required super.child});

  final VoidCallback close;

  static _DropdownScope? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_DropdownScope>();

  @override
  bool updateShouldNotify(_DropdownScope oldWidget) => false;
}

class _DropdownLayout extends SingleChildLayoutDelegate {
  const _DropdownLayout({
    required this.anchor,
    required this.alignment,
    required this.textDirection,
    required this.width,
    required this.maxHeight,
    required this.offset,
    required this.safeArea,
  });

  final Rect anchor;
  final DropdownAlignment alignment;
  final TextDirection textDirection;
  final double? width;
  final double maxHeight;
  final double offset;
  final EdgeInsets safeArea;

  static const double _margin = Dropdown.screenMargin;

  double _spaceBelow(Size size) =>
      size.height - safeArea.bottom - _margin - anchor.bottom - offset;

  double _spaceAbove() => anchor.top - offset - safeArea.top - _margin;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final available = math.max(constraints.maxWidth - _margin * 2, 0.0);
    final fixed = width == null ? null : math.min(width!, available);
    final room = math.max(_spaceBelow(constraints.biggest), _spaceAbove());

    return BoxConstraints(
      minWidth: fixed ?? math.min(Dropdown.minWidth, available),
      maxWidth: fixed ?? available,
      maxHeight: math.max(math.min(maxHeight, room), 0),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final isRtl = textDirection == TextDirection.rtl;

    final left = switch (alignment) {
      DropdownAlignment.center => anchor.center.dx - childSize.width / 2,
      DropdownAlignment.start when isRtl => anchor.right - childSize.width,
      DropdownAlignment.end when !isRtl => anchor.right - childSize.width,
      _ => anchor.left,
    };

    final below = anchor.bottom + offset;
    final fitsBelow =
        below + childSize.height <= size.height - safeArea.bottom - _margin;
    final opensBelow = fitsBelow || _spaceBelow(size) >= _spaceAbove();

    return Offset(
      left.clamp(
        _margin,
        math.max(_margin, size.width - _margin - childSize.width),
      ),
      opensBelow ? below : anchor.top - offset - childSize.height,
    );
  }

  @override
  bool shouldRelayout(_DropdownLayout oldDelegate) =>
      anchor != oldDelegate.anchor ||
      alignment != oldDelegate.alignment ||
      textDirection != oldDelegate.textDirection ||
      width != oldDelegate.width ||
      maxHeight != oldDelegate.maxHeight ||
      offset != oldDelegate.offset ||
      safeArea != oldDelegate.safeArea;
}

class _DropdownPanel extends StatelessWidget {
  const _DropdownPanel({
    required this.items,
    required this.padding,
    required this.radius,
    required this.fitsItems,
  });

  final List<Widget> items;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool fitsItems;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    Widget list = SingleChildScrollView(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items,
      ),
    );

    if (fitsItems) list = IntrinsicWidth(child: list);

    return Material(
      type: MaterialType.transparency,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.elevation50,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: colors.divider75),
          boxShadow: _menuShadows,
        ),
        child: DefaultTextStyle.merge(
          style: context.bitcrText.textSmRegular(color: colors.text300),
          child: IconTheme.merge(
            data: IconThemeData(size: 16, color: colors.text300),
            child: list,
          ),
        ),
      ),
    );
  }
}

class DropdownItem extends StatelessWidget {
  const DropdownItem({
    super.key,
    required this.child,
    this.leading,
    this.trailing,
    this.onTap,
    this.disabled = false,
    this.closeOnTap = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
  });

  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool disabled;
  final bool closeOnTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final onTap = this.onTap;
    final isActive = !disabled && onTap != null;

    return Opacity(
      opacity: isActive ? 1 : 0.5,
      child: InkWell(
        onTap: isActive
            ? () {
                if (closeOnTap) _DropdownScope.maybeOf(context)?.close();

                onTap();
              }
            : null,
        borderRadius: BorderRadius.circular(BitcrRadius.xxs),
        child: Padding(
          padding: padding,
          child: Row(
            spacing: 8,
            children: [
              ?leading,
              Expanded(child: child),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class DropdownSeparator extends StatelessWidget {
  const DropdownSeparator({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Separator(color: color),
  );
}
