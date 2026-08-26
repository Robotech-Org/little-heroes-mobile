class StringUtils {
  StringUtils._();

  /// Returns true if the string is null or empty.
  static bool isEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// Returns true if the string has a value.
  static bool isNotEmpty(String? value) {
    return !isEmpty(value);
  }

  /// Removes leading and trailing whitespace.
  static String clean(String? value) {
    return value?.trim() ?? '';
  }

  /// Capitalizes the first letter.
  ///
  /// hello world -> Hello world
  static String capitalize(String? value) {
    final text = clean(value);

    if (text.isEmpty) return '';

    return text[0].toUpperCase() + text.substring(1);
  }

  /// Capitalizes every word.
  ///
  /// hello world -> Hello World
  static String capitalizeWords(String? value) {
    final text = clean(value);

    if (text.isEmpty) return '';

    return text
        .split(RegExp(r'\s+'))
        .map(capitalize)
        .join(' ');
  }

  /// Converts text to lowercase safely.
  static String lower(String? value) {
    return clean(value).toLowerCase();
  }

  /// Converts text to uppercase safely.
  static String upper(String? value) {
    return clean(value).toUpperCase();
  }

  
  /// Example:
  /// truncate('Hello World', 5) -> 'Hello...'
  static String truncate(
    String? value,
    int maxLength, {
    String suffix = '...',
  }) {
    final text = clean(value);

    if (text.length <= maxLength) {
      return text;
    }

    if (maxLength <= suffix.length) {
      return suffix.substring(0, maxLength);
    }

    return '${text.substring(0, maxLength - suffix.length)}$suffix';
  }

  
  /// John Doe -> JD
  /// John Michael Doe -> JD
  static String initials(String? value) {
    final text = clean(value);

    if (text.isEmpty) return '';

    final words = text.split(RegExp(r'\s+'));

    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    }

    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  
  /// john.doe@gmail.com -> j*******@gmail.com
  static String maskEmail(String? email) {
    final value = clean(email);

    final atIndex = value.indexOf('@');

    if (atIndex <= 0) {
      return value;
    }

    final username = value.substring(0, atIndex);
    final domain = value.substring(atIndex);

    if (username.length <= 2) {
      return '${username[0]}***$domain';
    }

    return '${username[0]}${'*' * (username.length - 1)}$domain';
  }

  /// +251912345678 -> +251*****5678
  static String maskPhone(String? phone) {
    final value = clean(phone);

    if (value.length <= 4) {
      return value;
    }

    final visibleDigits = 4;
    final hiddenLength = value.length - visibleDigits;

    return '${'*' * hiddenLength}${value.substring(hiddenLength)}';
  }

  /// Removes all whitespace.
  static String removeWhitespace(String? value) {
    return clean(value).replaceAll(RegExp(r'\s+'), '');
  }

  /// Converts multiple spaces into a single space.
  static String normalizeSpaces(String? value) {
    return clean(value).replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Checks whether a string contains another string.
  static bool contains(
    String? value,
    String? search, {
    bool caseSensitive = false,
  }) {
    final text = clean(value);
    final query = clean(search);

    if (caseSensitive) {
      return text.contains(query);
    }

    return text.toLowerCase().contains(query.toLowerCase());
  }

  /// Returns a safe string from a nullable value.
  static String orDefault(
    String? value, {
    String defaultValue = '-',
  }) {
    return isEmpty(value) ? defaultValue : clean(value);
  }
}