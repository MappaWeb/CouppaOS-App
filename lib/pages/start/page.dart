import '../../config/dev_bypass.dart';
import '../../import.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  static String? redirect(BuildContext context, GoRouterState state) {
    if (DevBypass.active) {
      return DevBypass.role == UserRole.merchant
          ? '/Merchant/Coupon'
          : '/User/Coupon';
    }
    if (!AuthGuard.instance.isAuthenticated) {
      return '/Start/WithoutLogin';
    }
    return getRole() == UserRole.merchant ? '/Merchant/Coupon' : '/User/Coupon';
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
