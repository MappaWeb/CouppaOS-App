import '../../../../import.dart';
import 'bloc.dart';

class MerchantRedeemConfirmPage extends StatelessWidget {
  const MerchantRedeemConfirmPage(this.args, {super.key});

  final Map? args;

  String get code => args?['code']?.toString() ?? '';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MerchantRedeemConfirmCubit()..load(code),
      child: Scaffold(
        appBar: AppBar(title: const Text('Xác nhận sử dụng coupon')),
        body: BlocConsumer<MerchantRedeemConfirmCubit, MerchantRedeemConfirmState>(
          listener: (context, state) {
            if (state.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xác nhận coupon')),
              );
              appNavigator.pop();
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mã QR: $code'),
                          const SizedBox(height: 8),
                          Text('Coupon: ${state.couponTitle ?? '—'}'),
                          const SizedBox(height: 4),
                          Text('Người dùng: ${state.userName ?? '—'}'),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: state.isSubmitting
                        ? null
                        : () => context
                            .read<MerchantRedeemConfirmCubit>()
                            .confirm(code),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(state.isSubmitting
                          ? 'Đang xác nhận...'
                          : 'Xác nhận & Claim'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
