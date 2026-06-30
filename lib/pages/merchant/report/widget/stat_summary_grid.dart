import '../../../../import.dart';
import 'stat_card.dart';

class ReportStatSummaryGrid extends StatelessWidget {
  const ReportStatSummaryGrid({
    super.key,
    required this.totalCampaigns,
    required this.totalIssued,
    required this.totalClaimed,
    required this.totalRedeemed,
  });

  final int totalCampaigns;
  final int totalIssued;
  final int totalClaimed;
  final int totalRedeemed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ReportStatCard(
                icon: Icons.campaign_outlined,
                label: 'Tổng campaign',
                value: '$totalCampaigns',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReportStatCard(
                icon: Icons.local_offer_outlined,
                label: 'Đã phát hành',
                value: '$totalIssued',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ReportStatCard(
                icon: Icons.download_done_outlined,
                label: 'Đã nhận',
                value: '$totalClaimed',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReportStatCard(
                icon: Icons.check_circle_outline,
                label: 'Đã sử dụng',
                value: '$totalRedeemed',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
