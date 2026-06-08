import 'package:flutter/foundation.dart';

@immutable
class Notification {
  const Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.body,
    this.dataJson,
    required this.read,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String type;
  final String title;
  final String? body;
  final Map<String, dynamic>? dataJson;
  final bool read;
  final DateTime createdAt;

  Notification copyWith({
    bool? read,
  }) =>
      Notification(
        id: id,
        userId: userId,
        type: type,
        title: title,
        body: body,
        dataJson: dataJson,
        read: read ?? this.read,
        createdAt: createdAt,
      );
}
