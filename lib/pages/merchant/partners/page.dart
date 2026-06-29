import 'dart:async';

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
        BlocProvider(
          create: (ctx) =>
              PartnerActionCubit(apiClient: ctx.read<ApiClient>()),
        ),
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
          body: const TabBarView(
            children: [
              _PartnersTab(),
              _LinksTab(),
            ],
          ),
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

  Future<void> _onRefresh(BuildContext context) {
    final completer = Completer<void>();
    context.read<MerchantPartnersBloc>().add(
      RefreshBaseList(clearItems: false, completer: completer),
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MerchantPartnersBloc, SystemListState<Map>>(
      builder: (context, state) {
        if (state.showLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.isFail) {
          return _ErrorView(
            message: state.message ?? 'Có lỗi xảy ra',
            onRetry: () => context.read<MerchantPartnersBloc>().add(
              RefreshBaseList(clearItems: true),
            ),
          );
        }
        final items = state.items.map((e) => e.value).toList();
        return RefreshIndicator(
          onRefresh: () => _onRefresh(context),
          child: items.isEmpty
              ? const _EmptyView(message: 'Chưa có đối tác nào liên kết.')
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => PartnerItem(items[i]),
                ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Tab 2 — Yêu cầu liên kết (incoming + outgoing)
// ═══════════════════════════════════════════════════════════════════

class _LinksTab extends StatelessWidget {
  const _LinksTab();

  Future<void> _onRefresh(BuildContext context) {
    final completer = Completer<void>();
    context.read<MerchantLinksBloc>().add(
      RefreshBaseList(clearItems: false, completer: completer),
    );
    return completer.future;
  }

  Future<void> _respond(
    BuildContext context,
    Map link, {
    required bool accept,
  }) async {
    final name = (link['merchantName'] ?? '') as String;
    final id = (link['id'] ?? '') as String;
    if (id.isEmpty) return;
    final cubit = context.read<PartnerActionCubit>();
    await AppDialogs.showConfirmDialog(
      context: context,
      title: accept ? 'Duyệt yêu cầu' : 'Từ chối yêu cầu',
      message: accept
          ? 'Đồng ý liên kết với "$name"?'
          : 'Từ chối yêu cầu liên kết từ "$name"?',
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
    return BlocBuilder<MerchantLinksBloc, SystemListState<Map>>(
      builder: (context, state) {
        if (state.showLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.isFail) {
          return _ErrorView(
            message: state.message ?? 'Có lỗi xảy ra',
            onRetry: () => context.read<MerchantLinksBloc>().add(
              RefreshBaseList(clearItems: true),
            ),
          );
        }
        final items = state.items.map((e) => e.value).toList();
        return BlocBuilder<PartnerActionCubit, PartnerActionState>(
          buildWhen: (p, c) => p.isSubmitting != c.isSubmitting,
          builder: (context, actionState) {
            return RefreshIndicator(
              onRefresh: () => _onRefresh(context),
              child: items.isEmpty
                  ? const _EmptyView(
                      message: 'Chưa có yêu cầu liên kết nào.',
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final link = items[i];
                        return LinkItem(
                          link,
                          isBusy: actionState.isSubmitting,
                          onAccept: () =>
                              _respond(context, link, accept: true),
                          onReject: () =>
                              _respond(context, link, accept: false),
                        );
                      },
                    ),
            );
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Shared sub-widgets
// ═══════════════════════════════════════════════════════════════════

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Palette.textPrimary4),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Palette.textPrimary4,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Palette.textPrimary4),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
