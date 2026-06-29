import '../../../../import.dart';

class LinkItem extends StatelessWidget {
  const LinkItem(
    this.link, {
    super.key,
    required this.onAccept,
    required this.onReject,
    this.isBusy = false,
  });

  final Map link;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final bool isBusy;

  String get _name => (link['merchantName'] ?? '') as String;
  String get _status => (link['status'] ?? '') as String;
  String get _direction => (link['direction'] ?? '') as String;
  String? get _createdAt => link['createdAt'] as String?;

  bool get _isIncoming => _direction == 'incoming';
  bool get _isPending => _status == 'PENDING';
  bool get _canRespond => _isIncoming && _isPending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _DirectionIcon(isIncoming: _isIncoming),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name.isEmpty ? '—' : _name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitle(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Palette.textPrimary4,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: _status),
            ],
          ),
          if (_canRespond) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Palette.redTxtColor,
                      side: const BorderSide(color: Palette.redTxtColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isBusy ? null : onReject,
                    child: const Text('Từ chối'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Palette.primary,
                      disabledBackgroundColor: Palette.primary.withValues(
                        alpha: 0.4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isBusy ? null : onAccept,
                    child: const Text('Duyệt'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _subtitle() {
    final label = _isIncoming ? 'Yêu cầu đến' : 'Đã gửi';
    final rel = _relative(_createdAt);
    return rel == null ? label : '$label · $rel';
  }
}

class _DirectionIcon extends StatelessWidget {
  const _DirectionIcon({required this.isIncoming});

  final bool isIncoming;

  @override
  Widget build(BuildContext context) {
    final color = isIncoming ? Palette.blueTxtColor : Palette.textPrimary4;
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        isIncoming ? Icons.call_received : Icons.call_made,
        size: 18,
        color: color,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  ({Color bg, Color fg, String label}) _style() {
    switch (status) {
      case 'PENDING':
        return (
          bg: const Color(0xFFFFF7ED),
          fg: const Color(0xFFC2410C),
          label: 'Chờ',
        );
      case 'ACCEPTED':
        return (
          bg: Palette.successBgColor,
          fg: Palette.successTxtColor,
          label: 'Đã duyệt',
        );
      case 'REJECTED':
        return (
          bg: const Color(0xFFFEF2F2),
          fg: Palette.redTxtColor,
          label: 'Từ chối',
        );
      default:
        return (
          bg: Palette.bgColor,
          fg: Palette.textPrimary4,
          label: status.isEmpty ? '—' : status,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _style();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        s.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: s.fg,
        ),
      ),
    );
  }
}

String? _relative(String? iso) {
  if (iso == null || iso.isEmpty) return null;
  final dt = DateTime.tryParse(iso);
  if (dt == null) return null;
  final diff = DateTime.now().difference(dt.toLocal());
  if (diff.inSeconds < 60) return 'vừa xong';
  if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
  if (diff.inHours < 24) return '${diff.inHours} giờ trước';
  if (diff.inDays < 7) return '${diff.inDays} ngày trước';
  final local = dt.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year}';
}
