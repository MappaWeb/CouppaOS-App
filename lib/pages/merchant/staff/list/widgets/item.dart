import '../../../../../import.dart';

class StaffItem extends StatelessWidget {
  const StaffItem(
    this.staff, {
    super.key,
    required this.onEdit,
    required this.onRevoke,
  });

  final Map staff;
  final VoidCallback onEdit;
  final VoidCallback onRevoke;

  String get _phone => (staff['phone'] ?? '') as String;
  String get _role => (staff['role'] ?? '') as String;
  String get _status => (staff['status'] ?? '') as String;

  String get _roleLabel {
    switch (_role) {
      case 'merchant_admin':
        return 'Quản trị viên';
      case 'super_staff':
        return 'Trưởng nhóm';
      case 'accounting':
        return 'Kế toán';
      case 'staff':
        return 'Nhân viên';
      default:
        return _role.isEmpty ? '—' : _role;
    }
  }

  bool get _isRevoked => _status == 'REVOKED';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Palette.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.borderColor),
      ),
      child: Row(
        children: [
          _Avatar(phone: _phone),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _phone.isEmpty ? '—' : _phone,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _roleLabel,
                  style: const TextStyle(fontSize: 13, color: Palette.textPrimary4),
                ),
              ],
            ),
          ),
          _StatusBadge(status: _status),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Palette.textPrimary3, size: 20),
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'revoke') onRevoke();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Sửa'),
              ),
              if (!_isRevoked)
                PopupMenuItem(
                  value: 'revoke',
                  child: Text(
                    'Thu hồi',
                    style: TextStyle(color: Palette.redTxtColor),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Palette.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(21),
      ),
      child: const Icon(Icons.person_outline_rounded, size: 22, color: Palette.primary),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  ({Color bg, Color fg, String label}) _style() {
    switch (status) {
      case 'ACTIVE':
        return (
          bg: Palette.successBgColor,
          fg: Palette.successTxtColor,
          label: 'Hoạt động',
        );
      case 'INVITED':
        return (
          bg: const Color(0xFFFFF7ED),
          fg: const Color(0xFFC2410C),
          label: 'Chờ xác nhận',
        );
      case 'REVOKED':
        return (
          bg: const Color(0xFFF3F4F6),
          fg: Palette.textPrimary3,
          label: 'Đã thu hồi',
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
