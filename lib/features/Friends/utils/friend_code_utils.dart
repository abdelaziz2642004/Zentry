class FriendCodeUtils {
  /// Validates if a string is a valid friend code format
  static bool isValidFriendCode(String code) {
    final trimmedCode = code.trim();
    return trimmedCode.length == 6 &&
        RegExp(r'^[A-Z0-9]{6}$').hasMatch(trimmedCode.toUpperCase());
  }

  /// Formats a friend code to uppercase and removes spaces
  static String formatFriendCode(String code) {
    return code.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
  }

  /// Generates a random friend code (6 characters, alphanumeric)
  static String generateFriendCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final code = StringBuffer();

    for (int i = 0; i < 6; i++) {
      final index = (random + i) % chars.length;
      code.write(chars[index]);
    }

    return code.toString();
  }

  /// Validates and formats friend code with error message
  static Map<String, dynamic> validateAndFormatFriendCode(String code) {
    final formattedCode = formatFriendCode(code);

    if (formattedCode.isEmpty) {
      return {
        'isValid': false,
        'formattedCode': '',
        'errorMessage': 'Friend code cannot be empty',
      };
    }

    if (formattedCode.length != 6) {
      return {
        'isValid': false,
        'formattedCode': formattedCode,
        'errorMessage': 'Friend code must be exactly 6 characters',
      };
    }

    if (!RegExp(r'^[A-Z0-9]{6}$').hasMatch(formattedCode)) {
      return {
        'isValid': false,
        'formattedCode': formattedCode,
        'errorMessage': 'Friend code can only contain letters and numbers',
      };
    }

    return {
      'isValid': true,
      'formattedCode': formattedCode,
      'errorMessage': null,
    };
  }
}
