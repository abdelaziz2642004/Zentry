import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_States.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';
import 'package:async/async.dart';
import 'package:zentry_pomodoro_app/features/Profile/views/widgets/profile_popup_dialog.dart';

class Joineduserspart extends StatelessWidget {
  const Joineduserspart({super.key, required this.roomCode});

  final String roomCode;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomCubit, RoomStates>(
      buildWhen: (previous, current) {
        return current is RoomJoinSuccess || current is RoomUsersUpdated;
      },
      builder: (context, state) {
        if (state is RoomJoinSuccess || state is RoomUsersUpdated) {
          final roomDetails = (state as dynamic).room;
          final joinedUsers = roomDetails.joinedUsers ?? [];

          // Add 24 fake users for demonstration
          final List<String> fakeUserIds = List.generate(
            24,
            (index) => 'fake_user_$index',
          );
          final allUsers = [...joinedUsers, ...fakeUserIds];

          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF05161A).withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF2CACAD).withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2CACAD).withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child:
                  allUsers.isEmpty
                      ? Container(
                        height: 200,
                        padding: const EdgeInsets.all(32.0),
                        child: const Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.people_outline,
                                color: Color(0xFF6DA5C0),
                                size: 48,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No users in room yet',
                                style: TextStyle(
                                  color: Color(0xFF6DA5C0),
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Be the first to join!',
                                style: TextStyle(
                                  color: Color(0xFF6DA5C0),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6, // 6 columns like in the image
                              childAspectRatio:
                                  1.0, // Perfect square for circles
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: allUsers.length,
                        itemBuilder: (context, index) {
                          final userId = allUsers[index];
                          final isFakeUser = userId.startsWith('fake_user_');

                          if (isFakeUser) {
                            // Fake user with generated avatar and alternating colors
                            final borderColor =
                                index % 2 == 0
                                    ? const Color(0xFF2CACAD) // Bright blue
                                    : const Color(0xFF0F9E9C); // Bright orange

                            // Generate different fake avatars
                            final avatarType = index % 4; // 4 different types
                            Widget avatarContent;

                            switch (avatarType) {
                              case 0:
                                // Colored circle with letter
                                avatarContent = Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF75E2E0),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(
                                        65 + (index % 26),
                                      ), // A, B, C, etc.
                                      style: const TextStyle(
                                        color: Color(0xFF05161A),
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                                break;
                              case 1:
                                // Gradient circle
                                avatarContent = Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF2CACAD),
                                        Color(0xFF0F9E9C),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                );
                                break;
                              case 2:
                                // Pattern circle
                                avatarContent = Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6DA5C0),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.star,
                                    color: Color(0xFF05161A),
                                    size: 30,
                                  ),
                                );
                                break;
                              default:
                                // Icon circle
                                avatarContent = Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0C7075),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.favorite,
                                    color: Color(0xFFD9F5F0),
                                    size: 30,
                                  ),
                                );
                                break;
                            }

                            return Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: borderColor,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: borderColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: ClipOval(child: avatarContent),
                            );
                          } else {
                            // Real user from StreamBuilder
                            return StreamBuilder<DocumentSnapshot>(
                              stream:
                                  FirebaseFirestore.instance
                                      .collection(
                                        FirebaseConstants.usersCollection,
                                      )
                                      .doc(userId)
                                      .snapshots(),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.hasData &&
                                    userSnapshot.data!.exists) {
                                  final userData =
                                      userSnapshot.data!.data()
                                          as Map<String, dynamic>;
                                  final userName =
                                      userData[FirebaseConstants
                                          .fullNameField] ??
                                      'Unknown User';
                                  final userImage =
                                      userData[FirebaseConstants
                                          .imageUrlField] ??
                                      '';

                                  // Alternating border colors like in the image
                                  final borderColor =
                                      index % 2 == 0
                                          ? const Color(
                                            0xFF2CACAD,
                                          ) // Bright blue
                                          : const Color(
                                            0xFF0F9E9C,
                                          ); // Bright orange

                                  return GestureDetector(
                                    onTap:
                                        () => _showUserProfile(
                                          context,
                                          userId,
                                          userName,
                                        ),
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: borderColor,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: borderColor.withOpacity(0.3),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child:
                                            userImage.isNotEmpty
                                                ? Image.network(
                                                  userImage,
                                                  fit: BoxFit.cover,
                                                  width: 60,
                                                  height: 60,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return Container(
                                                      width: 60,
                                                      height: 60,
                                                      color: const Color(
                                                        0xFF072E33,
                                                      ),
                                                      child: Icon(
                                                        Icons.person,
                                                        color: const Color(
                                                          0xFF6DA5C0,
                                                        ),
                                                        size: 30,
                                                      ),
                                                    );
                                                  },
                                                )
                                                : Container(
                                                  width: 60,
                                                  height: 60,
                                                  color: const Color(
                                                    0xFF072E33,
                                                  ),
                                                  child: Icon(
                                                    Icons.person,
                                                    color: const Color(
                                                      0xFF6DA5C0,
                                                    ),
                                                    size: 30,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  );
                                } else {
                                  // Loading state for user data
                                  final borderColor =
                                      index % 2 == 0
                                          ? const Color(0xFF2CACAD)
                                          : const Color(0xFF0F9E9C);

                                  return Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: borderColor,
                                        width: 3,
                                      ),
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Color(0xFF75E2E0),
                                              ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          }
                        },
                      ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showUserProfile(BuildContext context, String userId, String userName) {
    showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) =>
              ProfilePopupDialog(userId: userId, userName: userName),
    );
  }
}
