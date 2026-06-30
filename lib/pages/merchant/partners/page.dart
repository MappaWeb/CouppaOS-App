import 'dart:ui';

import '../../../import.dart';
import 'bloc.dart';
import 'widgets/link_item.dart';
import 'widgets/partner_item.dart';
import 'widgets/send_link_dialog.dart';

class MerchantPartnersPage extends StatelessWidget {
  const MerchantPartnersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MerchantPartnersBloc()),
        BlocProvider(create: (_) => MerchantLinksBloc()),
        BlocProvider(create: (ctx) => PartnerActionCubit(apiClient: ctx.read<ApiClient>())),
      ],
      child: const _MerchantPartnersView(),
    );
  }
}

class _MerchantPartnersView extends StatelessWidget {
  const _MerchantPartnersView();

  void _onActionResult(BuildContext context, PartnerActionState state) {
    if (state.status == PartnerActionStatus.success) {
      showMessage(state.message ?? 'Thành công', type: 'success');
      switch (state.kind) {
        case PartnerActionKind.send:
        case PartnerActionKind.reject:
          context.read<MerchantLinksBloc>().add(RefreshBaseList());
          break;
        case PartnerActionKind.accept:
          context.read<MerchantLinksBloc>().add(RefreshBaseList());
          context.read<MerchantPartnersBloc>().add(RefreshBaseList());
          break;
        case null:
          break;
      }
      context.read<PartnerActionCubit>().reset();
    } else if (state.status == PartnerActionStatus.fail) {
      showMessage(state.message ?? 'Có lỗi xảy ra', type: 'error');
      context.read<PartnerActionCubit>().reset();
    }
  }

  Future<void> _onSendTap(BuildContext context) async {
    final phone = await showSendLinkDialog(context);
    if (phone == null) return;
    if (!context.mounted) return;
    await context.read<PartnerActionCubit>().sendRequest(phone);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PartnerActionCubit, PartnerActionState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: _onActionResult,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Palette.bgColor,
          appBar: BaseAppBar(
            context: context,
            title: const Text('Đối tác hợp tác'),
            automaticallyImplyLeading: false,
            bottom: const TabBar(
              labelColor: Palette.primary,
              unselectedLabelColor: Palette.textPrimary3,
              indicatorColor: Palette.primary,
              indicatorSize: .tab,
              tabs: [
                Tab(text: 'Đối tác'),
                Tab(text: 'Yêu cầu liên kết'),
              ],
            ),
          ),
          body: const TabBarView(children: [_PartnersTab(), _LinksTab()]),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Palette.primary,
            foregroundColor: Colors.white,
            onPressed: () => _onSendTap(context),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Gửi yêu cầu'),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Tab 1 — Đối tác đã liên kết
// ═══════════════════════════════════════════════════════════════════

class _PartnersTab extends StatelessWidget {
  const _PartnersTab();

  @override
  Widget build(BuildContext context) {
    return SystemListView<MerchantPartnersBloc, SystemListState<Map>, Map>(
      detailBuilder: (context, item, isSelected) {
        return PartnerItem(item);
      },
      bottomSlivers: [
        SliverToBoxAdapter(child: SizedBox(height: MediaQuery.paddingOf(context).bottom)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Tab 2 — Yêu cầu liên kết (incoming + outgoing)
// ═══════════════════════════════════════════════════════════════════

class _LinksTab extends StatelessWidget {
  const _LinksTab();

  Future<void> _respond(BuildContext context, Map link, {required bool accept}) async {
    final name = (link['merchantName'] ?? '') as String;
    final id = (link['id'] ?? '') as String;
    if (id.isEmpty) return;
    final cubit = context.read<PartnerActionCubit>();
    await AppDialogs.showConfirmDialog(
      context: context,
      title: accept ? 'Duyệt yêu cầu' : 'Từ chối yêu cầu',
      message: accept ? 'Đồng ý liên kết với "$name"?' : 'Từ chối yêu cầu liên kết từ "$name"?',
      textConfirm: accept ? 'Duyệt' : 'Từ chối',
      textCancel: 'Huỷ',
      onConfirm: () {
        appNavigator.pop();
        cubit.respond(linkId: id, accept: accept);
      },
      onCancel: () => appNavigator.pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.read<PartnerActionCubit>().state.isSubmitting;
    return Stack(
      children: [
        SystemListView<MerchantLinksBloc, SystemListState<Map>, Map>(
          detailBuilder: (context, item, isSelected) {
            return LinkItem(
              item,
              onAccept: () => _respond(context, item, accept: true),
              onReject: () => _respond(context, item, accept: false),
            );
          },
          bottomSlivers: [
            SliverToBoxAdapter(child: SizedBox(height: MediaQuery.paddingOf(context).bottom)),
          ],
        ),
        if (isSubmitting)
          Positioned.fill(
            child: Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                  child: Container(color: Colors.black.withValues(alpha: 0.2)),
                ),
                const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
      ],
    );
  }
}
