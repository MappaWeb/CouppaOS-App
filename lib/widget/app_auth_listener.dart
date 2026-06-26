import '../import.dart';

/// Lắng nghe vòng đời auth của app và điều hướng tương ứng:
/// - Bootstrap xong → bơm session cache vào [AuthSessionBloc] hoặc đánh dấu chưa login.
/// - Auth đổi (login/logout/expired) → điều hướng tới home theo role hoặc về login.
class AppAuthListener extends StatefulWidget {
  const AppAuthListener({super.key, required this.child});

  final Widget child;

  @override
  State<AppAuthListener> createState() => _AppAuthListenerState();
}

class _AppAuthListenerState extends State<AppAuthListener> {
  // Guard: tránh điều hướng lặp khi AuthAuthenticated được emit nhiều lần
  // (vd: refresh token). Reset về false mỗi khi rời trạng thái authenticated.
  bool _didNavigatePostAuth = false;

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      // 1) Bootstrap xong: chuyển session đã cache (nếu có) vào AuthSessionBloc,
      //    để chính BlocListener<AuthSessionBloc> bên dưới lo việc điều hướng.
      //    Nếu không có session → đánh dấu chưa login để StartPage redirect
      //    sang /Start/WithoutLogin.
      BlocListener<BootstrapBloc, BootstrapState>(
        listenWhen: (_, next) => next is BootstrapReady,
        listener: (context, state) {
          final ready = state as BootstrapReady;
          if (ready.session != null) {
            context.read<AuthSessionBloc>().add(LoggedIn(ready.session!.asSharedUser()));
          } else {
            AuthGuard.instance.isAuthenticated = false;
            ApplicationStateNotifier().refresh();
          }
        },
      ),
      // 2) Nguồn chân lý duy nhất cho điều hướng theo auth. listenWhen chỉ cho qua
      //    khi trạng thái "đã xác thực" THỰC SỰ đổi (login, logout, expired) —
      //    bỏ qua các lần emit lại cùng nhóm (AuthInitial→AuthLoading, refresh token).
      BlocListener<AuthSessionBloc, AuthSessionState>(
        listenWhen: (prev, next) =>
            (prev is AuthAuthenticated) != (next is AuthAuthenticated),
        listener: _onAuthStateChanged,
      ),
    ],
    child: widget.child,
  );

  void _onAuthStateChanged(BuildContext context, AuthSessionState state) {
    final isAuthenticated = state is AuthAuthenticated;
    AuthGuard.instance.isAuthenticated = isAuthenticated;

    if (isAuthenticated) {
      _redirectToRoleHome();
    } else {
      // Logout / token hết hạn: mở lại guard và để shell route (_requireAuth)
      // tự đẩy về /Login khi ApplicationStateNotifier refresh.
      _didNavigatePostAuth = false;
    }

    ApplicationStateNotifier().refresh();
  }

  void _redirectToRoleHome() {
    if (_didNavigatePostAuth) return;
    _didNavigatePostAuth = true;

    // Hoãn tới sau frame: lúc listener chạy, widget tree / router có thể chưa
    // sẵn sàng nhận lệnh điều hướng.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final target = getRole() == UserRole.merchant
          ? '/Merchant/Coupon'
          : '/User/Coupon';
      if (appNavigator.currentUri?.path != target) {
        appNavigator.go(target);
      }
    });
  }
}
