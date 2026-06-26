import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_theme.dart';
import 'config/app_flavor.dart';
import 'data/merchant/merchant_session_cubit.dart';
import 'import.dart';
import 'notifications/bloc/notification_count_cubit.dart';
import 'notifications/data/notification_data_source.dart';
import 'notifications/data/notification_sse_service.dart';
import 'pages/loading/page.dart';
import 'routes.dart';
import 'shell_router.dart';
import 'widget/app_auth_listener.dart';

Future<void> bootstrap(SharedMonitoring monitoring) async {
  final config = AppFlavorConfig.instance;
  configureAppSite(domain: config.appDomain, title: config.appName);
  final apiClient = ApiClient(ApiService.urlsFrom(config.apiDomain));

  if (config.enableLogging) {
    apiClient.addInterceptorToAll(const ApiLoggerInterceptor());
  }
  if (config.enableCrashlytics && monitoring.hasSupport) {
    apiClient.addInterceptorToAll(ProductionErrorInterceptor(
      recordError: (msg) => monitoring.crashlytics.log(msg),
    ));
  }

  final authSetup = AuthSetup.create(
    apiClient: apiClient,
    authBaseUrl: 'https://${ApiService.auth.subdomain}.${config.apiDomain}',
    bootstrapMinDuration: const Duration(milliseconds: 300),
    onRequireLogin: (_) => appNavigator.pushNamed(RouterConstants.login),
  );

  final notifyBaseUrl =
      'https://${ApiService.notify.subdomain}.${config.apiDomain}';
  final sseService = NotificationSseService(baseUrl: notifyBaseUrl, enableLog: false);
  final notifyDataSource =
      NotificationDataSource(apiClient.dio(ApiService.notify));
  final notificationCountCubit = NotificationCountCubit(
    dataSource: notifyDataSource,
    sseService: sseService,
  );

  final merchantSessionCubit = MerchantSessionCubit(apiClient: apiClient);

  AppRouter.init(
    routes: [...shellRouter, ...routes],
    topRoutes: ['/'],
    observers: monitoring.observers,
  );

  await init(
    darkTheme: AppTheme.lightTheme,
    theme: AppTheme.lightTheme,
    themeMode: ThemeMode.light,
    loading: const LoadingPage(),
    supportedLocales: const [Locale('vi'), Locale('en')],
    locale: const Locale('vi'),
    localizationsDelegates: [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    routerConfig: AppRouter.router,
    downloadFolderName: 'CouppaMiniOS',
    boxes: const ['auth_cache', 'merchant_cache', 'reference_cache'],
    providers: [
      BlocProvider<AuthSessionBloc>.value(value: authSetup.authSessionBloc),
      BlocProvider<BootstrapBloc>.value(value: authSetup.bootstrapBloc),
      BlocProvider<NotificationCountCubit>.value(value: notificationCountCubit),
      BlocProvider<MerchantSessionCubit>.value(value: merchantSessionCubit),
    ],
    builder: (child) => FieldScope(
      uploadService: DirectUploadService(dio: apiClient.dio(ApiService.file)),
      child: AppAuthListener(child: child),
    ),
    asyncCallbacks: _splashCallbacks(monitoring),
    initializedCallbacks: _initCallbacks(
      authSetup,
      monitoring,
      sseService,
      notificationCountCubit,
      merchantSessionCubit,
    ),
  );
}

List<Future<void> Function()> _splashCallbacks(SharedMonitoring monitoring) => [
  () => Future.delayed(const Duration(milliseconds: 500)),
  () => Future.delayed(const Duration(milliseconds: 1000)),
  () => Future.delayed(const Duration(milliseconds: 1500)),
  () => Future.delayed(const Duration(milliseconds: 1500)),
  () async {
    await monitoring.initFirebase(analytics: true, crashlytics: true);
    if (monitoring.hasSupport) {
      AppLogOutput.crashlyticsLog = (msg) => monitoring.crashlytics.log(msg);
    }
  },
];

List<Future<void> Function()> _initCallbacks(
  AuthSetup authSetup,
  SharedMonitoring monitoring,
  NotificationSseService sseService,
  NotificationCountCubit notificationCountCubit,
  MerchantSessionCubit merchantSessionCubit,
) => [
  () async {
    await merchantSessionCubit.hydrateFromCache();
    authSetup.bootstrapBloc.add(const BootstrapStarted());
  },
  () async {
    if (monitoring.hasSupport) {
      monitoring.setPayloadFunction((payload) {
        final String? screen = payload['screen']?.toString();
        final String? reportId = payload['id']?.toString();
        if (screen != null && screen.isNotEmpty) {
          appNavigator.pushNamed(screen, arguments: {'id': reportId});
        }
        notificationCountCubit.refresh();
      });
    }

    factories['messageRefresh'] = () => notificationCountCubit.refresh();

    authSetup.authSessionBloc.stream.listen((state) {
      if (state is AuthAuthenticated) {
        final token = authSetup.repository.getAccessTokenSync();
        if (token != null && token.isNotEmpty) {
          sseService.connect(token: token);
        }
        notificationCountCubit.refresh();
      } else {
        sseService.disconnect();
        merchantSessionCubit.clear();
      }
    });
  },
];

