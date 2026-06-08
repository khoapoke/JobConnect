import '../../domain/entities/notification.dart' as domain;

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.body,
    this.dataJson,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String?,
      dataJson: json['data_json'] as Map<String, dynamic>?,
      read: json['read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String userId;
  final String type;
  final String title;
  final String? body;
  final Map<String, dynamic>? dataJson;
  final bool read;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'type': type,
        'title': title,
        'body': body,
        'data_json': dataJson,
        'read': read,
        'created_at': createdAt.toIso8601String(),
      };

  domain.Notification toEntity() => domain.Notification(
        id: id,
        userId: userId,
        type: type,
        title: title,
        body: body,
        dataJson: dataJson,
        read: read,
        createdAt: createdAt,
      );
}
