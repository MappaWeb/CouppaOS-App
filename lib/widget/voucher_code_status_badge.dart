import '../import.dart';

class VoucherCodeStatusBadge extends StatelessWidget {
  final String status;
  final AppStatusSize size;

  const VoucherCodeStatusBadge(this.status, {super.key, this.size = AppStatusSize.normal});

  @override
  Widget build(BuildContext context) {
    final s = status.toUpperCase();
    final label = _label(s);
    final isLarge = size == AppStatusSize.large;

    switch (s) {
      case 'ISSUED':
        return isLarge ? AppStatus.expiredLarge(label) : AppStatus.expired(label);

      case 'REDEEMED':
        return isLarge ? AppStatus.other1Large(label) : AppStatus.other1(label);

      // case 'RESERVED':
      //   return isLarge ? AppStatus.warningLarge(label) : AppStatus.warning(label);

      case 'AVAILABLE':
        return isLarge ? AppStatus.informationLarge(label) : AppStatus.information(label);

      // case 'CANCELLED':
      //   return isLarge ? AppStatus.errorLarge(label) : AppStatus.error(label);

      case 'EXPIRED':
      default:
        return isLarge ? AppStatus.expiredLarge(label) : AppStatus.expired(label);
    }
  }

  static String _label(String upper) {
    switch (upper) {
      case 'AVAILABLE':
        return 'Sẵn sàng';
      // case 'RESERVED':
      //   return 'Đang giữ chỗ';
      case 'ISSUED':
        return 'Chưa dùng';
      case 'REDEEMED':
        return 'Đã sử dụng';
      case 'EXPIRED':
        return 'Hết hạn';
      // case 'CANCELLED':
      //   return 'Đã hủy';
      default:
        return upper.isEmpty ? '—' : upper;
    }
  }
}
