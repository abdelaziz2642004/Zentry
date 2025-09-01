import 'package:cloud_firestore/cloud_firestore.dart';

class StudyGroup {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final String creatorName;
  final String creatorImageUrl;
  final DateTime createdAt;
  final bool isPublic;
  final int maxMembers;
  final List<String> memberIds;
  final List<String> adminIds;
  final List<String> tags;
  final String category; // e.g., "Math", "Science", "Literature"
  final String imageUrl;
  final int messageCount;
  final DateTime lastActivity;
  final String? password; // Password for private groups

  StudyGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.creatorName,
    required this.creatorImageUrl,
    required this.createdAt,
    required this.isPublic,
    required this.maxMembers,
    required this.memberIds,
    required this.adminIds,
    required this.tags,
    required this.category,
    required this.imageUrl,
    required this.messageCount,
    required this.lastActivity,
    this.password,
  });

  factory StudyGroup.fromMap(Map<String, dynamic> map, String id) {
    return StudyGroup(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      creatorId: map['creatorId'] ?? '',
      creatorName: map['creatorName'] ?? '',
      creatorImageUrl: map['creatorImageUrl'] ?? '',
      createdAt:
          map['createdAt'] != null
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
      isPublic: map['isPublic'] ?? true,
      maxMembers: map['maxMembers'] ?? 50,
      memberIds: List<String>.from(map['memberIds'] ?? []),
      adminIds: List<String>.from(map['adminIds'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      category: map['category'] ?? 'General',
      imageUrl: map['imageUrl'] ?? '',
      messageCount: map['messageCount'] ?? 0,
      lastActivity:
          map['lastActivity'] != null
              ? (map['lastActivity'] as Timestamp).toDate()
              : DateTime.now(),
      password: map['password'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorImageUrl': creatorImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPublic': isPublic,
      'maxMembers': maxMembers,
      'memberIds': memberIds,
      'adminIds': adminIds,
      'tags': tags,
      'category': category,
      'imageUrl': imageUrl,
      'messageCount': messageCount,
      'lastActivity': Timestamp.fromDate(lastActivity),
      'password': password,
    };
  }

  bool get isFull => memberIds.length >= maxMembers;
  bool get canJoin => isPublic && !isFull;
  int get memberCount => memberIds.length;
  bool get isPrivate => !isPublic && password != null;

  StudyGroup copyWith({
    String? id,
    String? name,
    String? description,
    String? creatorId,
    String? creatorName,
    String? creatorImageUrl,
    DateTime? createdAt,
    bool? isPublic,
    int? maxMembers,
    List<String>? memberIds,
    List<String>? adminIds,
    List<String>? tags,
    String? category,
    String? imageUrl,
    int? messageCount,
    DateTime? lastActivity,
    String? password,
  }) {
    return StudyGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      creatorImageUrl: creatorImageUrl ?? this.creatorImageUrl,
      createdAt: createdAt ?? this.createdAt,
      isPublic: isPublic ?? this.isPublic,
      maxMembers: maxMembers ?? this.maxMembers,
      memberIds: memberIds ?? this.memberIds,
      adminIds: adminIds ?? this.adminIds,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      messageCount: messageCount ?? this.messageCount,
      lastActivity: lastActivity ?? this.lastActivity,
      password: password ?? this.password,
    );
  }
}
