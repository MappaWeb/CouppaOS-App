import 'dart:async';

import '../../../import.dart';
import 'bloc.dart';
import 'model.dart';
import 'widgets/item.dart';

class UserCouponPage extends StatelessWidget {
  const UserCouponPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyVoucherListBloc(),
      child: const _UserCouponView(),
    );
  }
}

class _UserCouponView extends StatelessWidget {
  const _UserCouponView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Palette.cardColor,
        appBar: AppBar(
          title: const Text('Coupon của tôi'),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            labelColor: Palette.primary,
            unselectedLabelColor: Palette.textPrimary3,
            indicatorColor: Palette.primary,
            tabs: [
              Tab(text: 'Có thể dùng'),
              Tab(text: 'Đã dùng / Hết hạn'),
            ],
          ),
        ),
        body: BlocBuilder<MyVoucherListBloc, SystemListState<MyVoucherModel>>(
          builder: (context, state) {
            if (state.showLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.isFail) {
              return _ErrorView(
                message: state.message ?? 'Có lỗi xảy ra',
                onRetry: () => context
                    .read<MyVoucherListBloc>()
                    .add(RefreshBaseList(clearItems: true)),
              );
            }

            final all = state.items.map((e) => e.value).toList();
            final usable = <MyVoucherModel>[];
            final used = <MyVoucherModel>[];
            for (final v in all) {
              (v.isUsable ? usable : used).add(v);
            }

            return TabBarView(
              children: [
                _CouponList(
                  items: usable,
                  emptyMessage: 'Chưa có coupon nào có thể dùng.',
                ),
                _CouponList(
                  items: used,
                  emptyMessage: 'Chưa có coupon nào đã dùng hoặc hết hạn.',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CouponList extends StatelessWidget {
  const _CouponList({required this.items, required this.emptyMessage});

  final List<MyVoucherModel> items;
  final String emptyMessage;

  Future<void> _onRefresh(BuildContext context) {
    final completer = Completer<void>();
    context.read<MyVoucherListBloc>().add(
          RefreshBaseList(clearItems: false, completer: completer),
        );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _onRefresh(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 80,
              ),
              child: Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Palette.textPrimary4),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _onRefresh(context),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final item = items[i];
          return UserCouponListItem(
            item,
            onTap: () => appNavigator.pushNamed(
              RouterConstants.userCouponDetail,
              arguments: {'id': item.voucherCodeId},
            ),
          );
        },
      ),
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
            const Icon(Icons.error_outline, color: Palette.textPrimary4, size: 40),
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
