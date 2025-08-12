class AppNotification {
  final String message;
  AppNotification({required this.message});

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(message: json['message'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'message': message};
  }
}
