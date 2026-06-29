import '../../../../import.dart';

class MerchantCouponDetailBloc extends SystemDetailBloc<SystemDetailState> {
  final String id;

  MerchantCouponDetailBloc(this.id)
    : super(dataSource: ApiService.coupon.apiPath(AppApi.voucher.campaignById(id)));
}

class MerchantCouponDetailCodesBloc extends SystemListBloc<SystemListState<Map>, Map> {
  final String id;

  MerchantCouponDetailCodesBloc(this.id)
    : super(dataSource: ApiService.coupon.apiPath(AppApi.voucher.campaignVouchers(id)));
}
