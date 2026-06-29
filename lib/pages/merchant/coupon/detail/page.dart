import '../../../../import.dart';
import 'bloc.dart';

class MerchantCouponDetailPage extends StatelessWidget {
  const MerchantCouponDetailPage(this.id, {super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MerchantCouponDetailBloc(id),
      child: Scaffold(
        appBar: AppBar(title: const Text('Chi tiết coupon')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Palette.textPrimary4),
            ),
          ),
        ),
      ),
    );
  }
}
