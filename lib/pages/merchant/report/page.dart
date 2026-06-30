import '../../../import.dart';
import 'bloc.dart';
import 'widget/widgets.dart';

class MerchantReportPage extends StatelessWidget {
  const MerchantReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MerchantReportCubit(
        apiClient: context.read<ApiClient>(),
      )..load(),
      child: const _MerchantReportView(),
    );
  }
}

class _MerchantReportView extends StatelessWidget {
  const _MerchantReportView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.bgColor,
      appBar: BaseAppBar(
        context: context,
        title: const Text('Báo cáo & Thống kê'),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<MerchantReportCubit, MerchantReportState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == MerchantReportStatus.failure) {
            return ReportErrorView(
              message: state.error ?? 'Không thể tải dữ liệu',
              onRetry: () => context.read<MerchantReportCubit>().load(),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<MerchantReportCubit>().load(),
            child: _DashboardContent(state: state),
          );
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.state});

  final MerchantReportState state;

  @override
  Widget build(BuildContext context) {
    final totalRedeemed = state.totalRedeemed;
    final totalClaimed = state.totalClaimed;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ReportStatSummaryGrid(
          totalCampaigns: state.totalCampaigns,
          totalIssued: state.totalIssued,
          totalClaimed: totalClaimed,
          totalRedeemed: totalRedeemed,
        ),
        const SizedBox(height: 24),
        if (state.campaigns.isNotEmpty) ...[
          ReportCampaignBarChartSection(campaigns: state.campaigns),
          const SizedBox(height: 24),
        ],
        if (totalClaimed > 0)
          ReportUsagePieChartSection(
            totalRedeemed: totalRedeemed,
            totalClaimed: totalClaimed,
          ),
        SizedBox(height: MediaQuery.paddingOf(context).bottom + 16),
      ],
    );
  }
}
