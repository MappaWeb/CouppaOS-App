import '../../../import.dart';
import 'model.dart';


class MerchantCouponListBloc extends AppListBloc<VoucherModel> {
  MerchantCouponListBloc({Map<String, dynamic>? initialFilters})
      : super(
          empty: const VoucherModel.empty(),
          dataSource: ApiService.coupon.apiPath(AppApi.voucher.campaigns),
          query: ListQuery.fromMap(initialFilters ?? const {}),
        );
}

