import '../../../../import.dart';

class MerchantRedeemConfirmState {
  const MerchantRedeemConfirmState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.couponTitle,
    this.userName,
    this.success = false,
    this.error,
  });

  final bool isLoading;
  final bool isSubmitting;
  final String? couponTitle;
  final String? userName;
  final bool success;
  final String? error;

  MerchantRedeemConfirmState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? couponTitle,
    String? userName,
    bool? success,
    String? error,
  }) {
    return MerchantRedeemConfirmState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      couponTitle: couponTitle ?? this.couponTitle,
      userName: userName ?? this.userName,
      success: success ?? this.success,
      error: error,
    );
  }
}

class MerchantRedeemConfirmCubit extends Cubit<MerchantRedeemConfirmState> {
  MerchantRedeemConfirmCubit() : super(const MerchantRedeemConfirmState());

  Future<void> load(String code) async {
    emit(state.copyWith(isLoading: true));
    // TODO: lookup coupon + user by QR code
    emit(state.copyWith(isLoading: false));
  }

  Future<void> confirm(String code) async {
    emit(state.copyWith(isSubmitting: true));
    // TODO: call claim/redeem API
    emit(state.copyWith(isSubmitting: false, success: true));
  }
}
