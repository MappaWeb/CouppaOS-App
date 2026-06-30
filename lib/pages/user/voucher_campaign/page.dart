import '../../../import.dart';
import 'bloc.dart';

/// Màn claim voucher (layout B) — mở sau khi quét QR + `by-code` thành công.
/// Nhận dữ liệu campaign qua route arguments (`state.extra`).
class UserVoucherCampaignPage extends StatelessWidget {
  const UserVoucherCampaignPage(this.args, {super.key});

  final Map? args;

  @override
  Widget build(BuildContext context) {
    final campaign = args ?? const {};
    return BlocProvider(
      create: (ctx) => VoucherCampaignCubit(
        apiClient: ctx.read<ApiClient>(),
        campaign: campaign,
      ),
      child: const _VoucherCampaignView(),
    );
  }
}

class _VoucherCampaignView extends StatelessWidget {
  const _VoucherCampaignView();

  Future<void> _onClaimed(BuildContext context) async {
    await AppDialogs.showConfirmDialog(
      context: context,
      title: 'Nhận quà thành công',
      message: 'Voucher đã được thêm vào ví. Mở “Coupon của tôi” để xem ngay.',
      showCloseButton: false,
      barrierDismissible: false,
      textConfirm: 'Đóng',
      onConfirm: () {
        appNavigator.pop(); // đóng dialog
        appNavigator.pop(); // về màn quét
      },
      actions: [
        BaseButton(
          onPressed: () {
            appNavigator.pop();
            appNavigator.go(RouterConstants.userCoupon);
          },
          child: const Text('Xem ví voucher'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: BaseAppBar(context: context, title: const Text('Nhận voucher')),
      body: BlocConsumer<VoucherCampaignCubit, VoucherCampaignState>(
        listenWhen: (p, c) =>
            (!p.claimed && c.claimed) ||
            (p.error != c.error && c.error != null),
        listener: (context, state) {
          if (state.claimed) {
            _onClaimed(context);
          } else if (state.error != null) {
            showMessage(state.error!, type: 'error');
            appNavigator.pop(); // back về màn quét sau khi báo lỗi
          }
        },
        builder: (context, state) {
          final c = state.campaign;
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Hero(campaign: c),
                      const SizedBox(height: 12),
                      _StatsCard(campaign: c),
                      const SizedBox(height: 12),
                      _UsageCard(campaign: c),
                      _AcceptancesCard(campaign: c),
                      _LocationsCard(campaign: c),
                      _NoteCard(campaign: c),
                    ],
                  ),
                ),
              ),
              _ClaimBar(state: state),
            ],
          );
        },
      ),
    );
  }
}

// ── Hero (cover + face value + merchant + tên campaign) ──────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.campaign});

  final Map campaign;

  @override
  Widget build(BuildContext context) {
    final cover = (campaign['coverImage'] ?? '').toString();
    final name = (campaign['name'] ?? '').toString();
    final merchant = (campaign['merchantName'] ?? '').toString();
    final address = (campaign['merchantAddress'] ?? '').toString();
    final face = _money(campaign['faceValue']);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (cover.isNotEmpty)
            Stack(
              children: [
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: ImageViewer(cover, fit: BoxFit.cover),
                ),
                if (face != null)
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Palette.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        face,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.card_giftcard, size: 16, color: Palette.primary),
                    const SizedBox(width: 6),
                    Text(
                      'QUÀ TẶNG DÀNH CHO BẠN',
                      style: TextStyle(
                        color: Palette.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  name.isEmpty ? 'Voucher' : name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Palette.textPrimary,
                  ),
                ),
                if (cover.isEmpty && face != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    face,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Palette.primary,
                    ),
                  ),
                ],
                if (merchant.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _IconLine(
                    icon: Icons.storefront_outlined,
                    text: address.isEmpty ? merchant : '$merchant • $address',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Thống kê số lượng + hạn dùng ─────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.campaign});

  final Map campaign;

  @override
  Widget build(BuildContext context) {
    final remaining = _remaining(campaign);
    final claimed = _asInt(campaign['claimedCount'] ?? campaign['claimed']);
    final total = _asInt(campaign['totalQuantity'] ?? campaign['total']);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _Stat(
                  value: '$remaining',
                  label: 'còn lại',
                  valueColor: const Color(0xFF16A34A),
                ),
              ),
              _vDivider(),
              Expanded(child: _Stat(value: '$claimed', label: 'đã nhận')),
              _vDivider(),
              Expanded(child: _Stat(value: '$total', label: 'tổng')),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 16),
          _IconLine(
            icon: Icons.access_time,
            text:
                'Hạn dùng: '
                '${_dateRange(campaign['validFrom'], campaign['validTo'])}',
          ),
        ],
      ),
    );
  }

  Widget _vDivider() =>
      Container(width: 1, height: 40, color: const Color(0xFFE5E7EB));
}

// ── Điều kiện sử dụng (ngày trong tuần / khung giờ / OTP) ─────────────────────

class _UsageCard extends StatelessWidget {
  const _UsageCard({required this.campaign});

  final Map campaign;

  @override
  Widget build(BuildContext context) {
    final days = _days(campaign['usageDaysOfWeek']);
    final windows = _windows(campaign['usageWindows']);
    final dates = _stringList(campaign['usageDates']);
    final otpRequired = campaign['otpRequired'] == true;

    final rows = <Widget>[];
    if (days.isNotEmpty) {
      rows.add(
        _IconLine(
          icon: Icons.event_outlined,
          text: 'Áp dụng: ${days.join(', ')}',
        ),
      );
    }
    if (dates.isNotEmpty) {
      rows.add(
        _IconLine(
          icon: Icons.calendar_today_outlined,
          text: 'Ngày: ${dates.join(', ')}',
        ),
      );
    }
    if (windows.isNotEmpty) {
      rows.add(
        _IconLine(
          icon: Icons.schedule_outlined,
          text: 'Khung giờ: ${windows.join(', ')}',
        ),
      );
    }
    if (otpRequired) {
      rows.add(
        _IconLine(
          icon: Icons.lock_outline,
          text: 'Cần OTP khi sử dụng tại cửa hàng',
        ),
      );
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return _SectionCard(
      title: 'Điều kiện sử dụng',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _withGaps(rows, 10),
      ),
    );
  }
}

// ── Thương hiệu chấp nhận voucher ────────────────────────────────────────────

class _AcceptancesCard extends StatelessWidget {
  const _AcceptancesCard({required this.campaign});

  final Map campaign;

  @override
  Widget build(BuildContext context) {
    final items = _mapList(campaign['acceptances']);
    if (items.isEmpty) return const SizedBox.shrink();

    return _SectionCard(
      title: 'Thương hiệu chấp nhận',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((m) {
          final name = (m['merchantName'] ?? '').toString();
          if (name.isEmpty) return const SizedBox.shrink();
          final isOwner = m['isOwner'] == true;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isOwner ? Icons.verified : Icons.storefront_outlined,
                  size: 15,
                  color: isOwner ? Palette.primary : Palette.textPrimary4,
                ),
                const SizedBox(width: 6),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Palette.textPrimary2,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Danh sách địa điểm sử dụng (liệt kê tất cả) ──────────────────────────────

class _LocationsCard extends StatelessWidget {
  const _LocationsCard({required this.campaign});

  final Map campaign;

  @override
  Widget build(BuildContext context) {
    final items = _mapList(campaign['locations']);
    if (items.isEmpty) return const SizedBox.shrink();

    final tiles = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      tiles.add(_LocationTile(data: items[i]));
      if (i != items.length - 1) {
        tiles.add(const Divider(height: 20, color: Color(0xFFE5E7EB)));
      }
    }

    return _SectionCard(
      title: 'Địa điểm sử dụng (${items.length})',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tiles,
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({required this.data});

  final Map data;

  @override
  Widget build(BuildContext context) {
    final storeName = (data['storeName'] ?? data['merchantName'] ?? '')
        .toString();
    final merchant = (data['merchantName'] ?? '').toString();
    final address = (data['address'] ?? '').toString();
    final isOwner = data['isOwner'] == true;
    final lat = _toDouble(data['lat'] ?? data['latitude']);
    final lng = _toDouble(data['lng'] ?? data['longitude']);
    final hasCoords = lat != null && lng != null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 18,
          color: isOwner ? Palette.primary : Palette.textPrimary4,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      storeName.isEmpty ? merchant : storeName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Palette.textPrimary,
                      ),
                    ),
                  ),
                  if (merchant.isNotEmpty && merchant != storeName) ...[
                    const SizedBox(width: 6),
                    Text(
                      '· $merchant',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Palette.textPrimary3,
                      ),
                    ),
                  ],
                ],
              ),
              if (address.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Palette.textPrimary2,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (hasCoords || address.isNotEmpty)
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => ActionUtils.openMap(
              latitude: lat,
              longitude: lng,
              query: address.isNotEmpty ? address : storeName,
            ),
            child: Text(
              'Bản đồ',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Palette.primary,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Ghi chú ──────────────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.campaign});

  final Map campaign;

  @override
  Widget build(BuildContext context) {
    final note = (campaign['note'] ?? '').toString().trim();
    if (note.isEmpty) return const SizedBox.shrink();
    return _SectionCard(
      title: 'Ghi chú',
      child: Text(
        note,
        style: const TextStyle(fontSize: 14, color: Palette.textPrimary2),
      ),
    );
  }
}

// ── Thanh nhận quà (sticky bottom) ───────────────────────────────────────────

class _ClaimBar extends StatelessWidget {
  const _ClaimBar({required this.state});

  final VoucherCampaignState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, -4)),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: Palette.primary,
            disabledBackgroundColor: Palette.primary.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: state.isClaiming || state.claimed
              ? null
              : () => context.read<VoucherCampaignCubit>().claim(),
          icon: state.isClaiming
              ? const SizedBox.shrink()
              : const Icon(Icons.card_giftcard, color: Colors.white),
          label: state.isClaiming
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  state.claimed ? 'Đã nhận' : 'Nhận quà ngay',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Widget dùng chung ────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Palette.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.valueColor});

  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: valueColor ?? Palette.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Palette.textPrimary3),
        ),
      ],
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Palette.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Palette.textPrimary2),
          ),
        ),
      ],
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

List<Widget> _withGaps(List<Widget> children, double gap) {
  final out = <Widget>[];
  for (var i = 0; i < children.length; i++) {
    out.add(children[i]);
    if (i != children.length - 1) out.add(SizedBox(height: gap));
  }
  return out;
}

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

double? _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

int _remaining(Map c) {
  final direct = c['slotsRemaining'] ?? c['remaining'] ?? c['remainingCount'];
  if (direct != null) return _asInt(direct);
  final total = _asInt(c['totalQuantity'] ?? c['total']);
  final claimed = _asInt(c['claimedCount'] ?? c['claimed']);
  final r = total - claimed;
  return r < 0 ? 0 : r;
}

String? _money(dynamic v) {
  final n = _toDouble(v);
  if (n == null) return null;
  return formatCurrency(n);
}

String _dateRange(dynamic from, dynamic to) {
  final f = from == null ? '' : date(from);
  final t = to == null ? '' : date(to);
  if (f.isEmpty && t.isEmpty) return '—';
  if (f.isEmpty) return t;
  if (t.isEmpty) return f;
  return '$f – $t';
}

List<Map> _mapList(dynamic v) {
  if (v is! List) return const [];
  return v.whereType<Map>().toList();
}

List<String> _stringList(dynamic v) {
  if (v is! List) return const [];
  return v
      .map((e) => e?.toString() ?? '')
      .where((e) => e.isNotEmpty)
      .toList();
}

// usageDaysOfWeek dùng quy ước 0=Chủ nhật … 6=Thứ 7 (giống Date.getDay()).
const _weekdayLabels = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

List<String> _days(dynamic v) {
  if (v is! List) return const [];
  final out = <String>[];
  for (final e in v) {
    final i = _asInt(e);
    if (i >= 0 && i < _weekdayLabels.length) out.add(_weekdayLabels[i]);
  }
  return out;
}

List<String> _windows(dynamic v) {
  if (v is! List) return const [];
  final out = <String>[];
  for (final w in v) {
    if (w is! Map) continue;
    final start = (w['start'] ?? '').toString();
    final end = (w['end'] ?? '').toString();
    if (start.isEmpty && end.isEmpty) continue;
    out.add(end.isEmpty ? start : '$start – $end');
  }
  return out;
}
