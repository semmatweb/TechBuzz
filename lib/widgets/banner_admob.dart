import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../ad_helper.dart';

class BannerAdMob extends StatefulWidget {
  const BannerAdMob({super.key});

  @override
  State<BannerAdMob> createState() => _BannerAdMobState();
}

class _BannerAdMobState extends State<BannerAdMob> {
  BannerAd? _bannerAd;

  Future<void> _loadBannerAd() async {
    final AnchoredAdaptiveBannerAdSize? adSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate() - 40,
    );

    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: adSize!,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          setState(() {
            _bannerAd = null;
          });
          debugPrint('Failed to load banner ad: ${error.message}');
          ad.dispose();
        },
        onAdClosed: (ad) {
          setState(() {
            _bannerAd = null;
          });
          ad.dispose();
        },
      ),
    );
    return _bannerAd!.load();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _loadBannerAd);
  }

  @override
  Widget build(BuildContext context) {
    return _bannerAd != null
        ? Column(
            children: [
              const SizedBox(height: 25),
              SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(
                  ad: _bannerAd!,
                ),
              ),
              const SizedBox(height: 25),
            ],
          )
        : const SizedBox(height: 30);
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
