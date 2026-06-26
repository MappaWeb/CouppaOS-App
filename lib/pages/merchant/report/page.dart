import '../../../import.dart';
import 'bloc.dart';

class MerchantReportPage extends StatelessWidget {
  const MerchantReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MerchantReportCubit()..load(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Báo cáo & Thống kê'),
          automaticallyImplyLeading: false,
        ),
        body: BlocBuilder<MerchantReportCubit, MerchantReportState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _StatTile(
                  icon: Icons.attach_money,
                  label: 'Doanh thu',
                  value: formatCurrency(state.totalRevenue),
                ),
                const SizedBox(height: 12),
                _StatTile(
                  icon: Icons.local_offer,
                  label: 'Coupon đã phát hành',
                  value: state.totalIssued.toCustomFormat(),
                ),
                const SizedBox(height: 12),
                _StatTile(
                  icon: Icons.check_circle_outline,
                  label: 'Lượt dùng coupon',
                  value: state.totalRedeemed.toCustomFormat(),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: Palette.bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'TODO: biểu đồ thống kê (line / bar chart)',
                    style: TextStyle(color: Palette.textPrimary4),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

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
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Palette.bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Palette.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: Palette.textPrimary4)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
