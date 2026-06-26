// import '../data/merchant/merchant_session_cubit.dart';
import '../import.dart';

class AppAuthListener extends StatefulWidget {
  const AppAuthListener({super.key, required this.child});

  final Widget child;

  @override
  State<AppAuthListener> createState() => _AppAuthListenerState();
}

class _AppAuthListenerState extends State<AppAuthListener> {
  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      BlocListener<BootstrapBloc, BootstrapState>(
        listener: (context, state) {
          if (state is BootstrapReady) {
            if (state.session != null) {
              context.read<AuthSessionBloc>().add(LoggedIn(state.session!.asSharedUser()));
              _navigateToHomeIfNotYet(context);
            } else {
              AuthGuard.instance.isAuthenticated = false;
              ApplicationStateNotifier().refresh();
            }
          }
        },
      ),
      // TODO: tạm comment API /api/merchants/me
      // BlocListener<AuthSessionBloc, AuthSessionState>(
      //   listenWhen: (prev, next) =>
      //       prev is! AuthAuthenticated && next is AuthAuthenticated,
      //   listener: (context, state) {
      //     if (state is! AuthAuthenticated) return;
      //     // Chỉ fetch /api/merchants/me khi user thuộc role merchant.
      //     if (getRole() == UserRole.merchant) {
      //       context.read<MerchantSessionCubit>().fetchMe();
      //     }
      //   },
      // ),
      BlocListener<AuthSessionBloc, AuthSessionState>(
        listener: (context, state) {
          AuthGuard.instance.isAuthenticated = state is AuthAuthenticated;
          ApplicationStateNotifier().refresh();
        },
      ),
    ],
    child: widget.child,
  );

  void _navigateToHomeIfNotYet(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
      if (!currentRoute.startsWith('/User/') && !currentRoute.startsWith('/Merchant/')) {
        final route = getRole() == UserRole.merchant ? '/Merchant/Coupon' : '/User/Coupon';
        appNavigator.go(route);
      }
    });
  }
}
