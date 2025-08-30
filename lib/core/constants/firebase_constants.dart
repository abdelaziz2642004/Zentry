class FirebaseConstants {
  FirebaseConstants._();

  // Firestore Collection Names
  static const String usersCollection = 'Users';
  static const String userNamesCollection = 'UserNames';
  static const String roomsCollection = 'Rooms';
  static const String dailyStatsCollection = 'DailyStats';

  // Firestore Document Names
  static const String initDocument = '_init';

  // Firestore Field Names
  static const String usernameField = 'username';
  static const String fullNameField = 'name';
  static const String emailField = 'email';
  static const String imageUrlField = 'imageUrl';
  static const String favoritedField = 'favorited';
  static const String notificationsField = 'notifications';
  static const String sessionIdField = 'SessionID';
  static const String idField = 'id';

  // Timezone and Daily Tracking Fields
  static const String timezoneField = 'timezone';
  static const String timezoneOffsetField = 'timezoneOffset';
  static const String dailyStudyHoursField = 'dailyStudyHours';
  static const String lastStudyDateField = 'lastStudyDate';
  static const String totalStudyTimeField = 'totalStudyTime';
  static const String studySessionsField = 'studySessions';

  // Realtime Database Paths
  static const String roomsDbPath = 'Rooms';
  static const String usersDbPath = 'users';
  static const String roomsUsersPath = 'users'; // subpath under rooms

  // Realtime Database Field Names
  static const String currentRoomField = 'currentRoom';
  static const String roomCodeField = 'roomCode';
  static const String joinedUsersField = 'joinedUsers';

  // Cloudinary Constants - MOVED TO EnvironmentConfig for security
  // Use EnvironmentConfig.cloudName, EnvironmentConfig.apiKey, etc.
  static const String uploadPreset = "UsersPics";

  // Helper Methods for Building Paths
  static String getRoomPath(String roomCode) => '$roomsDbPath/$roomCode';
  static String getRoomUsersPath(String roomCode) =>
      '$roomsDbPath/$roomCode/$roomsUsersPath';
  static String getUserPath(String userId) => '$usersDbPath/$userId';
  static String getDailyStatsPath(String userId, String date) =>
      '$dailyStatsCollection/$userId/$date';
}
