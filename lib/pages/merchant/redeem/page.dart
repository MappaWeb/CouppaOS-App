import '../../../import.dart';
import 'bloc.dart';

class MerchantRedeemPage extends StatelessWidget {
  const MerchantRedeemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MerchantRedeemCubit(),
      child: const _MerchantRedeemView(),
    );
  }
}

class _MerchantRedeemView extends StatelessWidget {
  const _MerchantRedeemView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét mã coupon'),
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<MerchantRedeemCubit, MerchantRedeemState>(
        listener: (context, state) {
          if (state.lastScannedCode != null) {
            appNavigator.pushNamed(
              '/Merchant/Redeem/Confirm',
              arguments: {'code': state.lastScannedCode},
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Container(
                color: Colors.black,
                alignment: Alignment.center,
                child: const Text(
                  'TODO: gắn camera scanner (mobile_scanner)\nđể đọc QR coupon từ người dùng.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: FilledButton.icon(
                  onPressed: () => context
                      .read<MerchantRedeemCubit>()
                      .onScanned('DEMO-CODE-001'),
                  icon: const Icon(Icons.qr_code),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Giả lập quét mã'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
