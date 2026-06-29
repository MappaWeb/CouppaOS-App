import '../../../../import.dart';

class MerchantCouponDetailBloc extends SystemDetailBloc<SystemDetailState> {
  final String id;

  MerchantCouponDetailBloc(this.id)
    : super(dataSource: ApiService.coupon.apiPath(AppApi.voucher.campaignById(id)));
}
