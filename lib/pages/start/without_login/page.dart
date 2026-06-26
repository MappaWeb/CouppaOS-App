import '../../../import.dart';

class StartWithoutLoginPage extends StatelessWidget {
  const StartWithoutLoginPage({super.key});

  static String? redirect(BuildContext context, GoRouterState state) {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.local_offer, size: 96, color: Palette.primary),
              const SizedBox(height: 16),
              const Text(
                'Couppa Mini',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Săn coupon — Tiết kiệm thông minh',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Palette.textPrimary4),
              ),
              const SizedBox(height: 40),
              FilledButton(
                onPressed: () => appNavigator.go('/Login'),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Đăng nhập'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
