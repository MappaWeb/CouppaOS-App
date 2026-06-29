import '../import.dart';

class CouponStatusBadge extends StatelessWidget {
  final String status;
  final AppStatusSize size;

  const CouponStatusBadge(this.status, {super.key, this.size = AppStatusSize.normal});

  @override
  Widget build(BuildContext context) {
    final s = status.toUpperCase();
    final label = _label(s);
    final isLarge = size == AppStatusSize.large;

    switch (s) {
      case 'ACTIVE':
      case 'APPROVED':
        return isLarge ? AppStatus.successLarge(label) : AppStatus.success(label);

      case 'ISSUED':
        return isLarge ? AppStatus.informationLarge(label) : AppStatus.information(label);

      case 'PENDING':
        return isLarge ? AppStatus.warningLarge(label) : AppStatus.warning(label);

      case 'REJECTED':
      case 'CANCELLED':
        return isLarge ? AppStatus.errorLarge(label) : AppStatus.error(label);

      case 'EXPIRED':
      case 'DRAFT':
      default:
        return isLarge ? AppStatus.expiredLarge(label) : AppStatus.expired(label);
    }
  }

  static String _label(String upper) {
    switch (upper) {
      case 'DRAFT':
        return 'Nháp';
      case 'PENDING':
        return 'Chờ duyệt';
      case 'APPROVED':
        return 'Đã duyệt';
      case 'ACTIVE':
        return 'Đang hoạt động';
      case 'ISSUED':
        return 'Đã phát hành';
      case 'REJECTED':
        return 'Từ chối';
      case 'CANCELLED':
        return 'Đã hủy';
      case 'EXPIRED':
        return 'Hết hạn';
      default:
        return upper.isEmpty ? '—' : upper;
    }
  }
}
