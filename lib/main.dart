import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../AppTheme.dart';
import '../Store/AppStore.dart';
import '../app_localizations.dart';
import '../model/LanguageModel.dart';
import '../screen/DataScreen.dart';
import '../utils/common.dart';
import '../utils/constant.dart';
import 'component/NoInternetConnection.dart';

AppStore appStore = AppStore();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await FlutterDownloader.initialize(debug: true);
  HttpOverrides.global = HttpOverridesSkipCertificate();
  await initialize();
  appStore.setDarkMode(aIsDarkMode: getBoolAsync(isDarkModeOnPref));
  appStore.setLanguage(getStringAsync(APP_LANGUAGE, defaultValue: 'en'));

  if (isMobile) {
    MobileAds.instance.initialize();
    await OneSignal.shared
        .setAppId(getStringAsync(ONESINGLE, defaultValue: mOneSignalID));
    OneSignal.shared.consentGranted(true);
    OneSignal.shared.promptUserForPushNotificationPermission();
    await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
    FlutterDownloader.registerCallback(DownloadClass.downloadCallback);
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late AppLifecycleReactor _appLifecycleReactor;

  @override
  void initState() {
    super.initState();
    setStatusBarColor(appStore.primaryColors,
        statusBarBrightness: Brightness.light);

    /// App Open Ad
    AppOpenAdManager appOpenAdManager = AppOpenAdManager()..loadAd();

    _appLifecycleReactor =
        AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
    _appLifecycleReactor.listenToAppStateChanges();

    ///

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((e) async {
      appStore.setConnectionState(e);
      if (e == ConnectivityResult.none) {
        log('not connected');
        push(NoInternetConnection());
      } else {
        pop();
        log('connected');
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home:
            appStore.isNetworkAvailable ? DataScreen() : NoInternetConnection(),
        supportedLocales: Language.languagesLocale(),
        navigatorKey: navigatorKey,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        localeResolutionCallback: (locale, supportedLocales) => locale,
        locale: Locale(getStringAsync(APP_LANGUAGE, defaultValue: 'en')),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: appStore.isDarkModeOn! ? ThemeMode.dark : ThemeMode.light,
        scrollBehavior: SBehavior(),
      );
    });
  }
}

class DownloadClass {
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    // Handle download callback here
    print('Download ID: $id');
    print('Download Status: $status');
    print('Download Progress: $progress%');
  }
}

class HttpOverridesSkipCertificate extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

// Other classes and methods used in the code
// ...

void initialize() {
  // Initialization logic
  // ...
}

void setStatusBarColor(Color color, {Brightness statusBarBrightness = Brightness.dark}) {
  // Set status bar color logic
  // ...
}

void push(Widget widget) {
  // Push widget to navigator logic
  // ...
}

void pop() {
  // Pop from navigator logic
  // ...
}

class Connectivity {
  Stream<ConnectivityResult> get onConnectivityChanged {
    // Connectivity stream logic
    // ...
  }
}

class ConnectivityResult {
  // Connectivity result logic
  // ...
}

class AppLifecycleReactor {
  AppLifecycleReactor({required AppOpenAdManager appOpenAdManager}) {
    // App lifecycle reactor initialization logic
    // ...
  }

  void listenToAppStateChanges() {
    // Listen to app state changes logic
    // ...
  }
}

class AppOpenAdManager {
  void loadAd() {
    // Load app open ad logic
    // ...
  }
}

class SBehavior extends ScrollBehavior {
  // Scroll behavior logic
  // ...
}

class Language {
  static List<Locale> languagesLocale() {
    // Supported languages logic
    // ...
  }
}

class AppLocalizations {
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // App localizations logic
  // ...
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Supported locale logic
    // ...
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    // Load app localizations logic
    // ...
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    // Should reload logic
    // ...
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    // Light theme logic
    // ...
  }

  static ThemeData get darkTheme {
    // Dark theme logic
    // ...
  }

  Color get primaryColors {
    // Primary colors logic
    // ...
  }
}

class MobileAds {
  static final MobileAds instance = MobileAds();

  void initialize() {
    // Mobile ads initialization logic
    // ...
  }
}

class OneSignal {
  static final shared = OneSignal();

  Future<void> setAppId(String appId) async {
    // Set OneSignal app ID logic
    // ...
  }

  void consentGranted(bool granted) {
    // Set OneSignal consent granted logic
    // ...
  }

  void promptUserForPushNotificationPermission() {
    // Prompt user for push notification permission logic
    // ...
  }
}

class NoInternetConnection extends StatelessWidget {
  // No internet connection widget logic
  // ...
}

class DataScreen extends StatelessWidget {
  // Data screen widget logic
  // ...
}

// Rest of the code...
