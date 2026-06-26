import '../../../../import.dart';

class MerchantCouponIssueState {
  const MerchantCouponIssueState({
    this.isSubmitting = false,
    this.error,
    this.success = false,
  });

  final bool isSubmitting;
  final String? error;
  final bool success;

  MerchantCouponIssueState copyWith({
    bool? isSubmitting,
    String? error,
    bool? success,
  }) {
    return MerchantCouponIssueState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      success: success ?? this.success,
    );
  }
}

class MerchantCouponIssueCubit extends Cubit<MerchantCouponIssueState> {
  MerchantCouponIssueCubit() : super(const MerchantCouponIssueState());

  Future<void> issue({
    required String couponId,
    required List<String> userIds,
  }) async {
    emit(state.copyWith(isSubmitting: true));
    // TODO: call repository to issue coupon to selected users
    emit(state.copyWith(isSubmitting: false, success: true));
  }
}
