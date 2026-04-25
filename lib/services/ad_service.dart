import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/ads/ad_ids.dart';
class AdService {
  static void showReward(Function onGift) {
    RewardedAd.load(
      adUnitId: AdIds.rewardId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => ad.show(onUserEarnedReward: (a, r) => onGift()),
        onAdFailedToLoad: (e) => print(e),
      ),
    );
  }
}
