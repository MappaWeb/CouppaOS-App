import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class NotificationDataSource {
  NotificationDataSource(this._dio);

  final Dio _dio;

  Future<int> fetchUnreadCount() async {
    try {
      final res = await _dio.get<dynamic>('/api/notifications/unread-count');
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
      await _dio.post<dynamic>('/api/notifications/$id/read');
      return true;
    } on DioException catch (e) {
      debugPrint('NotificationDataSource.markAsRead error: $e');
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      await _dio.post<dynamic>('/api/notifications/read-all');
      return true;
    } on DioException catch (e) {
      debugPrint('NotificationDataSource.markAllAsRead error: $e');
      return false;
    }
  }
}
