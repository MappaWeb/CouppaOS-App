import '../../../../import.dart';
import 'bloc.dart';

class MerchantCouponDetailPage extends StatelessWidget {
  const MerchantCouponDetailPage(this.map, {super.key});

  final Map? map;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MerchantCouponDetailBloc(map?['id'] ?? ''),
      child: _Content(),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return SystemDetailScaffold<MerchantCouponDetailBloc>(
      appBar: AppBar(title: const Text('Chi tiết coupon')),
      builder: (context, state, response) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              response['title'] ?? response['name'] ?? 'IDK',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Palette.textPrimary4),
            ),
          ),
        );
      },
    );
  }
}
