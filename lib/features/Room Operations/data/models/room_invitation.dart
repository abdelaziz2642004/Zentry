import 'package:cloud_firestore/cloud_firestore.dart';

enum InvitationStatus { pending, accepted, declined, expired }

class RoomInvitation {
  final String id;
  final String roomCode;
  final String roomName;
  final String inviterId;
  final String inviterName;
  final String inviterUsername;
  final String inviterImageUrl;
  final String inviteeId;
  final String inviteeName;
  final String inviteeUsername;
  final String inviteeImageUrl;
  final String message;
  final InvitationStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? respondedAt;

  RoomInvitation({
    required this.id,
    required this.roomCode,
    required this.roomName,
    required this.inviterId,
    required this.inviterName,
    required this.inviterUsername,
    required this.inviterImageUrl,
    required this.inviteeId,
    required this.inviteeName,
    required this.inviteeUsername,
    required this.inviteeImageUrl,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.respondedAt,
  });

  factory RoomInvitation.fromMap(Map<String, dynamic> map, String id) {
    return RoomInvitation(
      id: id,
      roomCode: map['roomCode'] ?? '',
      roomName: map['roomName'] ?? '',
      inviterId: map['inviterId'] ?? '',
      inviterName: map['inviterName'] ?? '',
      inviterUsername: map['inviterUsername'] ?? '',
      inviterImageUrl: map['inviterImageUrl'] ?? '',
      inviteeId: map['inviteeId'] ?? '',
      inviteeName: map['inviteeName'] ?? '',
      inviteeUsername: map['inviteeUsername'] ?? '',
      inviteeImageUrl: map['inviteeImageUrl'] ?? '',
      message: map['message'] ?? '',
      status: InvitationStatus.values.firstWhere(
        (e) => e.toString() == 'InvitationStatus.${map['status']}',
        orElse: () => InvitationStatus.pending,
      ),
      createdAt:
          map['createdAt'] != null
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
      expiresAt:
          map['expiresAt'] != null
              ? (map['expiresAt'] as Timestamp).toDate()
              : DateTime.now().add(const Duration(hours: 24)),
      respondedAt:
          map['respondedAt'] != null
              ? (map['respondedAt'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomCode': roomCode,
      'roomName': roomName,
      'inviterId': inviterId,
      'inviterName': inviterName,
      'inviterUsername': inviterUsername,
      'inviterImageUrl': inviterImageUrl,
      'inviteeId': inviteeId,
      'inviteeName': inviteeName,
      'inviteeUsername': inviteeUsername,
      'inviteeImageUrl': inviteeImageUrl,
      'message': message,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'respondedAt':
          respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isPending => status == InvitationStatus.pending && !isExpired;

  RoomInvitation copyWith({
    String? id,
    String? roomCode,
    String? roomName,
    String? inviterId,
    String? inviterName,
    String? inviterUsername,
    String? inviterImageUrl,
    String? inviteeId,
    String? inviteeName,
    String? inviteeUsername,
    String? inviteeImageUrl,
    String? message,
    InvitationStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? respondedAt,
  }) {
    return RoomInvitation(
      id: id ?? this.id,
      roomCode: roomCode ?? this.roomCode,
      roomName: roomName ?? this.roomName,
      inviterId: inviterId ?? this.inviterId,
      inviterName: inviterName ?? this.inviterName,
      inviterUsername: inviterUsername ?? this.inviterUsername,
      inviterImageUrl: inviterImageUrl ?? this.inviterImageUrl,
      inviteeId: inviteeId ?? this.inviteeId,
      inviteeName: inviteeName ?? this.inviteeName,
      inviteeUsername: inviteeUsername ?? this.inviteeUsername,
      inviteeImageUrl: inviteeImageUrl ?? this.inviteeImageUrl,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}
