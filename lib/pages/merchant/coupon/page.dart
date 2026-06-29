import '../../../import.dart';
import 'bloc.dart';
import 'model.dart';
import 'widgets/item.dart';

class MerchantCouponPage extends StatelessWidget {
  const MerchantCouponPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MerchantCouponListBloc(),
      child: const _MerchantCouponView(),
    );
  }
}

class _MerchantCouponView extends StatelessWidget {
  const _MerchantCouponView();

  static const _usedItems = [
    {'id': 'unused', 'title': 'Chưa dùng'},
    {'id': 'used', 'title': 'Đã dùng'},
  ];

  @override
  Widget build(BuildContext context) {
    return SystemListScaffold<MerchantCouponListBloc, SystemListState<VoucherModel>, VoucherModel>(
      backgroundColor: Palette.cardColor,
      appBar: BaseAppBar(
        context: context,
        title: const Text('Quản lý chiến dịch'),
        automaticallyImplyLeading: false,
      ),
      searchBarOption:
          SearchBarOption<MerchantCouponListBloc, SystemListState<VoucherModel>, VoucherModel>(
            hintText: 'Tìm theo mã / tên',
            extraFilters: (getFilter, onChanged) => Column(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FieldSelect.dropdown(
                  labelText: 'Trạng thái sử dụng',
                  items: _usedItems,
                  value: getFilter('used') as String?,
                  onChanged: (v) => onChanged<String>('used', v as String?),
                ),
                FieldDate(
                  labelText: 'Phát hành từ',
                  dateFormat: 'yyyy-MM-dd',
                  value: getFilter('issueFrom') as String?,
                  onChanged: (v) => onChanged<String>('issueFrom', v),
                ),
                FieldDate(
                  labelText: 'Phát hành đến',
                  dateFormat: 'yyyy-MM-dd',
                  value: getFilter('issueTo') as String?,
                  onChanged: (v) => onChanged<String>('issueTo', v),
                ),
                FieldDate(
                  labelText: 'Sử dụng từ',
                  dateFormat: 'yyyy-MM-dd',
                  value: getFilter('redeemFrom') as String?,
                  onChanged: (v) => onChanged<String>('redeemFrom', v),
                ),
                FieldDate(
                  labelText: 'Sử dụng đến',
                  dateFormat: 'yyyy-MM-dd',
                  value: getFilter('redeemTo') as String?,
                  onChanged: (v) => onChanged<String>('redeemTo', v),
                ),
              ],
            ),
          ),
      padding: const EdgeInsets.all(16),
      detailBuilder: (context, item, isSelected) => MerchantCouponListItem(
        item,
        onTap: () {
          appNavigator.pushNamed(RouterConstants.merchantCouponDetail, arguments: {'id': item.id});
        },
      ),
      floatingActionButton: Builder(
        builder: (ctx) => FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Tạo chiến dịch'),
          onPressed: () async {
            final result = await appNavigator.pushNamed(RouterConstants.merchantCouponForm);
            if (result == true && ctx.mounted) {
              ctx.read<MerchantCouponListBloc>().add(RefreshBaseList());
            }
          },
        ).paddingOnly(bottom: MediaQuery.paddingOf(context).bottom),
      ),
    );
  }
}
