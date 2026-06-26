import '../../../import.dart';

class MerchantCoupon {
  const MerchantCoupon({
    required this.id,
    required this.code,
    required this.title,
    required this.discount,
    required this.totalIssued,
    required this.totalUsed,
    required this.expiredAt,
  });

  final String id;
  final String code;
  final String title;
  final String discount;
  final int totalIssued;
  final int totalUsed;
  final DateTime expiredAt;
}

class MerchantCouponState {
  const MerchantCouponState({
    this.isLoading = false,
    this.items = const <MerchantCoupon>[],
    this.error,
  });

  final bool isLoading;
  final List<MerchantCoupon> items;
  final String? error;

  MerchantCouponState copyWith({
    bool? isLoading,
    List<MerchantCoupon>? items,
    String? error,
  }) {
    return MerchantCouponState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
    );
  }
}

class MerchantCouponCubit extends Cubit<MerchantCouponState> {
  MerchantCouponCubit() : super(const MerchantCouponState());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    // TODO: integrate repository / API call
    emit(state.copyWith(isLoading: false, items: const []));
  }

  Future<void> delete(String id) async {
    // TODO: call repository, then refresh
    await load();
  }
}
