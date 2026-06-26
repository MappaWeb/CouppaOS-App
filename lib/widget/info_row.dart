import '../import.dart';

class InfoRow extends StatelessWidget {
  final String icon;
  final String? value;
  final String? title;

  const InfoRow({
    super.key,
    required this.icon,
    this.value,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: .start,
      children: [
        SvgViewer(
          icon,
          color: const Color(0xff4A5565),
          height: 16,
          width: 16,
        ).paddingOnly(top: 2),
        w8,
        if (!empty(title)) ...[
          Text(title ?? '', style: const TextStyle(color: Color(0xff4A5565))),
          w4,
        ],
        Expanded(
          child: Text(value ?? '', style: TextStyle(color: AppColors.gray900)),
        ),
      ],
    );
  }
}
