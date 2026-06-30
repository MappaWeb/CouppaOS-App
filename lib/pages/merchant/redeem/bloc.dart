import '../../../import.dart';

enum MerchantScanStatus { idle, checking }

class MerchantRedeemState {
  const MerchantRedeemState({
    this.scanStatus = MerchantScanStatus.idle,
    this.checkedCode,
    this.verifyData,
    this.error,
  });

  final MerchantScanStatus scanStatus;

  /// Mã đang được kiểm tra (hiển thị overlay).
  final String? checkedCode;

  /// Non-null sau khi verify thành công → listener navigate sang confirm.
  final Map<String, dynamic>? verifyData;

  /// Non-null khi verify thất bại → listener hiển thị snackbar.
  final String? error;

  bool get isChecking => scanStatus == MerchantScanStatus.checking;

  /// Truyền vào QrScannerView.isProcessing — dừng quét khi đang check hoặc
  /// đã có kết quả chờ navigate.
  bool get isProcessing => isChecking || verifyData != null;

  MerchantRedeemState copyWith({
    MerchantScanStatus? scanStatus,
    String? checkedCode,
    Map<String, dynamic>? verifyData,
    bool clearVerifyData = false,
    String? error,
    bool clearError = false,
  }) {
    return MerchantRedeemState(
      scanStatus: scanStatus ?? this.scanStatus,
      checkedCode: checkedCode ?? this.checkedCode,
      verifyData: clearVerifyData ? null : (verifyData ?? this.verifyData),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Cubit scanner — gọi POST /vouchers/verify ngay khi quét/nhập mã.
///
/// Pattern: inject ApiClient, gọi API trực tiếp, bắt DioException.
/// Nếu verify thành công → emit verifyData (page navigate đến confirm).
/// Nếu thất bại → emit error (page hiện snackbar, scanner tự resume).
class MerchantRedeemCubit extends Cubit<MerchantRedeemState> {
  MerchantRedeemCubit({required this._apiClient})
      : super(const MerchantRedeemState());

  final ApiClient _apiClient;
  String? _lastCode;

  Future<void> onScanned(String code) async {
    if (state.isChecking) return;
    if (code == _lastCode) return;
    _lastCode = code;

    emit(state.copyWith(
      scanStatus: MerchantScanStatus.checking,
      checkedCode: code,
      clearVerifyData: true,
      clearError: true,
    ));

    try {
      final res = await _apiClient
          .dio(ApiService.coupon)
          .post(AppApi.voucher.voucherVerify, data: {'token': code});

      final data = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : <String, dynamic>{};

      // Luôn điều hướng sang trang xác nhận: trang đó hiển thị đầy đủ thông tin
      // verify + badge hợp lệ/không hợp lệ và chỉ bật nút đổi khi
      // `redeemable && belongsToMerchant`.
      emit(state.copyWith(
        scanStatus: MerchantScanStatus.idle,
        verifyData: {'token': code, ...data},
        clearError: true,
      ));
    } on DioException catch (e) {
      _lastCode = null;
      emit(state.copyWith(
        scanStatus: MerchantScanStatus.idle,
        error: _mapError(e),
        clearVerifyData: true,
      ));
    }
  }

  /// Gọi sau khi user quay lại từ confirm page (Quét tiếp).
  void resume() {
    _lastCode = null;
    emit(const MerchantRedeemState());
  }

  static String _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message'] ?? data['error'] ?? data['detail'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    return e.message ?? 'Đã xảy ra lỗi. Vui lòng thử lại.';
  }
}
