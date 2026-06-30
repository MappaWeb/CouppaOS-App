import '../../../../import.dart';
import 'bloc.dart';
import 'widgets/item.dart';

class MerchantStoreListPage extends StatelessWidget {
  const MerchantStoreListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => MerchantStoreListBloc(apiClient: ctx.read<ApiClient>()),
      child: const _MerchantStoreListView(),
    );
  }
}

class _MerchantStoreListView extends StatelessWidget {
  const _MerchantStoreListView();

  Future<void> _onAdd(BuildContext context) async {
    final result = await appNavigator.pushNamed(RouterConstants.merchantStoreForm);
    if (result == true && context.mounted) {
      context.read<MerchantStoreListBloc>().add(RefreshBaseList());
    }
  }

  Future<void> _onEdit(BuildContext context, Map store) async {
    final result = await appNavigator.pushNamed(
      RouterConstants.merchantStoreForm,
      arguments: store,
    );
    if (result == true && context.mounted) {
      context.read<MerchantStoreListBloc>().add(RefreshBaseList());
    }
  }

  Future<void> _onDelete(BuildContext context, Map store) async {
    final name = (store['name'] ?? '') as String;
    await AppDialogs.showConfirmDialog(
      context: context,
      title: 'Xoá chi nhánh',
      message: 'Bạn có chắc muốn xoá chi nhánh "$name"?',
      textConfirm: 'Xoá',
      textCancel: 'Huỷ',
      onConfirm: () {
        appNavigator.pop();
        context
            .read<MerchantStoreListBloc>()
            .add(DeleteStoreRequested((store['id'] ?? '') as String));
      },
      onCancel: () => appNavigator.pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MerchantStoreListBloc, SystemListState<Map>>(
      listenWhen: (p, c) =>
          p.extraData['actionResult'] != c.extraData['actionResult'] &&
          c.extraData['actionResult'] != null,
      listener: (ctx, state) {
        final result = state.extraData['actionResult'];
        final msg = state.extraData['actionMessage'] as String?;
        if (msg != null) {
          showMessage(msg, type: result == 'success' ? 'success' : 'error');
        }
      },
      child: Scaffold(
        backgroundColor: Palette.bgColor,
        appBar: BaseAppBar(
          context: context,
          title: const Text('Danh sách chi nhánh'),
        ),
        body: SystemListView<MerchantStoreListBloc, SystemListState<Map>, Map>(
          detailBuilder: (context, item, _) => StoreItem(
            item,
            onTap: () => _onEdit(context, item),
            onDelete: () => _onDelete(context, item),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          bottomSlivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 88),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Palette.primary,
          foregroundColor: Colors.white,
          onPressed: () => _onAdd(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Thêm chi nhánh'),
        ),
      ),
    );
  }
}
