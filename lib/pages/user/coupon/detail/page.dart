import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../import.dart';
import '../model.dart';

class UserCouponDetailPage extends StatelessWidget {
  const UserCouponDetailPage(this.args, {super.key});

  final Map? args;

  @override
  Widget build(BuildContext context) {
    final item = MyVoucherModel.fromJson(Map<String, dynamic>.from(args ?? {}));
    final exp = item.expiresAt;
    final isUsable = item.isUsable;
    final status = item.status.toUpperCase();
    final isExpired = !isUsable && status == 'ISSUED' && exp != null && !exp.isAfter(DateTime.now());
    final isUsed = status == 'REDEEMED';
    final isRevoked = status == 'REVOKED';

    return Scaffold(
      backgroundColor: Palette.bgColor,
      appBar: BaseAppBar(
        context: context,
        title: const Text('Chi tiết coupon'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isUsable)
              _QrHero(code: item.code)
            else
              _StateBanner(
                isUsed: isUsed,
                isExpired: isExpired,
                isRevoked: isRevoked,
              ),
            const SizedBox(height: 16),
            _InfoCard(item: item),
          ],
        ),
      ),
    );
  }
}

class _QrHero extends StatelessWidget {
  const _QrHero({required this.code});

  final String code;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: code));
    showMessage('Đã sao chép mã coupon', type: 'success');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Palette.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          if (code.isNotEmpty)
            QrImageView(
              data: code,
              version: QrVersions.auto,
              size: 220,
              backgroundColor: Palette.cardColor,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Palette.textPrimary,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Palette.textPrimary,
              ),
            )
          else
            const SizedBox(
              height: 220,
              child: Center(
                child: Text(
                  'Không có mã coupon',
                  style: TextStyle(color: Palette.textPrimary4),
                ),
              ),
            ),
          const SizedBox(height: 16),
          const Text(
            'Mã coupon',
            style: TextStyle(
              fontSize: 12,
              color: Palette.textPrimary3,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            code.isEmpty ? '—' : code,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              color: Palette.textPrimary,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (code.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _copy(context),
                icon: const Icon(Icons.content_copy, size: 18),
                label: const Text('Sao chép mã'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Palette.primary,
                  side: const BorderSide(color: Palette.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StateBanner extends StatelessWidget {
  const _StateBanner({
    required this.isUsed,
    required this.isExpired,
    required this.isRevoked,
  });

  final bool isUsed;
  final bool isExpired;
  final bool isRevoked;

  @override
  Widget build(BuildContext context) {
    final (icon, label, sublabel, bg, fg) = _resolve();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 56, color: fg),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            sublabel,
            style: const TextStyle(
              fontSize: 13,
              color: Palette.textPrimary4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  (IconData, String, String, Color, Color) _resolve() {
    if (isUsed) {
      return (
        Icons.check_circle_outline,
        'Coupon đã được sử dụng',
        'Mã coupon này đã được dùng và không thể sử dụng lại.',
        Palette.bgColor,
        Palette.textPrimary2,
      );
    }
    if (isRevoked) {
      return (
        Icons.block,
        'Coupon đã bị thu hồi',
        'Mã coupon này đã bị thu hồi và không còn hiệu lực.',
        const Color(0xFFFEE2E2),
        Palette.redTxtColor,
      );
    }
    if (isExpired) {
      return (
        Icons.schedule,
        'Coupon đã hết hạn',
        'Mã coupon này đã quá hạn sử dụng.',
        const Color(0xFFFEE2E2),
        Palette.redTxtColor,
      );
    }
    return (
      Icons.help_outline,
      'Coupon không khả dụng',
      'Mã coupon này hiện không thể sử dụng.',
      Palette.bgColor,
      Palette.textPrimary2,
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.item});

  final MyVoucherModel item;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      if (item.campaignName.isNotEmpty) ('Chiến dịch', item.campaignName),
      if (item.merchantName.isNotEmpty) ('Đơn vị phát hành', item.merchantName),
      if (item.faceValue != null) ('Giá trị', _formatValue(item.faceValue!)),
      if (item.expiresAt != null) ('Hạn sử dụng', date(item.expiresAt!.toIso8601String())),
      if (item.claimedAt != null) ('Ngày nhận', date(item.claimedAt!.toIso8601String())),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Palette.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFF1F1F1)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      rows[i].$1,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Palette.textPrimary3,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      rows[i].$2,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Palette.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatValue(num value) {
    final asInt = value.toInt();
    if (value == asInt) return '$asInt';
    return value.toString();
  }
}
