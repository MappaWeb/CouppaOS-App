import '../../../import.dart';

class MerchantPartnersBloc extends SystemListBloc<SystemListState<Map>, Map> {
  MerchantPartnersBloc() : super(dataSource: ApiService.merchant.apiPath(AppApi.merchant.partners));
}
