import '../../../../import.dart';
import '../../../../widget/coupon_status_badge.dart';
import '../model.dart';

class MerchantCouponListItem extends StatelessWidget {
  const MerchantCouponListItem(this.item, {super.key, this.onTap});

  final VoucherModel item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final issued = item.issuedCount;
    final total = item.totalQuantity;
    final hasQuota = total > 0;
    final progress = hasQuota ? (issued / total).clamp(0.0, 1.0) : 0.0;
    final name = item.name.isEmpty ? '(không tên)' : item.name;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Palette.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_offer_outlined,
                color: Palette.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Palette.textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ),
                      if (item.status.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        CouponStatusBadge(item.status),
                      ],
                    ],
                  ),
                  if (item.code.isNotEmpty || item.faceValue != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (item.code.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
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
                        if (item.faceValue != null && item.faceValue! > 0) ...[
                          if (item.code.isNotEmpty) const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              formatCurrency(item.faceValue!.toDouble()),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
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
                            valueColor: const AlwaysStoppedAnimation(
                              Palette.primary,
                            ),
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
                        const Icon(
                          Icons.event_outlined,
                          size: 14,
                          color: Palette.textPrimary3,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'HSD ${date(item.validTo!.toIso8601String())}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Palette.textPrimary3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
