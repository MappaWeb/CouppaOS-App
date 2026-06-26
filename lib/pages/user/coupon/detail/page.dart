import '../../../../import.dart';
import 'bloc.dart';

class UserCouponDetailPage extends StatelessWidget {
  const UserCouponDetailPage(this.args, {super.key});

  final Map? args;

  String get id => args?['id']?.toString() ?? '';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserCouponDetailCubit()..load(id),
      child: Scaffold(
        appBar: AppBar(title: const Text('Chi tiết coupon')),
        body: BlocBuilder<UserCouponDetailCubit, UserCouponDetailState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'TODO: chi tiết coupon $id\n(còn hạn / đã dùng / hết hạn)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Palette.textPrimary4),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
