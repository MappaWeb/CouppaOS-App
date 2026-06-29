import '../../import.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: viewAsUser,
      builder: (context, _, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isMerchant = getRole() == UserRole.merchant;

    return Scaffold(
      appBar: AppBar(title: Text(isMerchant ? 'Tài khoản Merchant' : 'Tài khoản')),
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          Center(
            child: Text(
              isMerchant ? 'Người bán' : 'Người dùng',
              style: const TextStyle(color: Palette.textPrimary4),
            ),
          ),
          if (getAccountRole() == UserRole.user) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FilledButton.icon(
                onPressed: () => appNavigator.pushNamed(RouterConstants.becomeMerchant),
                icon: const Icon(Icons.storefront_outlined),
                label: const Text('Trở thành cửa hàng'),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Divider(height: 1),
          if (canSwitchView)
            SwitchListTile(
              secondary: const Icon(Icons.swap_horiz),
              title: const Text('Dùng như người dùng'),
              subtitle: Text(
                viewAsUser.value ? 'Đang xem với quyền người dùng' : 'Đang xem với quyền người bán',
              ),
              value: viewAsUser.value,
              activeThumbColor: Palette.primary,
              onChanged: (value) => viewAsUser.value = value,
            ),
          if (canSwitchView) const Divider(height: 1),
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
            title: const Text('Đăng xuất', style: TextStyle(color: Palette.redTxtColor)),
            onTap: () {
              resetViewMode();
              AuthSetup.instance.authSessionBloc.add(const LoggedOut());
              appNavigator.go(RouterConstants.login);
            },
          ),
        ],
      ),
    );
  }
}
