import 'dart:async';

import 'package:bitcr_ui/src/patterns/animated_qr_code.dart';
import 'package:bitcr_ui/src/patterns/qr_matrix.dart';
import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Drawn in place of a code that cannot be encoded, when the caller supplies
/// no `errorBuilder` of its own.
///
/// A glyph rather than a sentence: the library ships no strings, and silence
/// on a surface whose only job is to show a code is the worst of the options.
class QrCodeUnavailable extends StatelessWidget {
  const QrCodeUnavailable({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        LucideIcons.triangleAlert,
        color: BitcrColors.of(context).signalError,
      ),
    );
  }
}

/// Above this many characters a single QR's modules get too dense to scan
/// reliably, and the data has to be shown as an [AnimatedQrCode] instead.
const int kMaxStaticQrDataLength = 2000;

/// Wraps the fullscreen QR before it's shown, for an app that needs something
/// around it — the wallet rotates it 180° when the phone is upside down, so a
/// code held out across a table faces the other person.
typedef QrFullscreenWrapper = Widget Function(
  BuildContext context,
  Widget child,
);

/// Opens [data] as a fullscreen QR over a near-opaque scrim, dismissed by
/// tapping anywhere.
///
/// This is what [QrCode] and [AnimatedQrCode] do on tap by default — call it
/// directly only to enlarge a QR from something that isn't one of them.
Future<void> showQrCodeFullscreen(
  BuildContext context, {
  required String data,
  QrFullscreenWrapper? wrapper,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.9),
    builder: (_) => QrCodeFullscreenOverlay(data: data, wrapper: wrapper),
  );
}

/// The fullscreen QR itself: as large as the screen allows, on a white card so
/// it scans regardless of theme.
///
/// Long payloads render as an [AnimatedQrCode]; see [kMaxStaticQrDataLength].
class QrCodeFullscreenOverlay extends StatelessWidget {
  const QrCodeFullscreenOverlay({super.key, required this.data, this.wrapper});

  final String data;
  final QrFullscreenWrapper? wrapper;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    final Widget content = GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              color: colors.white,
              padding: const EdgeInsets.all(16),
              child: data.length <= kMaxStaticQrDataLength
                  ? ExactQrCode(data: data, color: colors.black)
                  // Already fullscreen, so tapping this one dismisses rather
                  // than opening a second overlay.
                  : AnimatedQrCode(
                      data: data,
                      enlargeOnTap: false,
                      padding: EdgeInsets.zero,
                      contentPadding: const EdgeInsets.all(8),
                      backgroundColor: colors.white,
                    ),
            ),
          ),
        ),
      ),
    );

    return wrapper?.call(context, content) ?? content;
  }
}

/// A static QR code for [data], padded and boxed the way the receive and
/// request screens show it.
///
/// The encode runs on a background isolate, so the widget shows a spinner for
/// the first frame or two and re-encodes whenever [data] changes.
class QrCode extends StatefulWidget {
  const QrCode({
    super.key,
    required this.data,
    this.padding,
    this.contentPadding = const EdgeInsets.all(8),
    this.onTap,
    this.enlargeOnTap = true,
    this.fullscreenWrapper,
    this.backgroundColor,
    this.errorBuilder,
  });

  final String data;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry contentPadding;
  final WidgetBuilder? errorBuilder;
  final VoidCallback? onTap;
  final bool enlargeOnTap;
  final QrFullscreenWrapper? fullscreenWrapper;

  final Color? backgroundColor;

  @override
  State<QrCode> createState() => _QrCodeState();
}

class _QrCodeState extends State<QrCode> {
  QrMatrix? _matrix;
  bool _encoding = true;

  @override
  void initState() {
    super.initState();

    _encode();
  }

  @override
  void didUpdateWidget(covariant QrCode oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.data != widget.data) _encode();
  }

  void _encode() {
    setState(() => _encoding = true);
    unawaited(
      compute(encodeQrMatrix, widget.data).then((matrix) {
        if (!mounted) return;
        setState(() {
          _matrix = matrix;
          _encoding = false;
        });
      }),
    );
  }

  VoidCallback? get _onTap {
    if (widget.onTap != null) return widget.onTap;
    if (!widget.enlargeOnTap) return null;

    return () => showQrCodeFullscreen(
      context,
      data: widget.data,
      wrapper: widget.fullscreenWrapper,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final bg = widget.backgroundColor ?? colors.elevation250;
    final fg = widget.backgroundColor != null ? colors.black : colors.text300;
    final matrix = _matrix;

    return GestureDetector(
      onTap: _onTap,
      child: Padding(
        padding:
            widget.padding ??
            const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(color: bg),
            padding: widget.contentPadding,
            child: RepaintBoundary(
              child: switch ((_encoding, matrix)) {
                (true, _) => const Center(child: CircularProgressIndicator()),
                (false, final matrix?) => CustomPaint(
                  painter: QrMatrixPainter(matrix: matrix, color: fg),
                ),
                (false, null) =>
                  widget.errorBuilder?.call(context) ??
                      const QrCodeUnavailable(),
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// [QrCode] without the padding, box or color logic: it fills the shortest
/// side of whatever slot it's given, in exactly the [color] asked for.
class ExactQrCode extends StatefulWidget {
  const ExactQrCode({
    super.key,
    required this.data,
    required this.color,
    this.onTap,
    this.errorBuilder,
  });

  final String data;
  final Color color;
  final VoidCallback? onTap;
  final WidgetBuilder? errorBuilder;

  @override
  State<ExactQrCode> createState() => _ExactQrCodeState();
}

class _ExactQrCodeState extends State<ExactQrCode> {
  QrMatrix? _matrix;
  bool _encoding = true;

  @override
  void initState() {
    super.initState();

    _encode();
  }

  @override
  void didUpdateWidget(covariant ExactQrCode oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.data != widget.data) _encode();
  }

  void _encode() {
    setState(() => _encoding = true);
    unawaited(
      compute(encodeQrMatrix, widget.data).then((matrix) {
        if (!mounted) return;
        setState(() {
          _matrix = matrix;
          _encoding = false;
        });
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matrix = _matrix;

    return LayoutBuilder(
      builder: (context, constraints) {
        final dimension = constraints.biggest.shortestSide;

        return GestureDetector(
          onTap: widget.onTap,
          child: SizedBox.square(
            dimension: dimension,
            child: switch ((_encoding, matrix)) {
              (true, _) => const Center(child: CircularProgressIndicator()),
              (false, final matrix?) => RepaintBoundary(
                child: CustomPaint(
                  painter: QrMatrixPainter(matrix: matrix, color: widget.color),
                ),
              ),
              (false, null) =>
                widget.errorBuilder?.call(context) ?? const QrCodeUnavailable(),
            },
          ),
        );
      },
    );
  }
}
