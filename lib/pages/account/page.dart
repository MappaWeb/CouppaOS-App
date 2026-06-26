import '../../config/dev_bypass.dart';
import '../../import.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final role = getRole();
    final isMerchant = role == UserRole.merchant;

    return Scaffold(
      appBar: AppBar(
        title: Text(isMerchant ? 'Tài khoản Merchant' : 'Tài khoản'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 40,
            backgroundColor: Palette.bgColor,
            child: Icon(
              isMerchant ? Icons.storefront : Icons.person,
              size: 40,
              color: Palette.primary,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              currentUser?.displayName ?? 'Khách',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Center(
            child: Text(
              isMerchant ? 'Người bán' : 'Người dùng',
              style: const TextStyle(color: Palette.textPrimary4),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Thông tin cá nhân'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: navigate to edit information
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Palette.redTxtColor),
            title: const Text(
              'Đăng xuất',
              style: TextStyle(color: Palette.redTxtColor),
            ),
            onTap: () {
              DevBypass.exit();
              AuthSetup.instance.authSessionBloc.add(const LoggedOut());
              appNavigator.go('/Start/WithoutLogin');
            },
          ),
        ],
      ),
    );
  }
}
