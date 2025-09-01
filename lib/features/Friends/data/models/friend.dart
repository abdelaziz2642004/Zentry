import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  final String id;
  final String username;
  final String fullName;
  final String email;
  final String status; // online, offline, busy
  final DateTime lastSeen;
  final bool isOnline;
  final Duration totalStudyTime;
  final Duration dailyStudyTime;
  final String lastStudyDate;
  final List<String> favoriteSubjects;

  Friend({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.status,
    required this.lastSeen,
    required this.isOnline,
    required this.totalStudyTime,
    required this.dailyStudyTime,
    required this.lastStudyDate,
    required this.favoriteSubjects,
  });

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      status: map['status'] ?? 'offline',
      lastSeen:
          map['lastSeen'] != null
              ? (map['lastSeen'] is Timestamp
                  ? (map['lastSeen'] as Timestamp).toDate()
                  : DateTime.parse(map['lastSeen'].toString()))
              : DateTime.now(),
      isOnline: map['isOnline'] ?? false,
      totalStudyTime: Duration(seconds: map['totalStudyTime'] ?? 0),
      dailyStudyTime: Duration(seconds: map['dailyStudyTime'] ?? 0),
      lastStudyDate: map['lastStudyDate'] ?? '',
      favoriteSubjects: List<String>.from(map['favoriteSubjects'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'email': email,
      'status': status,
      'lastSeen': lastSeen.toIso8601String(),
      'isOnline': isOnline,
      'totalStudyTime': totalStudyTime.inSeconds,
      'dailyStudyTime': dailyStudyTime.inSeconds,
      'lastStudyDate': lastStudyDate,
      'favoriteSubjects': favoriteSubjects,
    };
  }

  Friend copyWith({
    String? id,
    String? username,
    String? fullName,
    String? email,
    String? status,
    DateTime? lastSeen,
    bool? isOnline,
    Duration? totalStudyTime,
    Duration? dailyStudyTime,
    String? lastStudyDate,
    List<String>? favoriteSubjects,
  }) {
    return Friend(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
      totalStudyTime: totalStudyTime ?? this.totalStudyTime,
      dailyStudyTime: dailyStudyTime ?? this.dailyStudyTime,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      favoriteSubjects: favoriteSubjects ?? this.favoriteSubjects,
    );
  }
}
