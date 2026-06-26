import '../../../../import.dart';

class MerchantCouponFormState {
  const MerchantCouponFormState({
    this.isSubmitting = false,
    this.error,
    this.success = false,
  });

  final bool isSubmitting;
  final String? error;
  final bool success;

  MerchantCouponFormState copyWith({
    bool? isSubmitting,
    String? error,
    bool? success,
  }) {
    return MerchantCouponFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      success: success ?? this.success,
    );
  }
}

class MerchantCouponFormCubit extends Cubit<MerchantCouponFormState> {
  MerchantCouponFormCubit() : super(const MerchantCouponFormState());

  Future<void> submit({
    String? id,
    required String title,
    required String discount,
  }) async {
    emit(state.copyWith(isSubmitting: true));
    // TODO: call repository (create when id == null, else update)
    emit(state.copyWith(isSubmitting: false, success: true));
  }
}
