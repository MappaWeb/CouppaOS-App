import '../../../../../import.dart';

class StaffItem extends StatelessWidget {
  const StaffItem(this.staff, {super.key, required this.onEdit, required this.onRevoke});

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
    return ItemBase(
      onPressed: onEdit,
      showMultiActions: true,
      actions: !_isRevoked
          ? [
              ItemMenuAction(key: 'edit', label: 'Sửa', iconData: Icons.edit_outlined),
              ItemMenuAction(
                key: 'revoke',
                label: 'Thu hồi',
                iconData: Icons.block_outlined,
                foregroundColor: Palette.redTxtColor,
              ),
            ]
          : [],
      onAction: (ctx, key) {
        if (key == 'edit') onEdit();
        if (key == 'revoke') onRevoke();
      },
      backgroundColor: Palette.cardColor,
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Palette.borderColor),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      leading: const _Avatar(),
      title: Text(
        _phone.isEmpty ? '—' : _phone,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Palette.textPrimary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      content: Column(
        crossAxisAlignment: .start,
        children: [
          SizedBox(height: 4,),
          _StatusBadge(status: _status),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _roleLabel,
              style: const TextStyle(fontSize: 13, color: Palette.textPrimary4),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

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
        return (bg: Palette.successBgColor, fg: Palette.successTxtColor, label: 'Hoạt động');
      case 'INVITED':
        return (bg: const Color(0xFFFFF7ED), fg: const Color(0xFFC2410C), label: 'Chờ xác nhận');
      case 'REVOKED':
        return (bg: const Color(0xFFF3F4F6), fg: Palette.textPrimary3, label: 'Đã thu hồi');
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
      decoration: BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        s.label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: s.fg),
      ),
    );
  }
}
