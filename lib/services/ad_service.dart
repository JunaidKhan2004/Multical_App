import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Initializes the Mobile Ads SDK and hands out banner ad unit IDs.
///
/// Uses Google's public TEST ad unit IDs in debug builds so development
/// never serves (and never accidentally clicks) real ads — swap the
/// `_prodBannerAndroid`/`_prodBannerIOS` constants for your own AdMob unit
/// IDs before a release build.
class AdService {
  AdService._();

  static const _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const _testBannerIOS = 'ca-app-pub-3940256099942544/2934735716';

  static const _prodBannerAndroid = 'ca-app-pub-5701334230119067/7721555767';
  // TODO: replace with your real iOS AdMob banner ad unit ID before release.
  static const _prodBannerIOS = 'ca-app-pub-3940256099942544/2934735716';

  static Future<void> init() => MobileAds.instance.initialize();

  static String get bannerAdUnitId {
    final useTest = kDebugMode;
    if (Platform.isAndroid) {
      return useTest ? _testBannerAndroid : _prodBannerAndroid;
    }
    if (Platform.isIOS) {
      return useTest ? _testBannerIOS : _prodBannerIOS;
    }
    throw UnsupportedError('Ads are only supported on Android and iOS');
  }
}
