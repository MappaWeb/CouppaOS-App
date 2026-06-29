import '../../../../import.dart';
import '../model.dart';

class UserCouponListItem extends StatelessWidget {
  const UserCouponListItem(this.item, {super.key, this.onTap});

  final MyVoucherModel item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final exp = item.expiresAt;
    final isUsable = item.isUsable;
    final isExpired = exp != null &&
        !exp.isAfter(DateTime.now()) &&
        item.status.toUpperCase() != 'REDEEMED';

    return ItemBase(
      onPressed: onTap,
      showMultiActions: false,
      backgroundColor: Palette.cardColor,
      borderRadius: BorderRadius.circular(12),
      leading: const Padding(
        padding: EdgeInsets.only(top: 2),
        child: Icon(
          Icons.confirmation_number_outlined,
          color: Palette.primary,
        ),
      ),
      titleText: item.campaignName.isEmpty ? '(không tên)' : item.campaignName,
      content: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.merchantName.isNotEmpty)
              Text(
                item.merchantName,
                style: const TextStyle(
                  fontSize: 13,
                  color: Palette.textPrimary3,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  _StatusBadge(
                    status: item.status,
                    isExpired: isExpired,
                    isUsable: isUsable,
                  ),
                  const Spacer(),
                  if (exp != null)
                    Text(
                      'HSD: ${date(exp.toIso8601String())}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Palette.textPrimary3,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    required this.isExpired,
    required this.isUsable,
  });

  final String status;
  final bool isExpired;
  final bool isUsable;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = _resolve();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  (String, Color, Color) _resolve() {
    if (isUsable) {
      return ('Có thể dùng', Palette.successBgColor, Palette.successTxtColor);
    }
    if (isExpired) {
      return ('Hết hạn', const Color(0xFFFEE2E2), Palette.redTxtColor);
    }
    switch (status.toUpperCase()) {
      case 'REDEEMED':
        return ('Đã dùng', Palette.bgColor, Palette.textPrimary2);
      case 'REVOKED':
        return ('Đã thu hồi', const Color(0xFFFEE2E2), Palette.redTxtColor);
      default:
        return (status, Palette.bgColor, Palette.textPrimary2);
    }
  }
}
