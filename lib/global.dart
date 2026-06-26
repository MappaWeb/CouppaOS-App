import 'config/app_flavor.dart';
import 'import.dart';

String get myDomain => AppFlavorConfig.instance.appDomain;

enum UserRole { user, merchant }

MeUser? get currentUser {
  final state = AuthSetup.instance.authSessionBloc.state;
  return state is AuthAuthenticated ? state.session.user : null;
}

UserRole getRole() {
  final String? roleString = currentUser?.role;
  switch (roleString?.toLowerCase()) {
    case 'merchant':
    case 'merchant_admin':
    case 'merchant_staff':
    case 'seller':
    case 'shop':
      return UserRole.merchant;
    case 'user':
    case 'customer':
    case 'buyer':
    default:
      return UserRole.user;
  }
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
