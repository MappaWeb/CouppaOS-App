import '../../import.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  static String? redirect(BuildContext context, GoRouterState state) {
    final bootstrapState = context.read<BootstrapBloc>().state;
    if (bootstrapState is! BootstrapReady) {
      return null;
    }
    if (!AuthGuard.instance.isAuthenticated) {
      return '/Start/WithoutLogin';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
