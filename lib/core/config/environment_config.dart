class EnvironmentConfig {
  EnvironmentConfig._();

  // Cloudinary Configuration
  // For now, keeping them here but with clear warnings
  static const String _cloudName = "dv0opvwfu";
  static const String _apiKey = "141946341514187";
  static const String _apiSecret = "-LpCQkZjIOyOu2-cSQqE9Qe6HNE";

  // Getters with warnings
  static String get cloudName {
    return _cloudName;
  }

  static String get apiKey {
    return _apiKey;
  }

  static String get apiSecret {
    return _apiSecret;
  }

  // Upload preset - this can be public
  static const String uploadPreset = "default_preset";
}
