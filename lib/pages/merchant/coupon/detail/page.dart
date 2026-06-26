import '../../../../import.dart';

class MerchantCouponDetailPage extends StatelessWidget {
  const MerchantCouponDetailPage(this.args, {super.key});

  final Map? args;

  String get id => args?['id']?.toString() ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết coupon')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'TODO: chi tiết coupon $id của merchant',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Palette.textPrimary4),
          ),
        ),
      ),
    );
  }
}
