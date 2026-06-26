import 'app_config.dart';
import 'config/app_flavor.dart';
import 'firebase_options.dart';
import 'import.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const apiDomain = String.fromEnvironment('API_DOMAIN');
  if (apiDomain.isEmpty) {
    throw StateError(
      'API_DOMAIN must be set for production. '
      'Build with: --dart-define=API_DOMAIN=api.suyxet.com',
    );
  }

  AppFlavorConfig.initialize(const AppFlavorConfig(
    flavor: AppFlavor.prod,
    appName: 'CouppaMiniOS',
    apiDomain: apiDomain,
    enableLogging: false,
    enableCrashlytics: true,
  ));

  final monitoring = SharedMonitoring();
  if (monitoring.hasSupport) {
    await monitoring.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  await bootstrap(monitoring);
}
