import 'package:core_charts/charts.dart';

import '../../../../import.dart';
import 'section_title.dart';

class ReportUsagePieChartSection extends StatelessWidget {
  const ReportUsagePieChartSection({
    super.key,
    required this.totalRedeemed,
    required this.totalClaimed,
  });

  final int totalRedeemed;
  final int totalClaimed;

  @override
  Widget build(BuildContext context) {
    final unusedCount = (totalClaimed - totalRedeemed).clamp(0, totalClaimed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ReportSectionTitle('Tỉ lệ sử dụng'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Palette.borderColor),
          ),
          padding: const EdgeInsets.all(16),
          child: PieChartType1(
            items: [
              {
                'title': 'Đã sử dụng',
                'value': totalRedeemed,
                'color': '#FF9800',
              },
              {
                'title': 'Chưa sử dụng',
                'value': unusedCount,
                'color': '#1976D2',
              },
            ],
          ),
        ),
      ],
    );
  }
}
