import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;

  final TextEditingController? controller;

  final TextInputType keyboardType;
  final TextInputAction? textInputAction;

  final bool obscureText;
  final bool enabled;
  final bool readOnly;

  /// Whether this field is required.
  final bool required;

  /// Custom validator.
  final String? Function(String?)? validator;

  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  final Widget? prefixIcon;
  final Widget? suffixIcon;

  final int maxLines;
  final int? maxLength;

  final String? helperText;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.validator,
    this.onChanged,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.helperText,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  String? _validate(String? value) {
    final text = value?.trim() ?? '';

    // Required validation
    if (widget.required && text.isEmpty) {
      return '${widget.label ?? 'This field'} is required';
    }

    // Optional empty fields don't need validation.
    if (text.isEmpty) {
      return null;
    }

    // Custom validation
    return widget.validator?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final showPasswordToggle = widget.obscureText;

    return TextFormField(
      controller: widget.controller,
      initialValue:
          widget.controller == null ? widget.initialValue : null,

      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,

      obscureText: _obscureText,

      enabled: widget.enabled,
      readOnly: widget.readOnly,

      maxLines: widget.obscureText ? 1 : widget.maxLines,
      maxLength: widget.maxLength,

      validator: _validate,
      onChanged: widget.onChanged,
      onTap: widget.onTap,

      decoration: InputDecoration(
        labelText: widget.required && widget.label != null
            ? '${widget.label} *'
            : widget.label,

        hintText: widget.hint,

        helperText: widget.helperText,

        prefixIcon: widget.prefixIcon,

        suffixIcon: showPasswordToggle
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              )
            : widget.suffixIcon,
      ),
    );
  }
}