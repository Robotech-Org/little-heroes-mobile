import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'country_picker.dart';

class PhoneNumberField extends StatelessWidget {
  final TextEditingController controller;
  final Country selectedCountry;
  final ValueChanged<Country> onCountryChanged;
  final String? Function(String?)? validator;

  const PhoneNumberField({
    super.key,
    required this.controller,
    required this.selectedCountry,
    required this.onCountryChanged,
    this.validator,
  });

  int get _maxPhoneLength {
    switch (selectedCountry.dialCode) {
      case '+251': // Ethiopia
        return 9;

      case '+254': // Kenya
        return 9;

      case '+256': // Uganda
        return 9;

      case '+255': // Tanzania
        return 9;

      case '+1': // USA
        return 10;

      case '+44': // UK
        return 10;

      default:
        return 15;
    }
  }

  String get _hintText {
    switch (selectedCountry.dialCode) {
      case '+251':
        return '988 107 722';

      case '+254':
        return '712 345 678';

      case '+256':
        return '712 345 678';

      default:
        return 'Phone number';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,

      // LIMIT PHONE NUMBER LENGTH
      maxLength: _maxPhoneLength,
      buildCounter:
          (context, {required currentLength, required isFocused, maxLength}) {
            return null; // Hide counter
          },

      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(_maxPhoneLength),
      ],

      validator: (value) {
        final phone = value?.trim() ?? '';

        if (phone.isEmpty) {
          return 'Phone number is required';
        }

        if (phone.length != _maxPhoneLength) {
          return 'Enter a valid ${_maxPhoneLength}-digit phone number';
        }

        if (validator != null) {
          return validator!(value);
        }

        return null;
      },

      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),

      decoration: InputDecoration(
        hintText: _hintText,

        hintStyle: TextStyle(
          color: colors.onSurfaceVariant.withValues(alpha: 0.55),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),

        filled: true,
        fillColor: colors.surface,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),

        // COUNTRY PICKER
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),

        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: CountryPicker(
            selectedCountry: selectedCountry,
            onChanged: onCountryChanged,
          ),
        ),

        // DIVIDER
        prefix: Container(
          height: 26,
          width: 1,
          margin: const EdgeInsets.only(right: 12),
          color: colors.outlineVariant,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.outline),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.outline),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary, width: 1.8),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.error),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.error, width: 1.8),
        ),

        errorStyle: const TextStyle(height: 1.2, fontSize: 12),
      ),
    );
  }
}
