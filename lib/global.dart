import 'config/app_flavor.dart';
import 'data/account/account_roles.dart';
import 'import.dart';

String get myDomain => AppFlavorConfig.instance.appDomain;

enum UserRole { user, merchant }

MeUser? get currentUser {
  final state = AuthSetup.instance.authSessionBloc.state;
  return state is AuthAuthenticated ? state.session.user : null;
}

/// Role thực tế của tài khoản đang đăng nhập. App tự suy từ mảng `roles`
/// của /auth/me (qua [AccountRoles]), không dùng `MeUser.role` của AppCore —
/// vốn không xử lý được roles dạng object `{role, scopeMerchantId}`.
UserRole getAccountRole() {
  return AccountRoles.instance.isMerchant ? UserRole.merchant : UserRole.user;
}

/// Bật khi tài khoản merchant chọn duyệt app như một người dùng thường.
/// Chỉ có ý nghĩa khi [canSwitchView] đúng. Shell router, bottom nav và
/// account page đều lắng nghe notifier này để đổi giao diện tức thời.
final ValueNotifier<bool> viewAsUser = ValueNotifier<bool>(false);

/// Tài khoản hiện tại có quyền chuyển đổi giữa view merchant/user hay không.
bool get canSwitchView => getAccountRole() == UserRole.merchant;

/// Reset chế độ xem về mặc định (gọi khi logout / đổi tài khoản).
void resetViewMode() => viewAsUser.value = false;

/// Role hiệu lực dùng cho điều hướng và UI. Merchant có thể tạm thời
/// hạ xuống view user qua [viewAsUser]; các role khác giữ nguyên.
UserRole getRole() {
  if (canSwitchView && viewAsUser.value) return UserRole.user;
  return getAccountRole();
}

enum CouponStatus { active, used, expired }

String couponStatusLabel(CouponStatus status) {
  switch (status) {
    case CouponStatus.active:
      return 'Còn hạn';
    case CouponStatus.used:
      return 'Đã dùng';
    case CouponStatus.expired:
      return 'Hết hạn';
  }
}

bool isInputEmail(String value) {
  return RegExp(r'[a-zA-Z@]').hasMatch(value);
}

String formatCurrency(double? amount) {
  if (amount == null) return '0đ';
  return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
}

extension FormatCurrencyExtension on dynamic {
  String toCustomFormat() {
    if (this == null) return '0';

    num? number;

    if (this is num) {
      number = this;
    } else if (this is String) {
      if (toString().isEmpty) return '0';
      number = num.tryParse(toString());
    }

    return NumberFormat.decimalPattern('vi_VN').format(number ?? 0);
  }
}
