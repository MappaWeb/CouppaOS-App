import '../../../config/dev_bypass.dart';
import '../../../import.dart';

class StartWithoutLoginPage extends StatelessWidget {
  const StartWithoutLoginPage({super.key});

  void _bypass(UserRole role) {
    DevBypass.enter(role);
    appNavigator.go(RouterConstants.start);
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
              if (DevBypass.enabled) ...[
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 12),
                const Text(
                  'DEV BYPASS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: Palette.textPrimary4,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _bypass(UserRole.user),
                  icon: const Icon(Icons.person_outline),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text('Vào với role User'),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _bypass(UserRole.merchant),
                  icon: const Icon(Icons.storefront_outlined),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text('Vào với role Merchant'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
