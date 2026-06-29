import 'package:couppa_mini/widget/coupon_status_badge.dart';
import 'package:couppa_mini/widget/voucher_code_status_badge.dart';

import '../../../../import.dart';
import 'bloc.dart';

class MerchantCouponDetailPage extends StatelessWidget {
  const MerchantCouponDetailPage(this.map, {super.key});

  final Map? map;

  @override
  Widget build(BuildContext context) {
    final id = (map?['id'] ?? '').toString();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MerchantCouponDetailBloc(id)),
        BlocProvider(create: (_) => MerchantCouponDetailCodesBloc(id)),
      ],
      child: _Content(id: id),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SystemDetailScaffold<MerchantCouponDetailBloc>(
        appBar: AppBar(
          title: const Text('Chi tiết chiến dịch'),
          actions: [_DetailMenu(id: id)],
          bottom: const TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: 'Thông tin'),
              Tab(text: 'Danh sách mã'),
            ],
          ),
        ),
        builder: (context, state, response) {
          return TabBarView(
            children: [
              _InfoTab(data: response),
              const _CodesTab(),
            ],
          );
        },
      ),
    );
  }
}

class _DetailMenu extends StatelessWidget {
  const _DetailMenu({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MerchantCouponDetailBloc, SystemDetailState, String>(
      selector: (state) => (state.result['status'] ?? '').toString().toUpperCase(),
      builder: (context, status) {
        final canEdit = status != 'ACTIVE';
        return PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) async {
            if (value == 'edit') {
              await appNavigator.pushNamed(
                RouterConstants.merchantCouponForm,
                arguments: {'id': id},
              );
              if (context.mounted) {
                context.read<MerchantCouponDetailBloc>().add(RefreshBaseDetail());
              }
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'edit',
              enabled: canEdit,
              child: Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: canEdit ? null : Palette.textPrimary3,
                  ),
                  const SizedBox(width: 8),
                  Text(canEdit ? 'Sửa' : 'Sửa (đang Active)'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// Tab 1 — Thông tin
// ============================================================

class _InfoTab extends StatelessWidget {
  const _InfoTab({required this.data});

  final Map data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Section(
            title: 'Thông tin chung',
            child: ItemBaseContent(
              items: [
                ContentLineInfo('Tên chiến dịch', data['name'] ?? ''),
                ContentLineInfo(
                  'Trạng thái',
                  CouponStatusBadge((data['status'] ?? '').toString()),
                  child: Row(
                    children: [
                      const Text('Trạng thái', style: TextStyle(color: Palette.textPrimary2)),
                      const Spacer(),
                      CouponStatusBadge((data['status'] ?? '').toString()),
                    ],
                  ),
                ),
                ContentLineInfo('Mã chiến dịch', data['code'] ?? ''),
                if ((data['note'] ?? '').toString().isNotEmpty)
                  ContentLineInfo('Ghi chú', data['note']),
                ContentLineInfo('Ngày tạo', date(data['createdAt'])),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'Mệnh giá & Phát hành',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ItemBaseContent(
                  items: [
                    ContentLineInfo(
                      'Mệnh giá',
                      _faceValue(data['faceValue']),
                    ),
                    ContentLineInfo(
                      'Hình thức phát hành',
                      _issueMode((data['issueMode'] ?? '').toString()),
                    ),
                    ContentLineInfo(
                      'Layout hiển thị',
                      _claimLayout((data['claimLayout'] ?? '').toString()),
                    ),
                    ContentLineInfo(
                      'Tổng số lượng',
                      '${data['totalQuantity'] ?? 0}',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _IssuedProgress(
                  issued: _int(data['issuedCount']),
                  total: _int(data['totalQuantity']),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'Hiệu lực',
            child: ItemBaseContent(
              items: [
                ContentLineInfo('Bắt đầu', date(data['validFrom'])),
                ContentLineInfo('Kết thúc', date(data['validTo'])),
                ContentLineInfo(
                  'Ngày trong tuần',
                  _daysOfWeek(data['usageDaysOfWeek']),
                ),
                if (data['usageDates'] is List && (data['usageDates'] as List).isNotEmpty)
                  ContentLineInfo(
                    'Ngày cụ thể',
                    (data['usageDates'] as List).join(', '),
                  ),
                if (data['usageWindows'] is List && (data['usageWindows'] as List).isNotEmpty)
                  ContentLineInfo(
                    'Khung giờ',
                    _windows(data['usageWindows']),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'Giới hạn nhận',
            child: ItemBaseContent(
              items: [
                ContentLineInfo(
                  'Tối đa / người dùng',
                  _limit(_int(data['maxPerUser'])),
                ),
                ContentLineInfo(
                  'Tối đa / số điện thoại',
                  _limit(_int(data['maxPerPhone'])),
                ),
                ContentLineInfo(
                  'Tối đa / thiết bị',
                  _limit(_int(data['maxPerDevice'])),
                ),
                ContentLineInfo(
                  'Nhận qua web',
                  _boolText(data['webClaimAllowed']),
                ),
                ContentLineInfo(
                  'Yêu cầu OTP',
                  _boolText(data['otpRequired']),
                ),
                ContentLineInfo(
                  'Thời gian giữ chỗ',
                  _reserveTtl(_int(data['reserveTtlSeconds'])),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static String _faceValue(dynamic v) {
    if (v == null) return '—';
    if (v is num) return '${v.toStringAsFixed(0)} ₫';
    return v.toString();
  }

  static String _issueMode(String code) {
    switch (code.toUpperCase()) {
      case 'CAMPAIGN':
        return 'Chiến dịch';
      case 'MANUAL':
        return 'Thủ công';
      default:
        return code.isEmpty ? '—' : code;
    }
  }

  static String _claimLayout(String code) {
    if (code.isEmpty) return '—';
    return 'Layout $code';
  }

  static String _daysOfWeek(dynamic v) {
    if (v is! List || v.isEmpty) return 'Mọi ngày';
    const labels = {1: 'T2', 2: 'T3', 3: 'T4', 4: 'T5', 5: 'T6', 6: 'T7', 7: 'CN'};
    return v.map((e) => labels[e is int ? e : int.tryParse('$e')] ?? '$e').join(', ');
  }

  static String _windows(dynamic v) {
    if (v is! List) return '—';
    return v.map((e) {
      if (e is Map) return '${e['from'] ?? ''} - ${e['to'] ?? ''}';
      return '$e';
    }).join(', ');
  }

  static String _limit(int n) => n <= 0 ? 'Không giới hạn' : '$n lượt';

  static String _boolText(dynamic v) => v == true ? 'Có' : 'Không';

  static String _reserveTtl(int seconds) {
    if (seconds <= 0) return 'Không giữ chỗ';
    if (seconds < 60) return '$seconds giây';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s == 0 ? '$m phút' : '$m phút $s giây';
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Palette.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _IssuedProgress extends StatelessWidget {
  const _IssuedProgress({required this.issued, required this.total});

  final int issued;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total > 0 ? (issued / total).clamp(0.0, 1.0) : 0.0;
    final percent = (ratio * 100).toStringAsFixed(0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Đã phát hành', style: TextStyle(color: Palette.textPrimary2)),
            const Spacer(),
            Text(
              total > 0 ? '$issued/$total ($percent%)' : '$issued',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Palette.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: Palette.bgColor,
            color: Palette.primary,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Tab 2 — Danh sách mã
// ============================================================

class _CodesTab extends StatelessWidget {
  const _CodesTab();

  @override
  Widget build(BuildContext context) {
    return SystemListView<MerchantCouponDetailCodesBloc, SystemListState<Map>, Map>(
      detailBuilder: (context, item, isSelected) => _CodeItem(item: item),
    );
  }
}

class _CodeItem extends StatelessWidget {
  const _CodeItem({required this.item});

  final Map item;

  @override
  Widget build(BuildContext context) {
    final code = (item['code'] ?? '').toString();
    final status = (item['status'] ?? '').toString();
    final claimedBy = item['claimedBy']?.toString();
    final expiresAt = item['expiresAt'];
    final qr = (item['qr'] ?? '').toString();
    final expired = _isExpired(expiresAt);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Palette.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        code,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Palette.textPrimary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    VoucherCodeStatusBadge(status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  claimedBy == null || claimedBy.isEmpty
                      ? 'Chưa có người nhận'
                      : 'Người nhận: $claimedBy',
                  style: TextStyle(
                    fontSize: 12,
                    color: claimedBy == null || claimedBy.isEmpty
                        ? Palette.textPrimary3
                        : Palette.textPrimary2,
                  ),
                ),
                if (expiresAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'HSD: ${date(expiresAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: expired ? Palette.redTxtColor : Palette.textPrimary3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (qr.isNotEmpty)
            IconButton(
              tooltip: 'Xem mã QR',
              icon: const Icon(Icons.qr_code_2, size: 28, color: Palette.primary),
              onPressed: () => _showQrDialog(context, code: code, qrUrl: qr),
            ),
        ],
      ),
    );
  }

  static bool _isExpired(dynamic v) {
    if (v == null) return false;
    final dt = v is DateTime ? v : DateTime.tryParse(v.toString());
    if (dt == null) return false;
    return dt.isBefore(DateTime.now());
  }
}

void _showQrDialog(BuildContext context, {required String code, required String qrUrl}) {
  showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              code,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: Palette.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                qrUrl,
                width: 240,
                height: 240,
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return const SizedBox(
                    width: 240,
                    height: 240,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (_, _, _) => const SizedBox(
                  width: 240,
                  height: 240,
                  child: Center(
                    child: Icon(Icons.broken_image_outlined, size: 48, color: Palette.textPrimary3),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng'),
          ),
        ],
      );
    },
  );
}
