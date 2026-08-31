import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Country {
  final String name;
  final String flag;
  final String dialCode;

  const Country({
    required this.name,
    required this.flag,
    required this.dialCode,
  });
}

const List<Country> countries = [
  Country(name: 'Ethiopia', flag: '🇪🇹', dialCode: '+251'),
  Country(name: 'Kenya', flag: '🇰🇪', dialCode: '+254'),
  Country(name: 'Uganda', flag: '🇺🇬', dialCode: '+256'),
  Country(name: 'Tanzania', flag: '🇹🇿', dialCode: '+255'),
  Country(name: 'United States', flag: '🇺🇸', dialCode: '+1'),
  Country(name: 'United Kingdom', flag: '🇬🇧', dialCode: '+44'),
];

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

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country selector
        PopupMenuButton<Country>(
          onSelected: onCountryChanged,
          position: PopupMenuPosition.under,
          itemBuilder: (context) {
            return countries.map((country) {
              return PopupMenuItem<Country>(
                value: country,
                child: Row(
                  children: [
                    Text(country.flag, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(country.name)),
                    Text(
                      country.dialCode,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }).toList();
          },
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedCountry.flag,
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(width: 6),
                Text(
                  selectedCountry.dialCode,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              ],
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Phone number
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: validator,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: '912 345 678',
              prefixIcon: const Icon(Icons.phone_outlined),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
