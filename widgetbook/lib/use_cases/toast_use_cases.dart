import 'package:bitcr_ui/bitcr_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Stands in for the app: a toast is imperative, so every case needs something
/// to fire it. The button is the harness, not part of the component.
class _ToastHarness extends StatefulWidget {
  const _ToastHarness({
    this.message = 'Payment sent',
    this.variant = ToastVariant.info,
    this.description,
    this.withAction = false,
    this.showCloseButton = false,
    this.duration = const Duration(seconds: 2),
  });

  final String message;
  final ToastVariant variant;
  final String? description;
  final bool withAction;
  final bool showCloseButton;
  final Duration duration;

  @override
  State<_ToastHarness> createState() => _ToastHarnessState();
}

class _ToastHarnessState extends State<_ToastHarness> {
  ToastController? _pending;
  String _lastAction = '';

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          Button(
            child: const Text('Show toast'),
            onPressed: () {
              _pending = showToast(
                context,
                message: widget.message,
                variant: widget.variant,
                description: widget.description,
                showCloseButton: widget.showCloseButton,
                duration: widget.duration,
                action: widget.withAction
                    ? ToastAction(
                        label: 'Undo',
                        onPressed: () =>
                            setState(() => _lastAction = 'Undo tapped'),
                      )
                    : null,
              );
              setState(() {});
            },
          ),
          // Proves the returned handle: a pending toast the app takes down
          // itself, rather than waiting out the duration.
          Button(
            variant: ButtonVariant.outline,
            onPressed: () => setState(() => _pending?.dismiss()),
            child: const Text('Dismiss last'),
          ),
          Text(
            _lastAction.isEmpty ? ' ' : _lastAction,
            style: context.bitcrText.textXsRegular(color: colors.text200),
          ),
        ],
      ),
    );
  }
}

/// The default: neutral icon, auto-dismisses after two seconds.
@widgetbook.UseCase(name: 'Info', type: Toast)
Widget toastInfo(BuildContext context) =>
    const _ToastHarness(message: 'Address copied to clipboard');

/// Success — green check.
@widgetbook.UseCase(name: 'Success', type: Toast)
Widget toastSuccess(BuildContext context) => const _ToastHarness(
  message: 'Payment sent',
  variant: ToastVariant.success,
);

/// Warning — the amber triangle, for something the user should notice but
/// which did not fail.
@widgetbook.UseCase(name: 'Warning', type: Toast)
Widget toastWarning(BuildContext context) => const _ToastHarness(
  message: 'Network is slow',
  variant: ToastVariant.warning,
);

/// Error — red, and in the wallet the only variant the app also logs.
@widgetbook.UseCase(name: 'Error', type: Toast)
Widget toastError(BuildContext context) => const _ToastHarness(
  message: 'Payment failed',
  variant: ToastVariant.error,
);

/// The two-line form: a lighter description under the message.
@widgetbook.UseCase(name: 'With description', type: Toast)
Widget toastWithDescription(BuildContext context) => const _ToastHarness(
  message: 'Payment failed',
  variant: ToastVariant.error,
  description: 'The mint refused the melt. Your funds are untouched.',
);

/// With a close button the toast does *not* auto-dismiss — tapping × is the
/// only way out, short of a swipe up.
@widgetbook.UseCase(name: 'Close button (no auto-dismiss)', type: Toast)
Widget toastCloseButton(BuildContext context) => const _ToastHarness(
  message: 'Recovery phrase saved',
  variant: ToastVariant.success,
  description: 'Keep it somewhere only you can reach.',
  showCloseButton: true,
);

/// A trailing action. Tapping it dismisses the toast, then runs the callback.
@widgetbook.UseCase(name: 'With action', type: Toast)
Widget toastWithAction(BuildContext context) => const _ToastHarness(
  message: 'Contact deleted',
  withAction: true,
);

@widgetbook.UseCase(name: 'Playground', type: Toast)
Widget toastPlayground(BuildContext context) => _ToastHarness(
  message: context.knobs.string(label: 'Message', initialValue: 'Payment sent'),
  variant: context.knobs.object.dropdown(
    label: 'Variant',
    options: ToastVariant.values,
    labelBuilder: (v) => v.name,
  ),
  description: context.knobs.stringOrNull(label: 'Description'),
  withAction: context.knobs.boolean(label: 'Action button'),
  showCloseButton: context.knobs.boolean(label: 'Close button'),
  duration: Duration(
    milliseconds: context.knobs.int
        .slider(
          label: 'Duration (ms)',
          initialValue: 2000,
          min: 500,
          max: 8000,
        )
        .toInt(),
  ),
);
