import '../../../../import.dart';
import 'bloc.dart';
import 'widgets/item.dart';

class MerchantStaffListPage extends StatelessWidget {
  const MerchantStaffListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MerchantStaffListBloc()),
        BlocProvider(
          create: (ctx) => MerchantStaffActionCubit(apiClient: ctx.read<ApiClient>()),
        ),
      ],
      child: const _MerchantStaffListView(),
    );
  }
}

class _MerchantStaffListView extends StatelessWidget {
  const _MerchantStaffListView();

  void _onActionResult(BuildContext context, MerchantStaffActionState state) {
    if (state.isSuccess) {
      showMessage(state.message ?? 'Thành công', type: 'success');
      context.read<MerchantStaffListBloc>().add(RefreshBaseList());
      context.read<MerchantStaffActionCubit>().reset();
    } else if (state.isFail) {
      showMessage(state.message ?? 'Có lỗi xảy ra', type: 'error');
      context.read<MerchantStaffActionCubit>().reset();
    }
  }

  Future<void> _onRevoke(BuildContext context, Map staff) async {
    final phone = (staff['phone'] ?? '') as String;
    await AppDialogs.showConfirmDialog(
      context: context,
      title: 'Thu hồi nhân viên',
      message: 'Thu hồi quyền truy cập của "$phone"?',
      textConfirm: 'Thu hồi',
      textCancel: 'Huỷ',
      onConfirm: () {
        appNavigator.pop();
        context.read<MerchantStaffActionCubit>().revoke((staff['id'] ?? '') as String);
      },
      onCancel: () => appNavigator.pop(),
    );
  }

  Future<void> _onEdit(BuildContext context, Map staff) async {
    final result = await appNavigator.pushNamed(
      RouterConstants.merchantStaffForm,
      arguments: staff,
    );
    if (result == true && context.mounted) {
      context.read<MerchantStaffListBloc>().add(RefreshBaseList());
    }
  }

  Future<void> _onAdd(BuildContext context) async {
    final result = await appNavigator.pushNamed(RouterConstants.merchantStaffForm);
    if (result == true && context.mounted) {
      context.read<MerchantStaffListBloc>().add(RefreshBaseList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MerchantStaffActionCubit, MerchantStaffActionState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: _onActionResult,
      child: Scaffold(
        backgroundColor: Palette.bgColor,
        appBar: BaseAppBar(context: context, title: const Text('Nhân viên cửa hàng')),
        body: SystemListView<MerchantStaffListBloc, SystemListState<Map>, Map>(
          detailBuilder: (context, item, _) => StaffItem(
            item,
            onEdit: () => _onEdit(context, item),
            onRevoke: () => _onRevoke(context, item),
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
          icon: const Icon(Icons.person_add_rounded),
          label: const Text('Thêm nhân viên'),
        ),
      ),
    );
  }
}
