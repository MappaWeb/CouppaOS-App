import '../global.dart';

/// Dev-only bypass cho auth. Đặt [enabled] = false trước khi release.
class DevBypass {
  DevBypass._();

  static const bool enabled = true;

  static UserRole _role = UserRole.user;
  static bool _active = false;

  static bool get active => enabled && _active;
  static UserRole get role => _role;

  static void enter(UserRole role) {
    _active = true;
    _role = role;
  }

  static void exit() {
    _active = false;
  }
}
