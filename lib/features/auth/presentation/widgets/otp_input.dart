import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInput extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;

  const OtpInput({super.key, required this.onChanged, this.onCompleted});

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  static const int _length = 6;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(_length, (_) => TextEditingController());

    _focusNodes = List.generate(_length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final node in _focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  String get _otp {
    return _controllers.map((controller) => controller.text).join();
  }

  void _notify() {
    final otp = _otp;

    widget.onChanged(otp);

    if (otp.length == _length) {
      widget.onCompleted?.call(otp);
    }
  }

  void _handleChanged(String value, int index) {
    if (value.length > 1) {
      _handlePaste(value);
      return;
    }

    if (value.isNotEmpty && index < _length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    _notify();
  }

  void _handlePaste(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) {
      return;
    }

    final otp = digits.length > _length ? digits.substring(0, _length) : digits;

    for (var i = 0; i < _length; i++) {
      _controllers[i].clear();
    }

    for (var i = 0; i < otp.length; i++) {
      _controllers[i].text = otp[i];
    }

    if (otp.length == _length) {
      _focusNodes[_length - 1].unfocus();
    } else {
      _focusNodes[otp.length].requestFocus();
    }

    _notify();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;

        final boxWidth =
            (constraints.maxWidth - (spacing * (_length - 1))) / _length;

        final width = boxWidth.clamp(42.0, 54.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_length, (index) {
            return SizedBox(
              width: width,
              height: 58,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                textInputAction: index == _length - 1
                    ? TextInputAction.done
                    : TextInputAction.next,
                maxLength: 1,
                autofillHints: index == 0
                    ? const [AutofillHints.oneTimeCode]
                    : null,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: colors.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: colors.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: colors.primary, width: 2),
                  ),
                ),
                onChanged: (value) {
                  _handleChanged(value, index);
                },
              ),
            );
          }),
        );
      },
    );
  }
}
