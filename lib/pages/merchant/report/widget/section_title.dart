import '../../../../import.dart';

class ReportSectionTitle extends StatelessWidget {
  const ReportSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Palette.textPrimary,
      ),
    );
  }
}
