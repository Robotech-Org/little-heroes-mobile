
import 'package:flutter/material.dart';

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

class CountryPicker extends StatelessWidget {
  final Country selectedCountry;
  final ValueChanged<Country> onChanged;

  const CountryPicker({
    super.key,
    required this.selectedCountry,
    required this.onChanged,
  });

  static const List<Country> countries = [
    Country(
      name: 'Ethiopia',
      flag: '🇪🇹',
      dialCode: '+251',
    ),
    Country(
      name: 'Kenya',
      flag: '🇰🇪',
      dialCode: '+254',
    ),
    Country(
      name: 'Uganda',
      flag: '🇺🇬',
      dialCode: '+256',
    ),
    Country(
      name: 'Tanzania',
      flag: '🇹🇿',
      dialCode: '+255',
    ),
    Country(
      name: 'United States',
      flag: '🇺🇸',
      dialCode: '+1',
    ),
    Country(
      name: 'United Kingdom',
      flag: '🇬🇧',
      dialCode: '+44',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Country>(
      onSelected: onChanged,
      itemBuilder: (context) {
        return countries.map((country) {
          return PopupMenuItem<Country>(
            value: country,
            child: Row(
              children: [
                Text(
                  country.flag,
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(country.name),
                ),
                Text(country.dialCode),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outline,
          ),
          borderRadius: BorderRadius.circular(8),
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
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
