import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class ActionUtils {
  ActionUtils._();

  static Future<void> makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      print('ActionUtils: Số điện thoại rỗng');
      return;
    }
    final String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanNumber.isEmpty) {
      debugPrint('ActionUtils: Số điện thoại không hợp lệ');
      return;
    }

    final Uri launchUri = Uri(scheme: 'tel', path: cleanNumber);

    try {
      // Gọi thẳng launchUrl: canLaunchUrl thường trả false cho scheme `tel`
      // khi thiếu khai báo queries (Android) / LSApplicationQueriesSchemes (iOS).
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } on Exception catch (e) {
      debugPrint('ActionUtils Error: $e');
    }
  }

  /// Mở bản đồ ngoài (Google/Apple Maps qua trình duyệt → app maps) tới toạ độ
  /// hoặc theo từ khoá địa chỉ. Dùng universal Google Maps URL để chạy cả
  /// iOS & Android mà không cần khai báo URL scheme.
  static Future<void> openMap({
    double? latitude,
    double? longitude,
    String? query,
  }) async {
    Uri uri;
    if (latitude != null && longitude != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      );
    } else if (query != null && query.trim().isNotEmpty) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query.trim())}',
      );
    } else {
      debugPrint('ActionUtils.openMap: thiếu toạ độ và từ khoá');
      return;
    }
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Exception catch (e) {
      debugPrint('ActionUtils.openMap Error: $e');
    }
  }
}
