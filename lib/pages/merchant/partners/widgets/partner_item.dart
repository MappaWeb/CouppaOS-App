import '../../../../import.dart';

class PartnerItem extends StatelessWidget {
  const PartnerItem(this.partner, {super.key});

  final Map partner;

  String get _name => (partner['name'] ?? '') as String;

  int get _storeCount {
    final stores = partner['stores'];
    return stores is List ? stores.length : 0;
  }

  String get _initials {
    final words = _name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return '?';
    if (words.length == 1) return words.first.characters.take(1).toString().toUpperCase();
    return (words.first.characters.take(1).toString() +
            words.last.characters.take(1).toString())
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Palette.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _initials,
              style: const TextStyle(
                color: Palette.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
                  '$_storeCount cơ sở',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Palette.textPrimary4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
