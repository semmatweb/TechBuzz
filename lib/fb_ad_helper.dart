import 'dart:io';

class FBAdHelper {
  static String get bannerAdPlacementId {
    if (Platform.isAndroid) {
      return '254979900341757_254995493673531';
    } else if (Platform.isIOS) {
      return 'YOUR_PLACEMENT_ID';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdPlacementId {
    if (Platform.isAndroid) {
      return '254979900341757_254994077007006';
    } else if (Platform.isIOS) {
      return 'YOUR_PLACEMENT_ID';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
