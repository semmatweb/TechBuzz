import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../ad_helper.dart';

class PostBannerAdMob extends StatefulWidget {
  const PostBannerAdMob({super.key});

  @override
  State<PostBannerAdMob> createState() => _PostBannerAdMobState();
}

class _PostBannerAdMobState extends State<PostBannerAdMob> {
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
              const SizedBox(height: 20),
              SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(
                  ad: _bannerAd!,
                ),
              ),
            ],
          )
        : const SizedBox.shrink();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
