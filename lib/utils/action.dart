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
}
