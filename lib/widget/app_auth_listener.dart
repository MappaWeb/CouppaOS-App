import 'package:core_auth/core_auth.dart';

// import '../data/merchant/merchant_session_cubit.dart';
import '../import.dart';

class AppAuthListener extends StatelessWidget {
  const AppAuthListener({super.key, required this.child});

  final Widget child;

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
    child: child,
  );
}
