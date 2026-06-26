import '../../../import.dart';
import 'bloc.dart';

class UserCouponPage extends StatelessWidget {
  const UserCouponPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserCouponCubit()..load(),
      child: const _UserCouponView(),
    );
  }
}

class _UserCouponView extends StatelessWidget {
  const _UserCouponView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coupon của tôi'),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<UserCouponCubit, UserCouponState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Chưa có coupon nào.\nTODO: hiển thị danh sách coupon.',
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
                leading: const Icon(Icons.confirmation_number,
                    color: Palette.primary),
                title: Text(coupon.title),
                subtitle: Text(
                  '${coupon.merchantName} • ${couponStatusLabel(coupon.status)}',
                ),
                trailing: Text(coupon.discount),
                onTap: () => appNavigator.pushNamed(
                  '/User/Coupon/Detail',
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
