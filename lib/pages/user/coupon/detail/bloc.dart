import '../../../../import.dart';

class UserCouponDetailState {
  const UserCouponDetailState({this.isLoading = false, this.error});

  final bool isLoading;
  final String? error;

  UserCouponDetailState copyWith({bool? isLoading, String? error}) {
    return UserCouponDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UserCouponDetailCubit extends Cubit<UserCouponDetailState> {
  UserCouponDetailCubit() : super(const UserCouponDetailState());

  Future<void> load(String id) async {
    emit(state.copyWith(isLoading: true));
    // TODO: fetch voucher detail theo voucherCodeId
    emit(state.copyWith(isLoading: false));
  }
}
