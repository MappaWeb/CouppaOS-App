import '../import.dart';

class CommonNote extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? label;

  const CommonNote({super.key, required this.icon, required this.text, this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .all(16),
      decoration: const BoxDecoration(
        color: Color(0xffEFF6FF),
        border: Border(left: BorderSide(color: Color(0xff51A2FF), width: 3)),
        borderRadius: .only(bottomRight: .circular(14), topRight: .circular(14)),
      ),
      child: Row(
        crossAxisAlignment: .start,
        spacing: 12,
        children: [
          Icon(icon, color: const Color(0xff155DFC)),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              spacing: 4,
              children: [
                if (!empty(label))
                  Text(
                    label ?? '',
                    style: const TextStyle(color: Color(0xff1C398E), fontSize: 16, fontWeight: .w600),
                  ),
                Text(text, style: const TextStyle(color: Color(0xff1C398E))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
