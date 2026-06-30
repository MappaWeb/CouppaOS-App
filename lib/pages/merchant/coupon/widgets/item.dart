import '../../../../import.dart';
import '../../../../widget/coupon_status_badge.dart';
import '../model.dart';

class MerchantCouponListItem extends StatelessWidget {
  const MerchantCouponListItem(this.item, {super.key, this.onTap, this.onEdit});

  final VoucherModel item;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final issued = item.issuedCount;
    final total = item.totalQuantity;
    final hasQuota = total > 0;
    final progress = hasQuota ? (issued / total).clamp(0.0, 1.0) : 0.0;
    final name = item.name.isEmpty ? '(không tên)' : item.name;
    final canEdit = item.status.toUpperCase() != 'ACTIVE';
    final isDirect = (item.issueMode ?? '').toUpperCase() == 'DIRECT';

    return ItemBase(
      onPressed: onTap,
      showMultiActions: true,
      actions: [
        ItemMenuAction(key: 'edit', label: 'Sửa', iconData: Icons.edit_outlined, enabled: canEdit),
      ],
      onAction: (ctx, key) {
        if (key == 'edit') onEdit?.call();
      },
      backgroundColor: Palette.cardColor,
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFFEEEEEE)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Palette.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.local_offer_outlined, color: Palette.primary, size: 22),
      ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
          if (item.status.isNotEmpty) ...[const SizedBox(width: 8), CouponStatusBadge(item.status)],
        ],
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.code.isNotEmpty || item.faceValue != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (item.code.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Palette.bgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.code,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Palette.textPrimary4,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                if (isDirect) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Palette.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Lô',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Palette.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: hasQuota ? progress : null,
                    minHeight: 6,
                    backgroundColor: Palette.bgColor,
                    valueColor: const AlwaysStoppedAnimation(Palette.primary),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                hasQuota ? '$issued/$total' : '$issued',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Palette.textPrimary2,
                ),
              ),
            ],
          ),
          if (item.validTo != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.event_outlined, size: 14, color: Palette.textPrimary3),
                const SizedBox(width: 4),
                Text(
                  'HSD ${date(item.validTo!.toIso8601String())}',
                  style: const TextStyle(fontSize: 12, color: Palette.textPrimary3),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
