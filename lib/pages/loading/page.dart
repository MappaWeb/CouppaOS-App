import '../../import.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xff0B74E5), Palette.primary]),
        ),
        width: .infinity,
        child: Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            Image.asset('assets/images/logo.png', width: 127, height: 127),
            Text(
              'Mappa'.lang(),
              style: const TextStyle(fontWeight: .w700, fontSize: 48, color: Colors.white),
            ),

            Text(
              context.l10n.searchNearbyStores,
              style: const TextStyle(fontWeight: .w400, fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 60),

            BlocSelector<ConfigBloc, ConfigState, double>(
              selector: (state) => state.percentLoading,
              builder: (context, percentLoading) {
                final value = (percentLoading / 100).clamp(0.0, 1.0);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    spacing: 12,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: value),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOut,
                          builder: (context, animatedValue, _) {
                            return LinearProgressIndicator(
                              value: animatedValue,
                              minHeight: 10,
                              backgroundColor: const Color(0xffFFFFFF).withValues(alpha: 0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            );
                          },
                        ),
                      ),
                      Text(
                        '${parseInt(percentLoading)} %',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: .w400),
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
}
