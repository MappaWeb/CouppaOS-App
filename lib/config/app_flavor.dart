enum AppFlavor { dev, staging, prod }

class AppFlavorConfig {
  static AppFlavorConfig? _instance;

  final AppFlavor flavor;
  final String appName;
  final String apiDomain;
  final String appDomain;
  final bool enableLogging;
  final bool enableCrashlytics;

  const AppFlavorConfig({
    required this.flavor,
    required this.appName,
    required this.apiDomain,
    this.appDomain = 'https://couppa.coquan.vn',
    this.enableLogging = false,
    this.enableCrashlytics = false,
  });

  static void initialize(AppFlavorConfig config) {
    _instance = config;
  }

  static AppFlavorConfig get instance {
    if (_instance == null) {
      throw StateError('AppFlavorConfig chưa được khởi tạo. '
          'Gọi AppFlavorConfig.initialize() trong main trước.');
    }
    return _instance!;
  }

  bool get isProd => flavor == AppFlavor.prod;
  bool get isDev => flavor == AppFlavor.dev;
  bool get isStaging => flavor == AppFlavor.staging;
}
