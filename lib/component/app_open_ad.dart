import 'dart:developer' as dev;
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppOpenAdManager {
  ///
  String adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/3419835294'
      : 'ca-app-pub-3940256099942544/5662855259';

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  void loadAd() {
    dev.log('AppOpenAdManager: loadAd');
    AppOpenAd.load(
      adUnitId: adUnitId,
      orientation: AppOpenAd.orientationPortrait,
      request: AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          dev.log('AppOpenAdManager: onAdLoaded');
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          dev.log('AppOpenAdManager: onAdFailedToLoad');
          debugPrint('AppOpenAd failed to load: $error');
        },
      ),
    );
  }

  bool get isAdAvailable => _appOpenAd != null;

  void showAdIfAvailable() {
    dev.log('AppOpenAdManager: showAdIfAvailable');
    if (!isAdAvailable) {
      debugPrint('Tried to show ad before available.');
      loadAd();
      return;
    }
    if (_isShowingAd) {
      debugPrint('Tried to show ad while already showing an ad.');
      return;
    }
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        debugPrint('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
    );
    _appOpenAd!.show();
  }
}

class AppLifecycleReactor {
  final AppOpenAdManager appOpenAdManager;

  AppLifecycleReactor({required this.appOpenAdManager});

  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream
        .forEach((state) => _onAppStateChanged(state));
  }

  void _onAppStateChanged(AppState appState) {
    dev.log('AppOpenAdManager: _onAppStateChanged: $appState');
    if (appState == AppState.foreground) {
      appOpenAdManager.showAdIfAvailable();
    }
  }
}
