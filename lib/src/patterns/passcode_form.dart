import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:bitcr_ui/src/theme/radii.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// PIN entry: a row of dots over a single invisible text field.
///
/// The parent owns the value. [onChanged] reports one digit at a time as a
/// (index, character) pair — an empty string for a deletion — and the caller
/// folds those into its own state and passes the result back as [value].
class PasscodeForm extends StatefulWidget {
  const PasscodeForm({
    super.key,
    required this.onChanged,
    required this.value,
    this.length = 4,
    this.autoFocus = false,
    this.identifier,
  });

  final void Function(int index, String value) onChanged;

  final String value;
  final int length;
  final bool autoFocus;
  final String? identifier;

  @override
  State<PasscodeForm> createState() => _PasscodeFormState();
}

class _PasscodeFormState extends State<PasscodeForm>
    with WidgetsBindingObserver {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String _previousText = '';
  bool _autoFocusScheduled = false;
  bool _pendingInitialFocus = false;
  Animation<double>? _routeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    _previousText = widget.value;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final routeAnimation = ModalRoute.of(context)?.animation;
    if (routeAnimation != _routeAnimation) {
      _routeAnimation?.removeStatusListener(_onRouteAnimationStatus);
      _routeAnimation = routeAnimation;
      _routeAnimation?.addStatusListener(_onRouteAnimationStatus);
    }

    if (widget.autoFocus && !_autoFocusScheduled) {
      _autoFocusScheduled = true;
      _scheduleInitialAutoFocus();
    }
  }

  void _onRouteAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.reverse && _focusNode.hasFocus) {
      _focusNode.unfocus();
    } else if (status == AnimationStatus.completed && _pendingInitialFocus) {
      _pendingInitialFocus = false;
      _requestInitialKeyboardFocus();
    }
  }

  void _scheduleInitialAutoFocus() {
    final animation = _routeAnimation;
    if (animation == null || animation.status == AnimationStatus.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _requestInitialKeyboardFocus();
      });
    } else {
      _pendingInitialFocus = true;
    }
  }

  void _requestInitialKeyboardFocus() {
    _requestKeyboardFocus();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _requestKeyboardFocus();
    });
  }

  void _requestKeyboardFocus() {
    if (!mounted || !_focusNode.canRequestFocus) return;

    _focusNode.requestFocus();
    SystemChannels.textInput.invokeMethod<void>('TextInput.show');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.autoFocus && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestKeyboardFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant PasscodeForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
      _controller.selection = TextSelection.collapsed(
        offset: widget.value.length,
      );
      _previousText = widget.value;

      if (widget.value.isEmpty && widget.autoFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _requestKeyboardFocus();
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _routeAnimation?.removeStatusListener(_onRouteAnimationStatus);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTextChanged(String newText) {
    final oldText = _previousText;
    _previousText = newText;

    if (newText.length > oldText.length) {
      final index = newText.length - 1;
      widget.onChanged(index, newText[index]);
    } else if (newText.length < oldText.length) {
      final index = oldText.length - 1;
      widget.onChanged(index, '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _requestKeyboardFocus,
      child: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, value, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: List.generate(widget.length, (index) {
                  return _PinDot(
                    filled: index < value.text.length,
                    active: index == value.text.length,
                  );
                }),
              );
            },
          ),
          Positioned.fill(
            child: Semantics(
              identifier: widget.identifier,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: false,
                maxLength: widget.length,
                showCursor: false,
                style: const TextStyle(color: Colors.transparent, fontSize: 1),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                decoration: const InputDecoration(
                  counterText: '',
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: _handleTextChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PinDot extends StatelessWidget {
  const _PinDot({required this.filled, this.active = false});

  final bool filled;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);

    return Container(
      width: 44,
      height: 52,
      decoration: BoxDecoration(
        color: colors.elevation200,
        borderRadius: BorderRadius.circular(BitcrRadius.md),
        border: Border.all(
          color: active ? colors.divider300 : colors.divider50,
        ),
      ),
      child: filled
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors.text300,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
