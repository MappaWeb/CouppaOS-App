import '../../../../import.dart';

class MerchantRedeemConfirmState {
  const MerchantRedeemConfirmState({
    this.isSubmitting = false,
    this.verifyData = const {},
    this.success = false,
    this.error,
  });

  final bool isSubmitting;
  final Map<String, dynamic> verifyData;
  final bool success;
  final String? error;

  /// Mã thuộc cửa hàng của merchant hiện tại.
  bool get belongsToMerchant => verifyData['belongsToMerchant'] == true;

  /// Server cho phép đổi mã (còn hạn, đúng ngày áp dụng, chưa dùng...).
  bool get redeemable => verifyData['redeemable'] == true;

  /// Voucher đã gắn khách nhận chưa (ảnh hưởng tới việc đổi mã).
  bool get hasCustomer => verifyData['hasCustomer'] == true;

  /// Chỉ được đổi khi vừa thuộc cửa hàng vừa redeemable.
  bool get canRedeem => belongsToMerchant && redeemable;

  String get _status => verifyData['status']?.toString() ?? '';
  bool get _expired => verifyData['expired'] == true;

  /// Tiêu đề banner — nêu rõ vì sao không đổi được (đã dùng / hết hạn / ...).
  String get invalidTitle {
    if (canRedeem) return 'Mã hợp lệ';
    if (_status == 'REDEEMED') return 'Mã đã được sử dụng';
    if (_expired || _status == 'EXPIRED') return 'Mã đã hết hạn';
    if (!belongsToMerchant) return 'Mã không thuộc cửa hàng';
    return 'Mã không hợp lệ';
  }

  /// Mô tả phụ — ưu tiên `reason` của API, fallback theo từng case.
  String? get invalidReason {
    if (canRedeem) return null;
    final reason = verifyData['reason']?.toString();
    if (reason != null && reason.isNotEmpty) return reason;
    if (_status == 'REDEEMED') return 'Mã này đã được đổi trước đó';
    if (_expired || _status == 'EXPIRED') return 'Mã đã quá hạn sử dụng';
    if (!belongsToMerchant) return 'Mã thuộc cửa hàng khác';
    return 'Mã chưa thể đổi';
  }

  MerchantRedeemConfirmState copyWith({
    bool? isSubmitting,
    Map<String, dynamic>? verifyData,
    bool? success,
    String? error,
    bool clearError = false,
  }) {
    return MerchantRedeemConfirmState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      verifyData: verifyData ?? this.verifyData,
      success: success ?? this.success,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Cubit xác nhận đổi mã — nhận verifyData đã fetch sẵn từ scanner bloc.
///
/// Không gọi verify lần 2 (scanner đã verify trước khi navigate).
/// `confirm()` gọi `POST /vouchers/redeem {"token": code}` để đổi mã thật.
class MerchantRedeemConfirmCubit extends Cubit<MerchantRedeemConfirmState> {
  MerchantRedeemConfirmCubit({
    required ApiClient apiClient,
    required Map<String, dynamic> initialData,
  })  : _apiClient = apiClient, // ignore: prefer_initializing_formals
        super(MerchantRedeemConfirmState(verifyData: initialData));

  final ApiClient _apiClient;

  Future<void> confirm(String code) async {
    if (state.isSubmitting || !state.canRedeem) return;
    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      await _apiClient
          .dio(ApiService.coupon)
          .post(AppApi.voucher.voucherRedeem, data: {'token': code});
      emit(state.copyWith(isSubmitting: false, success: true));
    } on DioException catch (e) {
      emit(state.copyWith(isSubmitting: false, error: _mapError(e)));
    }
  }

  static String _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      // API trả lỗi dạng `{ "error": { "code": "...", "message": "..." } }`.
      final error = data['error'];
      if (error is Map && error['message'] is String) {
        return error['message'] as String;
      }
      final msg = data['reason'] ?? data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    return e.message ?? 'Đổi mã thất bại. Vui lòng thử lại.';
  }
}
