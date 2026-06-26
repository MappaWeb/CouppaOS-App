// import '../data/merchant/merchant_session_cubit.dart';
import '../import.dart';

class AppAuthListener extends StatefulWidget {
  const AppAuthListener({super.key, required this.child});

  final Widget child;

  @override
  State<AppAuthListener> createState() => _AppAuthListenerState();
}

class _AppAuthListenerState extends State<AppAuthListener> {
  bool _navigatedPostAuth = false;

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      BlocListener<BootstrapBloc, BootstrapState>(
        listener: (context, state) {
          if (state is BootstrapReady) {
            if (state.session != null) {
              context.read<AuthSessionBloc>().add(LoggedIn(state.session!.asSharedUser()));
            } else {
              AuthGuard.instance.isAuthenticated = false;
              ApplicationStateNotifier().refresh();
            }
            _navigatePostAuthIfNeeded(context);
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

  void _navigatePostAuthIfNeeded(BuildContext context) {
    if (_navigatedPostAuth || !AuthGuard.instance.isAuthenticated) return;
    _navigatedPostAuth = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = getRole() == UserRole.merchant ? '/Merchant/Coupon' : '/User/Coupon';
      appNavigator.go(route);
    });
  }
}
