import 'package:bitcr_ui/src/core/avatar.dart';
import 'package:bitcr_ui/src/navigation/identity_chip.dart';
import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/radii.dart';
import 'package:bitcr_ui/src/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

/// One entry in an [IdentitySwitcher]'s menu.
class IdentityOption<T> {
  const IdentityOption({
    required this.value,
    required this.name,
    this.imageUrl,
  });

  final T value;
  final String name;
  final String? imageUrl;
}

/// An [IdentityChip] that drops a menu of the other identities to switch to,
/// with an optional action row at the bottom.
///
/// The menu hangs from below the topbar, spans the page's width and closes on
/// an outside tap. Selecting closes it and reports the choice — everything
/// that happens next (showing a [SwitchingOverlay], reloading, navigating) is
/// the app's, since only it knows what switching costs.
class IdentitySwitcher<T> extends StatefulWidget {
  const IdentitySwitcher({
    super.key,
    required this.name,
    required this.options,
    required this.selected,
    required this.onSelect,
    this.imageUrl,
    this.loading = false,
    this.footerLabel,
    this.footerIcon,
    this.onFooterTap,
  });

  final String name;
  final String? imageUrl;
  final List<IdentityOption<T>> options;
  final T? selected;
  final ValueChanged<T> onSelect;
  final bool loading;
  final String? footerLabel;
  final IconData? footerIcon;
  final VoidCallback? onFooterTap;

  @override
  State<IdentitySwitcher<T>> createState() => _IdentitySwitcherState<T>();
}

class _IdentitySwitcherState<T> extends State<IdentitySwitcher<T>> {
  final _controller = OverlayPortalController();
  bool _open = false;

  static const double _gutter = 20;
  static const double _menuGap = 8;
  static const double _menuMaxHeight = 360;

  void _toggle() {
    if (!mounted) return;

    setState(() => _open = !_open);

    _open ? _controller.show() : _controller.hide();
  }

  void _close() {
    if (!mounted || !_open) return;

    setState(() => _open = false);

    _controller.hide();
  }

  void _select(T value) {
    _close();
    widget.onSelect(value);
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: _buildOverlay,
      child: IdentityChip(
        name: widget.name,
        imageUrl: widget.imageUrl,
        showChevron: true,
        open: _open,
        onTap: _toggle,
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final topInset =
        MediaQuery.paddingOf(context).top + _menuGap + IdentityChip.minHeight;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _close,
          ),
        ),
        Positioned(
          top: topInset,
          left: _gutter,
          right: _gutter,
          child: _IdentityMenu<T>(
            options: widget.options,
            selected: widget.selected,
            onSelect: _select,
            loading: widget.loading,
            footerLabel: widget.footerLabel,
            footerIcon: widget.footerIcon,
            onFooterTap: widget.onFooterTap == null
                ? null
                : () {
                    _close();
                    widget.onFooterTap!();
                  },
            maxHeight: _menuMaxHeight,
            width: MediaQuery.sizeOf(context).width - _gutter * 2,
          ),
        ),
      ],
    );
  }
}

class _IdentityMenu<T> extends StatelessWidget {
  const _IdentityMenu({
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.loading,
    required this.footerLabel,
    required this.footerIcon,
    required this.onFooterTap,
    required this.maxHeight,
    required this.width,
  });

  final List<IdentityOption<T>> options;
  final T? selected;
  final ValueChanged<T> onSelect;
  final bool loading;
  final String? footerLabel;
  final IconData? footerIcon;
  final VoidCallback? onFooterTap;
  final double maxHeight;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final label = footerLabel;

    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight, maxWidth: width),
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: colors.elevation50,
            borderRadius: BorderRadius.circular(BitcrRadius.lg),
            border: Border.all(color: colors.divider75),
            boxShadow: _menuShadows,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: loading
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: [
                          for (final option in options)
                            _IdentityMenuRow(
                              name: option.name,
                              imageUrl: option.imageUrl,
                              selected: option.value == selected,
                              onTap: () => onSelect(option.value),
                            ),
                        ],
                      ),
              ),
              if (label != null && onFooterTap != null) ...[
                Divider(height: 1, thickness: 1, color: colors.divider75),
                InkWell(
                  onTap: onFooterTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 4,
                      children: [
                        Text(
                          label,
                          style: context.bitcrText
                              .textSmMedium(color: colors.text400)
                              .copyWith(height: 1.42),
                        ),
                        if (footerIcon != null)
                          Icon(footerIcon, size: 16, color: colors.text400),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _IdentityMenuRow extends StatelessWidget {
  const _IdentityMenuRow({
    required this.name,
    required this.imageUrl,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String? imageUrl;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          spacing: 12,
          children: [
            Avatar(
              name: name,
              imageUrl: imageUrl,
              backgroundColor: colors.elevation200,
              borderColor: colors.divider50,
            ),
            Expanded(
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: context.bitcrText.textMdMedium(color: colors.text300),
              ),
            ),
            if (selected)
              Icon(LucideIcons.check300, size: 20, color: colors.text300),
          ],
        ),
      ),
    );
  }
}
