import '../../../../import.dart';
import '../model.dart';

class MerchantCouponListItem extends StatelessWidget {
  const MerchantCouponListItem(this.item, {super.key, this.onTap});

  final VoucherModel item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final issued = item.issuedCount;
    final total = item.totalQuantity;
    final ratio = total > 0 ? '$issued/$total' : '$issued';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.local_offer, color: Palette.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name.isEmpty ? '(không tên)' : item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Palette.textPrimary,
                    ),
                  ),
                  if (item.code.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.code,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Palette.textPrimary4,
                      ),
                    ),
                  ],
                  if (item.validTo != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'HSD: ${date(item.validTo!.toIso8601String())}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Palette.textPrimary3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(status: item.status),
                const SizedBox(height: 6),
                Text(
                  ratio,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Palette.textPrimary2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    if (status.isEmpty) return const SizedBox.shrink();
    final (bg, fg) = _colorFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  static (Color, Color) _colorFor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
      case 'ISSUED':
        return (Palette.successBgColor, Palette.successTxtColor);
      case 'EXPIRED':
      case 'CANCELLED':
        return (const Color(0xFFFEE2E2), Palette.redTxtColor);
      case 'DRAFT':
      default:
        return (Palette.bgColor, Palette.textPrimary2);
    }
  }
}
