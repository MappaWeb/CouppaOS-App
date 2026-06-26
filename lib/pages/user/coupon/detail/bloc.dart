import '../../../../import.dart';
import '../bloc.dart';

class UserCouponDetailState {
  const UserCouponDetailState({this.coupon, this.isLoading = false, this.error});

  final UserCoupon? coupon;
  final bool isLoading;
  final String? error;

  UserCouponDetailState copyWith({
    UserCoupon? coupon,
    bool? isLoading,
    String? error,
  }) {
    return UserCouponDetailState(
      coupon: coupon ?? this.coupon,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UserCouponDetailCubit extends Cubit<UserCouponDetailState> {
  UserCouponDetailCubit() : super(const UserCouponDetailState());

  Future<void> load(String id) async {
    emit(state.copyWith(isLoading: true));
    // TODO: fetch coupon by id
    emit(state.copyWith(isLoading: false));
  }
}
