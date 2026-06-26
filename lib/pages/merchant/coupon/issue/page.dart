import '../../../../import.dart';
import 'bloc.dart';

class MerchantCouponIssuePage extends StatelessWidget {
  const MerchantCouponIssuePage(this.args, {super.key});

  final Map? args;

  String get couponId => args?['id']?.toString() ?? '';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MerchantCouponIssueCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Phát hành coupon')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Coupon ID: $couponId',
                style: const TextStyle(color: Palette.textPrimary4),
              ),
              const SizedBox(height: 12),
              const Expanded(
                child: Center(
                  child: Text(
                    'TODO: chọn / tìm người dùng để phát hành coupon.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Palette.textPrimary4),
                  ),
                ),
              ),
              BlocConsumer<MerchantCouponIssueCubit, MerchantCouponIssueState>(
                listener: (context, state) {
                  if (state.success) appNavigator.pop();
                },
                builder: (context, state) {
                  return FilledButton(
                    onPressed: state.isSubmitting
                        ? null
                        : () => context.read<MerchantCouponIssueCubit>().issue(
                              couponId: couponId,
                              userIds: const [],
                            ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(state.isSubmitting
                          ? 'Đang phát hành...'
                          : 'Phát hành'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
