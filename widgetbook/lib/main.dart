import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// Generated from every @UseCase in this package by `dart run build_runner build`
// (or `watch` while you're adding use cases).
import 'main.directories.g.dart';

void main() {
  runApp(const WidgetbookApp());
}

/// Rebuilds the generated tree with every component collapsed, leaving the
/// folders open — so the catalog opens on a list of components rather than
/// every use case at once.
///
/// It has to rebuild rather than `copyWith`: `isInitiallyExpanded` defaults to
/// true on [WidgetbookNode] and isn't part of the `copyWith` signature. Nodes
/// re-parent themselves on construction, so reusing the generated use cases
/// here is safe.
List<WidgetbookNode> _collapseComponents(List<WidgetbookNode> nodes) => [
  for (final node in nodes)
    if (node is WidgetbookComponent)
      WidgetbookComponent(
        name: node.name,
        useCases: node.useCases,
        isInitiallyExpanded: false,
      )
    else if (node is WidgetbookFolder)
      WidgetbookFolder(
        name: node.name,
        children: _collapseComponents(node.children ?? const []),
      )
    else
      node,
];

/// Lets a mouse drag a scrollable, which Flutter does not allow by default:
/// [ScrollBehavior.dragDevices] is touch-like devices only, and a wheel scroll
/// is a pointer signal rather than a drag. On a desktop run that leaves no
/// input that can overscroll, so gestures built on one — `PullToRefresh`
/// above all — are untestable in the catalog.
///
/// Catalog-only on purpose. Shipping it in `BitcrTheme` would let a stray
/// mouse drag scroll lists in the apps' own desktop builds, which is not the
/// platform behaviour.
class _MouseDragScrollBehavior extends MaterialScrollBehavior {
  const _MouseDragScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    ...super.dragDevices,
    PointerDeviceKind.mouse,
  };
}

@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      // Below the app's own ScrollConfiguration, so it wins for the use case.
      appBuilder: (context, child) => materialAppBuilder(
        context,
        ScrollConfiguration(
          behavior: const _MouseDragScrollBehavior(),
          child: child,
        ),
      ),
      directories: _collapseComponents(directories),
      addons: [
        // Viewport has to come first: it wraps everything below it.
        ViewportAddon([
          Viewports.none,
          ...IosViewports.phones,
          ...AndroidViewports.phones,
          ...IosViewports.tablets,
        ]),
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Light', data: BitcrTheme.light),
            WidgetbookTheme(name: 'Dark', data: BitcrTheme.dark),
          ],
        ),
        TextScaleAddon(min: 1, max: 2),
        AlignmentAddon(),
      ],
    );
  }
}
