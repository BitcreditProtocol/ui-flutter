import 'dart:async';
import 'dart:math' as math;

import 'package:bitcr_ui/src/patterns/bcqr_protocol.dart';
import 'package:bitcr_ui/src/patterns/qr_code.dart';
import 'package:bitcr_ui/src/patterns/qr_matrix.dart';
import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';

/// Initial time each chunk QR is shown before advancing to the next one.
const Duration _kInitialFrameDuration = Duration(milliseconds: 200);

/// Amount to slow the animation on each step after the initial pace.
const Duration _kFrameDurationStep = Duration(milliseconds: 100);

/// Maximum delay between frame changes once the animation slows down.
const Duration _kMaxFrameDuration = Duration(milliseconds: 700);

/// Gap between the code and its progress bar, and the bar's own height —
/// reserved out of the available height so the square never overflows it.
const double _kProgressGap = 12;
const double _kProgressHeight = 6;

/// An animated QR code that cycles through chunked [BCQR frames] for data too
/// large to fit in a single QR code, with a progress bar showing where in the
/// sequence it is. Data that fits in one chunk renders as a single static QR
/// and no progress bar.
///
/// The animation starts fast and slows down the longer it runs: a scanner that
/// missed a frame gets progressively more time to catch it.
///
/// [BCQR frames]: buildChunkedQrFrames
class AnimatedQrCode extends StatefulWidget {
  const AnimatedQrCode({
    super.key,
    required this.data,
    this.padding,
    this.contentPadding = EdgeInsets.zero,
    this.onTap,
    this.enlargeOnTap = true,
    this.fullscreenWrapper,
    this.backgroundColor,
    this.errorBuilder,
  });

  final String data;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry contentPadding;
  final VoidCallback? onTap;
  final bool enlargeOnTap;
  final QrFullscreenWrapper? fullscreenWrapper;
  final Color? backgroundColor;
  final WidgetBuilder? errorBuilder;

  @override
  State<AnimatedQrCode> createState() => _AnimatedQrCodeState();
}

class _AnimatedQrCodeState extends State<AnimatedQrCode> {
  late List<String> _frames;
  List<QrMatrix?>? _frameMatrices;
  bool _encoding = true;
  int _currentFrame = 0;
  int _animationStep = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _buildFrames();
  }

  @override
  void didUpdateWidget(covariant AnimatedQrCode oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.data != widget.data) {
      _timer?.cancel();
      _currentFrame = 0;
      _animationStep = 0;
      _frameMatrices = null;

      _buildFrames();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  void _buildFrames() {
    _frames = buildChunkedQrFrames(widget.data);

    setState(() => _encoding = true);
    unawaited(
      compute(encodeQrMatrices, _frames).then((matrices) {
        if (!mounted) return;

        setState(() {
          _frameMatrices = matrices;
          _encoding = false;
        });
        _scheduleNextFrame();
      }),
    );
  }

  void _scheduleNextFrame() {
    _timer?.cancel();

    if (_frames.length <= 1) return;

    final duration = _frameDurationForStep(_animationStep);
    _timer = Timer(duration, () {
      if (!mounted) return;

      setState(() {
        _currentFrame = (_currentFrame + 1) % _frames.length;
        _animationStep += 1;
      });

      _scheduleNextFrame();
    });
  }

  Duration _frameDurationForStep(int step) {
    final cycle = step ~/ _frames.length;

    if (cycle < 5) return _kInitialFrameDuration;

    final slowingCycle = cycle - 5;
    final durationMs =
        _kInitialFrameDuration.inMilliseconds +
        (slowingCycle * _kFrameDurationStep.inMilliseconds);

    return Duration(
      milliseconds: durationMs.clamp(
        _kInitialFrameDuration.inMilliseconds,
        _kMaxFrameDuration.inMilliseconds,
      ),
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
    final isAnimated = _frames.length > 1;
    final bg = widget.backgroundColor ?? colors.elevation250;
    final fg = widget.backgroundColor != null ? colors.black : colors.text300;
    final matrix = _frameMatrices?[_currentFrame];

    return GestureDetector(
      onTap: _onTap,
      child: Padding(
        padding:
            widget.padding ??
            const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final reserved = isAnimated
                ? _kProgressGap + _kProgressHeight
                : 0.0;
            final available = constraints.hasBoundedHeight
                ? constraints.maxHeight - reserved
                : double.infinity;
            final side = math.min(constraints.maxWidth, available);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox.square(
                  dimension: side,
                  child: Container(
                    decoration: BoxDecoration(color: bg),
                    padding: widget.contentPadding,
                    child: RepaintBoundary(
                      child: switch ((_encoding, matrix)) {
                        (true, _) => const Center(
                          child: CircularProgressIndicator(),
                        ),
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
                if (isAnimated) ...[
                  const SizedBox(height: _kProgressGap),
                  SizedBox(
                    width: side,
                    child: _ChunkProgressIndicator(
                      currentChunk: _currentFrame,
                      totalChunks: _frames.length,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ChunkProgressIndicator extends StatelessWidget {
  const _ChunkProgressIndicator({
    required this.currentChunk,
    required this.totalChunks,
  });

  final int currentChunk;
  final int totalChunks;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return ClipRRect(
      child: LinearProgressIndicator(
        value: totalChunks > 0 ? (currentChunk + 1) / totalChunks : 0,
        minHeight: 6,
        backgroundColor: colors.text200.withValues(alpha: 0.2),
        valueColor: AlwaysStoppedAnimation<Color>(colors.brand200),
      ),
    );
  }
}
