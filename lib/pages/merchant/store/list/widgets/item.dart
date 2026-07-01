import '../../../../../import.dart';

class StoreItem extends StatelessWidget {
  const StoreItem(
    this.store, {
    super.key,
    required this.onTap,
    required this.onDelete,
  });

  final Map store;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  String get _name => (store['name'] ?? '').toString();
  String get _address => (store['address'] ?? '').toString();
  String get _phone => (store['phone'] ?? '').toString();
  bool get _isPrimary => store['isPrimary'] == true;

  String? get _thumbnail {
    final images = store['images'];
    if (images is List && images.isNotEmpty) {
      final first = images.first;
      if (first is Map) {
        final url = first['url']?.toString();
        if (url != null && url.isNotEmpty) return url;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ItemBase(
      onPressed: onTap,
      showMultiActions: true,
      actions: [
        ItemMenuAction(
          key: 'edit',
          label: 'Sửa',
          iconData: Icons.edit_outlined,
        ),
        if (!_isPrimary)
          ItemMenuAction(
            key: 'delete',
            label: 'Xoá',
            iconData: Icons.delete_outline,
            foregroundColor: Palette.redTxtColor,
          ),
      ],
      onAction: (ctx, key) {
        if (key == 'edit') onTap();
        if (key == 'delete') onDelete();
      },
      backgroundColor: Palette.cardColor,
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Palette.borderColor),
      padding: const EdgeInsets.all(16),
      leading: _Thumbnail(url: _thumbnail),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              _name.isEmpty ? '—' : _name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Palette.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_isPrimary) ...[
            const SizedBox(width: 8),
            _PrimaryBadge(),
          ],
        ],
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            _address.isEmpty ? '—' : _address,
            style: const TextStyle(
              fontSize: 13,
              color: Palette.textPrimary4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (_phone.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  size: 14,
                  color: Palette.textPrimary3,
                ),
                const SizedBox(width: 4),
                Text(
                  _phone,
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
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 48,
        height: 48,
        color: Palette.primary.withValues(alpha: 0.08),
        child: url != null
            ? Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.storefront_outlined,
                  color: Palette.primary,
                  size: 22,
                ),
              )
            : const Icon(
                Icons.storefront_outlined,
                color: Palette.primary,
                size: 22,
              ),
      ),
    );
  }
}

class _PrimaryBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Palette.successBgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            size: 14,
            color: Palette.successTxtColor,
          ),
          const SizedBox(width: 4),
          const Text(
            'Cơ sở chính',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Palette.successTxtColor,
            ),
          ),
        ],
      ),
    );
  }
}
