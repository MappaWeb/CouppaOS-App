import '../../../import.dart';

/// State cho màn claim voucher (dạng 1 — sau khi quét QR + by-code thành công).
///
/// `campaign` là Map dữ liệu campaign lấy từ `GET /campaigns/by-code/{code}`,
/// được truyền sang qua route arguments (`state.extra`).
class VoucherCampaignState {
  const VoucherCampaignState({
    required this.campaign,
    this.isClaiming = false,
    this.claimed = false,
    this.error,
  });

  final Map campaign;
  final bool isClaiming;
  final bool claimed;
  final String? error;

  VoucherCampaignState copyWith({
    Map? campaign,
    bool? isClaiming,
    bool? claimed,
    String? error,
    bool clearError = false,
  }) {
    return VoucherCampaignState(
      campaign: campaign ?? this.campaign,
      isClaiming: isClaiming ?? this.isClaiming,
      claimed: claimed ?? this.claimed,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Cubit cho màn claim voucher theo campaign.
///
/// Theo convention dự án (xem `AccountProfileBloc` / `VoucherClaimCubit`): gọi
/// API trực tiếp qua `ApiClient.dio(ApiService.X)`, bắt `DioException` tại chỗ.
class VoucherCampaignCubit extends Cubit<VoucherCampaignState> {
  VoucherCampaignCubit({required ApiClient apiClient, required Map campaign})
    : _apiClient = apiClient,
      super(VoucherCampaignState(campaign: campaign));

  final ApiClient _apiClient;

  String get _campaignId => (state.campaign['id'] ?? '').toString();

  /// POST `/vouchers/claims` với `{"campaignId": ...}` để nhận voucher.
  Future<void> claim() async {
    if (state.isClaiming || state.claimed) return;
    final id = _campaignId;
    if (id.isEmpty) {
      emit(state.copyWith(error: 'Thiếu mã chiến dịch'));
      return;
    }

    emit(state.copyWith(isClaiming: true, clearError: true));
    try {
      final res = await _apiClient
          .dio(ApiService.coupon)
          .post(AppApi.voucher.voucherClaims, data: {'campaignId': id});
      final ok = (res.statusCode ?? 0) >= 200 && (res.statusCode ?? 0) < 300;
      if (ok) {
        markVoucherWalletDirty();
        emit(state.copyWith(isClaiming: false, claimed: true));
      } else {
        emit(state.copyWith(isClaiming: false, error: 'Nhận voucher thất bại'));
      }
    } on DioException catch (e) {
      emit(state.copyWith(isClaiming: false, error: _mapError(e)));
    } catch (_) {
      emit(state.copyWith(isClaiming: false, error: 'Có lỗi xảy ra'));
    }
  }

  /// Map code lỗi backend → thông báo tiếng Việt.
  static const _codeMessages = <String, String>{
    'CAMPAIGN_NOT_ACTIVE': 'Chiến dịch chưa được kích hoạt',
    'CAMPAIGN_NOT_FOUND': 'Không tìm thấy chiến dịch',
    'CAMPAIGN_EXPIRED': 'Chiến dịch đã hết hạn',
    'CAMPAIGN_OUT_OF_SLOTS': 'Chiến dịch đã hết lượt nhận',
    'ALREADY_CLAIMED': 'Bạn đã nhận voucher này rồi',
  };

  static String _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      // Lỗi lồng: {"error": {"code": ..., "message": ...}}
      final err = data['error'];
      if (err is Map) {
        final code = err['code'];
        if (code is String) {
          final mapped = _codeMessages[code];
          if (mapped != null) return mapped;
        }
        final msg = err['message'];
        if (msg is String && msg.isNotEmpty) return msg;
      }
      // Lỗi phẳng: {"message"/"error"/"detail": "..."}
      final msg = data['message'] ?? data['error'] ?? data['detail'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    return 'Có lỗi xảy ra, vui lòng thử lại';
  }
}
