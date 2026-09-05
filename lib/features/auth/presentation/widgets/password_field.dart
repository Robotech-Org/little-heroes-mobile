import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final bool enabled;
  final String? Function(String?)? validator;

  const PasswordField({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    this.enabled = true,
    this.validator,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
        ],

        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: _obscurePassword,
          validator:
              widget.validator ??
              (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Password is required';
                }

                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }

                return null;
              },
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Enter your password',

            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: colors.onSurfaceVariant,
            ),

            suffixIcon: IconButton(
              tooltip: _obscurePassword ? 'Show password' : 'Hide password',
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: colors.onSurfaceVariant,
              ),
            ),

            filled: true,
            fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.35),

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.error),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
