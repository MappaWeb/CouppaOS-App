import 'package:core/core.dart';

class MarkNotificationRead extends SystemListEvent {
  MarkNotificationRead(this.id);
  final String id;
}

class MarkAllNotificationsRead extends SystemListEvent {}
