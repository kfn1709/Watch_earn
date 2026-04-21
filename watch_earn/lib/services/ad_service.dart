import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../utils/helpers.dart';

class AdService {

  static const String appId = 'ca-app-pub-4792713510799915~3451232442';

  static const String bannerAdUnitId = 'ca-app-pub-4792713510799915/3581531285';

  static const String interstitialAdUnitId = 'ca-app-pub-4792713510799915/2076877924';

  static const String rewardedAdUnitId = 'ca-app-pub-4792713510799915/5422789666';

  static Future<void> init() async {

    await Helpers.retry(

      action: () => MobileAds.instance.initialize(),

      maxAttempts: 3,

      delayBetween: const Duration(seconds: 2),

    );

  }

  static Future<BannerAd?> createBannerAd() async {

    final completer = Completer<BannerAd?>();

    

    final banner = BannerAd(

      size: AdSize.banner,

      adUnitId: bannerAdUnitId,

      request: const AdRequest(),

      listener: BannerAdListener(

        onAdLoaded: (ad) => completer.complete(ad as BannerAd),

        onAdFailedToLoad: (ad, error) {

          ad.dispose();

          completer.complete(null);

        },

      ),

    );

    

    banner.load();

    

    return await Helpers.withTimeout(

      action: () => completer.future,

      timeout: const Duration(seconds: 15),

      defaultValue: null,

    );

  }

  static Future<InterstitialAd?> createInterstitialAd() async {

    final completer = Completer<InterstitialAd?>();

    

    InterstitialAd.load(

      adUnitId: interstitialAdUnitId,

      request: const AdRequest(),

      adLoadCallback: InterstitialAdLoadCallback(

        onAdLoaded: (ad) => completer.complete(ad),

        onAdFailedToLoad: (error) => completer.complete(null),

      ),

    );

    

    return await Helpers.withTimeout(

      action: () => completer.future,

      timeout: const Duration(seconds: 15),

      defaultValue: null,

    );

  }

  static Future<RewardedAd?> createRewardedAd() async {

    return await Helpers.retry(

      action: () async {

        final completer = Completer<RewardedAd?>();

        

        RewardedAd.load(

          adUnitId: rewardedAdUnitId,

          request: const AdRequest(),

          rewardedAdLoadCallback: RewardedAdLoadCallback(

            onAdLoaded: (ad) => completer.complete(ad),

            onAdFailedToLoad: (error) => completer.complete(null),

          ),

        );

        

        return await completer.future;

      },

      maxAttempts: 2,

      delayBetween: const Duration(seconds: 1),

    );

  }

}