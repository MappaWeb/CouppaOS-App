import '../../../import.dart';
import 'model.dart';

class MyVoucherListBloc extends AppListBloc<MyVoucherModel> {
  MyVoucherListBloc({Map<String, dynamic>? initialFilters})
      : super(
          empty: const MyVoucherModel.empty(),
          dataSource: ApiService.coupon.apiPath(AppApi.voucher.vouchersMine),
          query: ListQuery.fromMap(initialFilters ?? const {}),
        );
}
