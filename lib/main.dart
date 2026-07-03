import 'app_config.dart';
import 'config/app_flavor.dart';
import 'firebase_options.dart';
import 'import.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppFlavorConfig.initialize(const AppFlavorConfig(
    flavor: AppFlavor.dev,
    appName: 'CouppaOS DEV',
    apiDomain: 'api-qr.dev.iotcommunication.net',
    enableLogging: true,
    enableCrashlytics: false,
  ));

  final monitoring = SharedMonitoring();
  if (monitoring.hasSupport) {
    await monitoring.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  await bootstrap(monitoring);
}
