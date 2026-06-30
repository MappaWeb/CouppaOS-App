import '../../../../import.dart';

class MerchantCouponDetailBloc extends SystemDetailBloc<SystemDetailState> {
  final String id;

  MerchantCouponDetailBloc(this.id)
    : super(dataSource: ApiService.coupon.apiPath(AppApi.voucher.campaignById(id)));
}

class MerchantCouponDetailCodesBloc extends SystemListBloc<SystemListState<Map>, Map> {
  final String id;

  MerchantCouponDetailCodesBloc(this.id)
    : super(dataSource: ApiService.coupon.apiPath(AppApi.voucher.campaignVouchers(id)));
}

// ── Generate vouchers ─────────────────────────────────────────────────────────

class MerchantCouponGenerateState {
  const MerchantCouponGenerateState({this.loading = false, this.error, this.success = false});

  final bool loading;
  final String? error;
  final bool success;
}

class MerchantCouponGenerateCubit extends Cubit<MerchantCouponGenerateState> {
  MerchantCouponGenerateCubit({
    required this._apiClient,
    required this._campaignId,
  }) : super(const MerchantCouponGenerateState());

  final ApiClient _apiClient;
  final String _campaignId;

  Future<void> generate(int quantity) async {
    emit(const MerchantCouponGenerateState(loading: true));
    try {
      await _apiClient.dio(ApiService.coupon).post(
        AppApi.voucher.campaignVouchers(_campaignId),
        data: {'quantity': quantity},
      );
      emit(const MerchantCouponGenerateState(success: true));
    } on DioException catch (e) {
      final msg = (e.response?.data is Map)
          ? (e.response!.data['message']?.toString() ?? 'Không thể sinh mã')
          : 'Không thể sinh mã';
      emit(MerchantCouponGenerateState(error: msg));
    }
  }
}
