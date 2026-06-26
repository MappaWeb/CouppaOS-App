import '../../../import.dart';

class UserCoupon {
  const UserCoupon({
    required this.id,
    required this.code,
    required this.title,
    required this.merchantName,
    required this.discount,
    required this.expiredAt,
    required this.status,
  });

  final String id;
  final String code;
  final String title;
  final String merchantName;
  final String discount;
  final DateTime expiredAt;
  final CouponStatus status;
}

class UserCouponState {
  const UserCouponState({
    this.isLoading = false,
    this.items = const <UserCoupon>[],
    this.error,
  });

  final bool isLoading;
  final List<UserCoupon> items;
  final String? error;

  UserCouponState copyWith({
    bool? isLoading,
    List<UserCoupon>? items,
    String? error,
  }) {
    return UserCouponState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
    );
  }
}

class UserCouponCubit extends Cubit<UserCouponState> {
  UserCouponCubit() : super(const UserCouponState());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    // TODO: integrate repository / API call
    emit(state.copyWith(isLoading: false, items: const []));
  }
}
