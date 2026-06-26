import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/notification_preferences.dart';

class NotificationDataSource {
  NotificationDataSource(this._dio);

  final Dio _dio;

  Future<int> fetchUnreadCount() async {
    try {
      final res = await _dio.get<dynamic>('/notifications/unread-count');
      final data = res.data;
      if (data is Map) {
        return (data['count'] ?? data['unreadCount'] ?? 0) as int;
      }
      if (data is int) return data;
      return 0;
    } on DioException catch (e) {
      debugPrint('NotificationDataSource.fetchUnreadCount error: $e');
      return 0;
    }
  }

  Future<bool> markAsRead(String id) async {
    try {
      await _dio.patch<dynamic>('/notifications/$id/read');
      return true;
    } on DioException catch (e) {
      debugPrint('NotificationDataSource.markAsRead error: $e');
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      await _dio.patch<dynamic>('/notifications/read-all');
      return true;
    } on DioException catch (e) {
      debugPrint('NotificationDataSource.markAllAsRead error: $e');
      return false;
    }
  }

  Future<NotificationPreferences?> fetchPreferences() async {
    try {
      final res = await _dio.get<dynamic>('/notifications/preferences');
      final data = res.data;
      if (data is Map) {
        return NotificationPreferences.fromJson(
          Map<String, dynamic>.from(data),
        );
      }
      return const NotificationPreferences();
    } on DioException catch (e) {
      debugPrint('NotificationDataSource.fetchPreferences error: $e');
      return null;
    }
  }

  Future<bool> updatePreferences(NotificationPreferences preferences) async {
    try {
      await _dio.patch<dynamic>(
        '/notifications/preferences',
        data: preferences.toJson(),
      );
      return true;
    } on DioException catch (e) {
      debugPrint('NotificationDataSource.updatePreferences error: $e');
      return false;
    }
  }
}
