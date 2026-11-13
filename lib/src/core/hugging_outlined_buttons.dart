import 'package:material_ui/material_ui.dart';

class HuggingOutlinedButtons extends StatelessWidget {
  const HuggingOutlinedButtons({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: theme.outlinedButtonTheme.style?.copyWith(
            minimumSize: const WidgetStatePropertyAll(Size.zero),
          ),
        ),
      ),
      child: child,
    );
  }
}
