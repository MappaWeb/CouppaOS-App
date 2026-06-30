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
/// Không cần gọi API verify lần 2 vì scanner đã verify trước khi navigate.
/// `confirm()` thực hiện đổi mã thật (hiện mock, TODO: thay bằng API thật).
class MerchantRedeemConfirmCubit extends Cubit<MerchantRedeemConfirmState> {
  MerchantRedeemConfirmCubit({
    required ApiClient apiClient,
    required Map<String, dynamic> initialData,
  })  : _apiClient = apiClient, // ignore: prefer_initializing_formals
        super(MerchantRedeemConfirmState(verifyData: initialData));

  // Retained for when the real redeem API is wired up.
  // ignore: unused_field
  final ApiClient _apiClient;

  Future<void> confirm(String code) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true, clearError: true));
    // TODO: thay bằng POST /vouchers/redeem {"token": code}
    await Future.delayed(const Duration(milliseconds: 800));
    emit(state.copyWith(isSubmitting: false, success: true));
  }
}
