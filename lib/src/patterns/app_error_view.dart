import 'dart:async';

import 'package:bitcr_ui/src/core/refresh_button.dart';
import 'package:flutter/material.dart';

class AppErrorView extends StatefulWidget {
  const AppErrorView({
    super.key,
    required this.message,
    this.details,
    this.retryLabel,
    this.onRetry,
    this.onRetryError,
  }) : assert(
         onRetry == null || retryLabel != null,
         'onRetry needs a retryLabel',
       );

  final String message;
  final Widget? details;
  final String? retryLabel;
  final FutureOr<void> Function()? onRetry;
  final void Function(Object error, StackTrace stack)? onRetryError;

  @override
  State<AppErrorView> createState() => _AppErrorViewState();
}

class _AppErrorViewState extends State<AppErrorView> {
  var _isRetrying = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.message, textAlign: TextAlign.center),
          if (widget.details case final details?) ...[
            const SizedBox(height: 8),
            details,
          ],
          if (widget.onRetry != null)
            RefreshButton(
              label: widget.retryLabel,
              isLoading: _isRetrying,
              onPressed: _retry,
            ),
        ],
      ),
    );
  }

  Future<void> _retry() async {
    if (_isRetrying) return;

    setState(() => _isRetrying = true);

    try {
      await widget.onRetry!();
    } catch (error, stack) {
      widget.onRetryError?.call(error, stack);
    } finally {
      if (mounted) setState(() => _isRetrying = false);
    }
  }
}
