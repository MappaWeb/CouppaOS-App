// ignore_for_file: prefer_initializing_formals
import '../../../import.dart';
import '../../../data/merchant/campaign_stat.dart';

enum MerchantReportStatus { initial, loading, success, failure }

class MerchantReportState {
  const MerchantReportState({
    this.status = MerchantReportStatus.initial,
    this.campaigns = const [],
    this.error,
  });

  final MerchantReportStatus status;
  final List<CampaignStat> campaigns;
  final String? error;

  bool get isLoading => status == MerchantReportStatus.loading;

  int get totalCampaigns => campaigns.length;
  int get totalIssued => campaigns.fold(0, (s, e) => s + e.issuedCount);
  int get totalClaimed => campaigns.fold(0, (s, e) => s + e.claimedCount);
  int get totalRedeemed => campaigns.fold(0, (s, e) => s + e.redeemedCount);

  MerchantReportState copyWith({
    MerchantReportStatus? status,
    List<CampaignStat>? campaigns,
    String? error,
  }) =>
      MerchantReportState(
        status: status ?? this.status,
        campaigns: campaigns ?? this.campaigns,
        error: error,
      );
}

/// Cubit tải thống kê campaign — GET [AppApi.stats.campaigns].
class MerchantReportCubit extends Cubit<MerchantReportState> {
  MerchantReportCubit({required ApiClient apiClient})
      : _apiClient = apiClient,
       super(const MerchantReportState());

  final ApiClient _apiClient;

  Future<void> load() async {
    emit(state.copyWith(status: MerchantReportStatus.loading, error: null));
    try {
      final res = await _apiClient
          .dio(ApiService.merchant)
          .get<dynamic>(AppApi.stats.campaigns);
      final list = (res.data as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(CampaignStat.fromJson)
          .toList();
      emit(state.copyWith(
        status: MerchantReportStatus.success,
        campaigns: list,
      ));
    } on DioException catch (e) {
      final msg = (e.response?.data is Map)
          ? (e.response!.data['message']?.toString() ?? 'Không thể tải dữ liệu')
          : 'Không thể tải dữ liệu';
      emit(state.copyWith(status: MerchantReportStatus.failure, error: msg));
    } catch (_) {
      emit(state.copyWith(
        status: MerchantReportStatus.failure,
        error: 'Không thể tải dữ liệu',
      ));
    }
  }
}
