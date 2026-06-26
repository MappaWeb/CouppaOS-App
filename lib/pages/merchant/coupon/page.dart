import '../../../import.dart';
import 'bloc.dart';

class MerchantCouponPage extends StatelessWidget {
  const MerchantCouponPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MerchantCouponCubit()..load(),
      child: const _MerchantCouponView(),
    );
  }
}

class _MerchantCouponView extends StatelessWidget {
  const _MerchantCouponView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Coupon'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => appNavigator.pushNamed('/Merchant/Coupon/Form'),
        icon: const Icon(Icons.add),
        label: const Text('Thêm coupon'),
      ),
      body: BlocBuilder<MerchantCouponCubit, MerchantCouponState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Chưa có coupon.\nTODO: hiển thị danh sách coupon do merchant tạo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Palette.textPrimary4),
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: state.items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final coupon = state.items[i];
              return ListTile(
                leading: const Icon(Icons.local_offer, color: Palette.primary),
                title: Text(coupon.title),
                subtitle: Text(
                  'Đã phát: ${coupon.totalIssued} • Đã dùng: ${coupon.totalUsed}',
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        appNavigator.pushNamed(
                          '/Merchant/Coupon/Form',
                          arguments: {'id': coupon.id},
                        );
                      case 'issue':
                        appNavigator.pushNamed(
                          '/Merchant/Coupon/Issue',
                          arguments: {'id': coupon.id},
                        );
                      case 'delete':
                        context.read<MerchantCouponCubit>().delete(coupon.id);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Sửa')),
                    PopupMenuItem(value: 'issue', child: Text('Phát hành')),
                    PopupMenuItem(value: 'delete', child: Text('Xoá')),
                  ],
                ),
                onTap: () => appNavigator.pushNamed(
                  '/Merchant/Coupon/Detail',
                  arguments: {'id': coupon.id},
                ),
              );
            },
          );
        },
      ),
    );
  }
}
