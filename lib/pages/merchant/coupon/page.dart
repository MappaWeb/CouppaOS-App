import 'package:flutter_speed_dial/flutter_speed_dial.dart';

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

  Future<void> _open(BuildContext context, String route) async {
    final bloc = context.read<MerchantCouponListBloc>();
    final result = await appNavigator.pushNamed(route);
    if (result == true) {
      bloc.add(RefreshBaseList());
    }
  }

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
      detailBuilder: (context, item, isSelected) => Builder(
        builder: (ctx) => MerchantCouponListItem(
          item,
          onTap: () {
            appNavigator.pushNamed(
              RouterConstants.merchantCouponDetail,
              arguments: {'id': item.id},
            );
          },
          onEdit: () async {
            final result = await appNavigator.pushNamed(
              RouterConstants.merchantCouponCampaign,
              arguments: item.toJson(),
            );
            if (result == true && ctx.mounted) {
              ctx.read<MerchantCouponListBloc>().add(RefreshBaseList());
            }
          },
        ),
      ),
      bottomSlivers: [
        SliverToBoxAdapter(child: SizedBox(height: MediaQuery.paddingOf(context).bottom)),
      ],
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Palette.primary,
        foregroundColor: Colors.white,
        spacing: 12,
        spaceBetweenChildren: 8,
        overlayColor: Colors.black,
        overlayOpacity: 0.4,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.confirmation_number_outlined),
            label: 'Tạo voucher',
            backgroundColor: Palette.primary,
            foregroundColor: Colors.white,
            onTap: () => _open(context, RouterConstants.merchantCouponBatch),
          ),
          SpeedDialChild(
            child: const Icon(Icons.campaign_outlined),
            label: 'Tạo chiến dịch',
            backgroundColor: Palette.primary,
            foregroundColor: Colors.white,
            onTap: () => _open(context, RouterConstants.merchantCouponCampaign),
          ),
        ],
      ),
    );
  }
}
