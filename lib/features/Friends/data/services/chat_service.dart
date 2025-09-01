import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/chat_message.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/online_status_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/block_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/user_service.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final OnlineStatusService _onlineStatusService = OnlineStatusService();
  final BlockService _blockService = BlockService();
  final UserService _userService = UserService();

  /// Send a text message to a friend
  Future<void> sendMessage({
    required String receiverId,
    required String receiverName,
    required String content,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    // Check if users can interact (not blocked)
    final canInteract = await _blockService.canUsersInteract(
      currentUser.uid,
      receiverId,
    );
    if (!canInteract) {
      throw Exception(
        'Cannot send message - user is blocked or has blocked you',
      );
    }

    // Get current user data
    final userData = await _userService.getUserData(currentUser.uid);
    if (userData == null) throw Exception('User data not found');

    final message = ChatMessage(
      id: '', // Will be set by Firestore
      senderId: currentUser.uid,
      senderName: userData[FirebaseConstants.fullNameField] ?? '',
      receiverId: receiverId,
      receiverName: receiverName,
      content: content,
      type: MessageType.text,
      timestamp: DateTime.now(),
      isRead: false,
    );

    await _firestore.collection('directMessages').add(message.toMap());
  }

  /// Send a room invitation as a message
  Future<void> sendRoomInvitation({
    required String receiverId,
    required String receiverName,
    required String roomCode,
    required String roomName,
    String? message,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    // Check if users can interact (not blocked)
    final canInteract = await _blockService.canUsersInteract(
      currentUser.uid,
      receiverId,
    );
    if (!canInteract) {
      throw Exception(
        'Cannot send invitation - user is blocked or has blocked you',
      );
    }

    // Get current user data
    final userData = await _userService.getUserData(currentUser.uid);
    if (userData == null) throw Exception('User data not found');

    final invitationMessage = ChatMessage(
      id: '', // Will be set by Firestore
      senderId: currentUser.uid,
      senderName: userData[FirebaseConstants.fullNameField] ?? '',
      receiverId: receiverId,
      receiverName: receiverName,
      content: message ?? 'Join me in studying!',
      type: MessageType.roomInvitation,
      timestamp: DateTime.now(),
      isRead: false,
      roomCode: roomCode,
      roomName: roomName,
      inviterName: userData[FirebaseConstants.fullNameField] ?? '',
    );

    await _firestore
        .collection('directMessages')
        .add(invitationMessage.toMap());
  }

  /// Get chat messages between two users with dynamic user data
  Stream<List<ChatMessage>> getChatMessages(String otherUserId) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('directMessages')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
                  .where(
                    (message) =>
                        (message.senderId == currentUser.uid &&
                            message.receiverId == otherUserId) ||
                        (message.senderId == otherUserId &&
                            message.receiverId == currentUser.uid),
                  )
                  .toList()
                ..sort((a, b) => a.timestamp.compareTo(b.timestamp)),
        );
  }

  /// Get all chat conversations for current user with dynamic user data
  Stream<List<Map<String, dynamic>>> getChatConversations() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore.collection('directMessages').snapshots().asyncMap((
      snapshot,
    ) async {
      final conversations = <String, Map<String, dynamic>>{};

      for (final doc in snapshot.docs) {
        final message = ChatMessage.fromMap(doc.data(), doc.id);

        // Only process messages involving current user
        if (message.senderId == currentUser.uid ||
            message.receiverId == currentUser.uid) {
          final otherUserId =
              message.senderId == currentUser.uid
                  ? message.receiverId
                  : message.senderId;

          final otherUserName =
              message.senderId == currentUser.uid
                  ? message.receiverName
                  : message.senderName;

          if (!conversations.containsKey(otherUserId)) {
            // Get online status for this user
            final userStatus =
                await _onlineStatusService.getUserStatus(otherUserId).first;

            conversations[otherUserId] = {
              'userId': otherUserId,
              'userName': otherUserName,
              'lastMessage': message.content,
              'lastMessageTime': message.timestamp,
              'unreadCount': 0, // Will be calculated below
              'isOnline': userStatus['online'] ?? false,
              'lastSeen': userStatus['lastSeen'],
            };
          }

          // Always update unread count for this message
          final existing = conversations[otherUserId]!;
          if (message.receiverId == currentUser.uid && !message.isRead) {
            existing['unreadCount'] = (existing['unreadCount'] ?? 0) + 1;
          }

          // Update with latest message if this one is newer
          if (message.timestamp.isAfter(existing['lastMessageTime'])) {
            existing['lastMessage'] = message.content;
            existing['lastMessageTime'] = message.timestamp;
          }
        }
      }

      return conversations.values.toList()..sort(
        (a, b) => (b['lastMessageTime'] as DateTime).compareTo(
          a['lastMessageTime'] as DateTime,
        ),
      );
    });
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String otherUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final batch = _firestore.batch();
      bool hasUnreadMessages = false;

      // Get all messages and filter in Dart
      final allMessages = await _firestore.collection('directMessages').get();

      for (final doc in allMessages.docs) {
        final message = ChatMessage.fromMap(doc.data(), doc.id);
        if (message.senderId == otherUserId &&
            message.receiverId == currentUser.uid &&
            !message.isRead) {
          batch.update(doc.reference, {'isRead': true});
          hasUnreadMessages = true;
        }
      }

      // Only commit if there are unread messages to update
      if (hasUnreadMessages) {
        await batch.commit();
        print('Marked messages as read for user: $otherUserId');
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  /// Get total unread message count across all conversations
  Stream<int> getTotalUnreadCount() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value(0);

    return _firestore.collection('directMessages').snapshots().map((snapshot) {
      int totalUnread = 0;
      for (final doc in snapshot.docs) {
        final message = ChatMessage.fromMap(doc.data(), doc.id);
        if (message.receiverId == currentUser.uid && !message.isRead) {
          totalUnread++;
        }
      }
      return totalUnread;
    });
  }

  /// Get unread count for specific user stream
  Stream<int> getUnreadCountForUser(String userId) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value(0);

    return _firestore.collection('directMessages').snapshots().map((snapshot) {
      int unreadCount = 0;
      for (final doc in snapshot.docs) {
        final message = ChatMessage.fromMap(doc.data(), doc.id);
        if (message.senderId == userId &&
            message.receiverId == currentUser.uid &&
            !message.isRead) {
          unreadCount++;
        }
      }
      return unreadCount;
    });
  }

  /// Delete a message (only for message sender)
  Future<void> deleteMessage(String messageId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    // Get the message to check if user is the sender
    final messageDoc =
        await _firestore.collection('directMessages').doc(messageId).get();

    if (!messageDoc.exists) {
      throw Exception('Message not found');
    }

    final message = ChatMessage.fromMap(messageDoc.data()!, messageId);

    // Only allow deletion if user is the sender
    if (message.senderId != currentUser.uid) {
      throw Exception('You can only delete your own messages');
    }

    await _firestore.collection('directMessages').doc(messageId).delete();
  }

  /// Add or remove a reaction to a message
  Future<void> toggleReaction(String messageId, String emoji) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final messageRef = _firestore.collection('directMessages').doc(messageId);

    await _firestore.runTransaction((transaction) async {
      final messageDoc = await transaction.get(messageRef);

      if (!messageDoc.exists) {
        throw Exception('Message not found');
      }

      final data = messageDoc.data()!;
      final reactions = Map<String, List<String>>.from(
        (data['reactions'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(key, List<String>.from(value)),
            ) ??
            {},
      );

      final userId = currentUser.uid;
      final newReactions = <String, List<String>>{};

      // Check if user already reacted with this emoji
      bool userHasReacted = false;
      for (final entry in reactions.entries) {
        if (entry.key == emoji) {
          if (entry.value.contains(userId)) {
            // Remove reaction from this emoji
            final newList = List<String>.from(entry.value)..remove(userId);
            if (newList.isNotEmpty) {
              newReactions[emoji] = newList;
            }
            userHasReacted = true;
          } else {
            // Add reaction to this emoji (keep existing users)
            final newList = List<String>.from(entry.value)..add(userId);
            newReactions[emoji] = newList;
            userHasReacted = true;
          }
        } else {
          // Keep other emoji reactions but remove this user
          final newList = List<String>.from(entry.value)..remove(userId);
          if (newList.isNotEmpty) {
            newReactions[entry.key] = newList;
          }
        }
      }

      // If user hasn't reacted with this emoji yet, add it
      if (!userHasReacted) {
        newReactions[emoji] = [userId];
      }

      transaction.update(messageRef, {'reactions': newReactions});
    });
  }

  /// Send a reply message
  Future<void> sendReplyMessage({
    required String receiverId,
    required String receiverName,
    required String content,
    required String replyToMessageId,
    required String replyToMessageContent,
    required String replyToSenderName,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    // Check if users can interact (not blocked)
    final canInteract = await _blockService.canUsersInteract(
      currentUser.uid,
      receiverId,
    );
    if (!canInteract) {
      throw Exception(
        'Cannot send message - user is blocked or has blocked you',
      );
    }

    // Get current user data
    final userData = await _userService.getUserData(currentUser.uid);
    if (userData == null) throw Exception('User data not found');

    final message = ChatMessage(
      id: '', // Will be set by Firestore
      senderId: currentUser.uid,
      senderName: userData[FirebaseConstants.fullNameField] ?? '',
      receiverId: receiverId,
      receiverName: receiverName,
      content: content,
      type: MessageType.text,
      timestamp: DateTime.now(),
      isRead: false,
      replyToMessageId: replyToMessageId,
      replyToMessageContent: replyToMessageContent,
      replyToSenderName: replyToSenderName,
    );

    await _firestore.collection('directMessages').add(message.toMap());
  }
}
