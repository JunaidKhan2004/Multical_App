import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';

/// A banner ad pinned to the bottom of a screen, styled to match the app's
/// brutalist border/shadow language. Loads its own [BannerAd] and reserves
/// no space until the ad actually loads, so a failed/slow load never leaves
/// a blank gap above the screen's content.
class BannerAdBar extends StatefulWidget {
  final bool isDark;
  const BannerAdBar({super.key, required this.isDark});

  @override
  State<BannerAdBar> createState() => _BannerAdBarState();
}

class _BannerAdBarState extends State<BannerAdBar> {
  static const _maxRetries = 3;
  static const _retryDelays = [
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 30),
  ];

  BannerAd? _ad;
  bool _failed = false;
  int _attempt = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    BannerAd(
      size: AdSize.banner,
      adUnitId: AdService.bannerAdUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _ad = ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          // NO_FILL and transient network errors are common and usually
          // resolve on their own — retry a few times with backoff before
          // giving up and hiding the bar for this screen instance.
          if (_attempt < _maxRetries) {
            final delay = _retryDelays[_attempt];
            _attempt++;
            Future.delayed(delay, () {
              if (mounted) _load();
            });
          } else {
            setState(() => _failed = true);
          }
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null || _failed) return const SizedBox.shrink();

    final borderColor = widget.isDark ? AppColors.dark : AppColors.medium;
    final surface =
        widget.isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      width: double.infinity,
      color: surface,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 2),
            ),
            width: ad.size.width.toDouble(),
            height: ad.size.height.toDouble(),
            child: AdWidget(ad: ad),
          ),
        ],
      ),
    );
  }
}
