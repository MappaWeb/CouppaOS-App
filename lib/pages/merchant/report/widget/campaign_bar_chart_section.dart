import 'package:core_charts/charts.dart';

import '../../../../data/merchant/campaign_stat.dart';
import '../../../../import.dart';
import 'section_title.dart';

class ReportCampaignBarChartSection extends StatelessWidget {
  const ReportCampaignBarChartSection({
    super.key,
    required this.campaigns,
  });

  final List<CampaignStat> campaigns;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ReportSectionTitle('Nhận & Sử dụng theo Campaign'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Palette.borderColor),
          ),
          padding: const EdgeInsets.all(16),
          child: MultiBarChartType1(
            height: 220,
            columnsSpace: 24,
            columnWidth: 14,
            barsSpace: 4,
            bottomReservedSize: 52,
            bottomAngle: -0.5,
            labelKey: 'name',
            columns: const [
              ChartColumnInfo(
                key: 'claimedCount',
                label: 'Đã nhận',
                color: Color(0xFF1976D2),
              ),
              ChartColumnInfo(
                key: 'redeemedCount',
                label: 'Đã dùng',
                color: Palette.primary,
              ),
            ],
            items: campaigns.map((e) => e.toJson()).toList(),
          ),
        ),
      ],
    );
  }
}
