import '../../import.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: .infinity,
        child: Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            const Icon(Icons.local_offer, size: 96, color: Palette.primary),
            const SizedBox(height: 16),
            const Text(
              'CouppaOS',
              style: TextStyle(fontWeight: .w700, fontSize: 40, color: Palette.primary),
            ),

            Text(
              'Săn coupon - Tiết kiệm thông minh',
              style: const TextStyle(fontWeight: .w400, fontSize: 18, color: Palette.primary),
            ),
            const SizedBox(height: 60),

            BlocSelector<ConfigBloc, ConfigState, ConfigStateStatus>(
              selector: (state) => state.status,
              builder: (context, status) {
                if (status == ConfigStateStatus.error) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      spacing: 12,
                      children: [
                        const Icon(Icons.wifi_off, size: 32, color: Palette.redTxtColor),
                        const Text(
                          'Không thể kết nối. Vui lòng kiểm tra mạng và thử lại.',
                          textAlign: .center,
                          style: TextStyle(color: Palette.redTxtColor, fontSize: 14, fontWeight: .w500),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: Palette.primary),
                          onPressed: () => context.read<ConfigBloc>().refresh(true),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    spacing: 12,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          minHeight: 10,
                          backgroundColor: Palette.primary.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(Palette.primary),
                        ),
                      ),
                      Text(
                        _statusText(status),
                        style: const TextStyle(color: Palette.primary, fontSize: 14, fontWeight: .w400),
                      ),
                    ],
                  ),
                );
              },
            ),

          ],
        ),
      ),
    );
  }

  String _statusText(ConfigStateStatus status) {
    switch (status) {
      case ConfigStateStatus.loaded:
        return 'Đã sẵn sàng';
      case ConfigStateStatus.loading:
      case ConfigStateStatus.initial:
      case ConfigStateStatus.error:
        return 'Đang khởi động...';
    }
  }
}
