import '../../../../../import.dart';

/// 7 FilterChip T2..CN (0=T2 … 6=CN). Value: `List<int>` sorted.
class DaysOfWeekPicker extends StatelessWidget {
  const DaysOfWeekPicker({
    super.key,
    this.value,
    this.errorText,
    required this.onChanged,
  });

  static const _labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  final List<int>? value;
  final String? errorText;
  final ValueChanged<List<int>?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value ?? const <int>[];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Text(
              'Ngày trong tuần',
              style: TextStyle(fontSize: 13, color: Palette.textPrimary4),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_labels.length, (i) {
              final on = selected.contains(i);
              return FilterChip(
                label: Text(_labels[i]),
                selected: on,
                onSelected: (s) {
                  final next = [...selected];
                  if (s) {
                    next.add(i);
                  } else {
                    next.remove(i);
                  }
                  next.sort();
                  onChanged(next.isEmpty ? null : next);
                },
              );
            }),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                errorText!,
                style: const TextStyle(color: Palette.redTxtColor, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
