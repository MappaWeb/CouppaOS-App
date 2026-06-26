import 'package:core/core.dart';

import 'app_localizations.dart';

/// Extension để truy cập AppLocalizations dễ dàng từ BuildContext
extension L10nExtension on BuildContext {
  /// Lấy AppLocalizations từ context hiện tại
  AppLocalizations get l10n {
    final localizations = AppLocalizations.of(this);
    return localizations;
  }
}

/// Helper class để truy cập AppLocalizations từ globalContext
class L10n {
  /// Lấy AppLocalizations từ globalContext
  /// 
  /// Sử dụng khi không có BuildContext trong scope
  /// Ví dụ: L10n.of.cameraPermissionRequired
  static AppLocalizations get of {
    try {
      final localizations = AppLocalizations.of(globalContext);
      return localizations;
    } catch (e) {
      throw FlutterError(
        'Failed to get AppLocalizations from globalContext: $e',
      );
    }
  }
}

