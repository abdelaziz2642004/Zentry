import 'package:zentry_pomodoro_app/Models/notification.dart';

class FireUser {
  final String _id;
  final String _email;
  String _imageUrl;
  String _fullName;
  String _timezone;
  int _timezoneOffset;
  Duration _dailyStudyHours;
  String _lastStudyDate;
  Duration _totalStudyTime;
  bool _isOnline;
  DateTime _lastSeen;
  String _status;
  List<String> _favoriteSubjects;
  int _studyStreak;

  set fullName(String value) => _fullName = value;
  String get imageUrl => _imageUrl;
  set imageUrl(String value) => _imageUrl = value;
  String get fullName => _fullName;
  String get timezone => _timezone;
  int get timezoneOffset => _timezoneOffset;
  Duration get dailyStudyHours => _dailyStudyHours;
  String get lastStudyDate => _lastStudyDate;
  Duration get totalStudyTime => _totalStudyTime;
  bool get isOnline => _isOnline;
  DateTime get lastSeen => _lastSeen;
  String get status => _status;
  List<String> get favoriteSubjects => _favoriteSubjects;
  int get studyStreak => _studyStreak;

  final List<AppNotification> _notifications;

  FireUser({
    String? id,
    String? email,
    String? userName,
    String? imageUrl,
    String? fullName,
    List<AppNotification>? notifications,
    String? timezone,
    int? timezoneOffset,
    Duration? dailyStudyHours,
    String? lastStudyDate,
    Duration? totalStudyTime,
    bool? isOnline,
    DateTime? lastSeen,
    String? status,
    List<String>? favoriteSubjects,
    int? studyStreak,
  }) : _id = id ?? '',
       _email = email ?? 'Guest',
       _imageUrl = imageUrl ?? '',
       _fullName = fullName ?? 'Guest',
       _timezone = timezone ?? 'UTC',
       _timezoneOffset = timezoneOffset ?? 0,
       _dailyStudyHours = dailyStudyHours ?? Duration.zero,
       _lastStudyDate = lastStudyDate ?? '',
       _totalStudyTime = totalStudyTime ?? Duration.zero,
       _notifications = notifications ?? [],
       _isOnline = isOnline ?? false,
       _lastSeen = lastSeen ?? DateTime.now(),
       _status = status ?? 'offline',
       _favoriteSubjects = favoriteSubjects ?? [],
       _studyStreak = studyStreak ?? 0;

  String get id => _id;
  String get email => _email;
  List<AppNotification> get notifications => _notifications;

  /// Update daily study hours
  void updateDailyStudyHours(Duration studyTime) {
    _dailyStudyHours = studyTime;
  }

  /// Update total study time
  void updateTotalStudyTime(Duration studyTime) {
    _totalStudyTime = studyTime;
  }

  /// Update last study date
  void updateLastStudyDate(String date) {
    _lastStudyDate = date;
  }

  /// Update timezone information
  void updateTimezone(String timezone, int offset) {
    _timezone = timezone;
    _timezoneOffset = offset;
  }

  /// Create a copy of this user with updated fields
  FireUser copyWith({
    String? id,
    String? email,
    String? imageUrl,
    String? fullName,
    List<AppNotification>? notifications,
    String? timezone,
    int? timezoneOffset,
    Duration? dailyStudyHours,
    String? lastStudyDate,
    Duration? totalStudyTime,
    bool? isOnline,
    DateTime? lastSeen,
    String? status,
    List<String>? favoriteSubjects,
    int? studyStreak,
  }) {
    return FireUser(
      id: id ?? _id,
      email: email ?? _email,
      imageUrl: imageUrl ?? _imageUrl,
      fullName: fullName ?? _fullName,
      notifications: notifications ?? _notifications,
      timezone: timezone ?? _timezone,
      timezoneOffset: timezoneOffset ?? _timezoneOffset,
      dailyStudyHours: dailyStudyHours ?? _dailyStudyHours,
      lastStudyDate: lastStudyDate ?? _lastStudyDate,
      totalStudyTime: totalStudyTime ?? _totalStudyTime,
      isOnline: isOnline ?? _isOnline,
      lastSeen: lastSeen ?? _lastSeen,
      status: status ?? _status,
      favoriteSubjects: favoriteSubjects ?? _favoriteSubjects,
      studyStreak: studyStreak ?? _studyStreak,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': _fullName,
      'email': _email.trim(),
      'imageUrl': _imageUrl,
      'id': _id,
      'timezone': _timezone,
      'timezoneOffset': _timezoneOffset,
      'dailyStudyHours': _dailyStudyHours.inSeconds,
      'lastStudyDate': _lastStudyDate,
      'totalStudyTime': _totalStudyTime.inSeconds,
      'isOnline': _isOnline,
      'lastSeen': _lastSeen.toIso8601String(),
      'status': _status,
      'favoriteSubjects': _favoriteSubjects,
      'studyStreak': _studyStreak,
    };
  }

  factory FireUser.fromMap(Map<String, dynamic> map) {
    return FireUser(
      id: map['id'],
      email: map['email'],
      fullName: map['name'],
      imageUrl: map['imageUrl'],
      timezone: map['timezone'] ?? 'UTC',
      timezoneOffset: map['timezoneOffset'] ?? 0,
      dailyStudyHours: Duration(seconds: map['dailyStudyHours'] ?? 0),
      lastStudyDate: map['lastStudyDate'] ?? '',
      totalStudyTime: Duration(seconds: map['totalStudyTime'] ?? 0),
      isOnline: map['isOnline'] ?? false,
      lastSeen:
          map['lastSeen'] != null
              ? DateTime.parse(map['lastSeen'])
              : DateTime.now(),
      status: map['status'] ?? 'offline',
      favoriteSubjects: List<String>.from(map['favoriteSubjects'] ?? []),
      studyStreak: map['studyStreak'] ?? 0,
    );
  }
}
