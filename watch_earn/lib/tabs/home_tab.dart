import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../screens/withdraw_screen.dart';
import '../services/notification_service.dart';
import '../utils/helpers.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  BannerAd? _bannerAd;
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  bool _isBannerLoaded = false;
  bool _isRewardedReady = false;
  String? _playerId;
  bool _hasShownMilestone = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _loadAds();
    _getUserData();
  }

  Future<void> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _playerId = doc.data()?['playerId'] ?? user.uid;
      });
    }
  }

  void _loadAds() {
    // Banner Ad
    BannerAd(
      size: AdSize.banner,
      adUnitId: 'ca-app-pub-4792713510799915/3581531285',
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
            _isBannerLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    ).load();

    // Rewarded Ad
    _loadRewardedAd();

    // Interstitial Ad
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-4792713510799915/2076877924',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) {},
      ),
    );
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-4792713510799915/5422789666',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedReady = true;
        },
        onAdFailedToLoad: (error) {},
      ),
    );
  }

  Future<void> _watchRewardedAd() async {
    if (!_isRewardedReady) {
      await Helpers.retry(
        action: () async {
          _loadRewardedAd();
          await Helpers.delay(const Duration(seconds: 2));
          if (!_isRewardedReady) throw Exception('Ad not ready');
        },
        maxAttempts: 3,
      );
      if (!_isRewardedReady) {
        NotificationService.showError('Ad not available, try again');
        return;
      }
    }

    _rewardedAd!.show(onUserEarnedReward: (ad, reward) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await Helpers.retry(
          action: () async {
            final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
            final snap = await doc.get();
            int currentPoints = snap.data()?['points'] ?? 0;
            await doc.update({'points': currentPoints + 1000});
            await doc.collection('earnings').add({
              'points': 1000,
              'timestamp': FieldValue.serverTimestamp(),
            });
          },
          maxAttempts: 3,
        );
        if (mounted) {
          NotificationService.showSuccess('+1000 POINTS!');
          setState(() {});
        }
      }
      _loadRewardedAd();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00F0FF)),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final points = data['points'] ?? 0;
        final level = Helpers.calculateLevel(points);
        final nextLevelPoints = level * 10000;
        final progress = (points / nextLevelPoints).clamp(0.0, 1.0);
        final dollars = (points / 1000).toStringAsFixed(2);
        final canWithdraw = points >= 10000;

        if (points >= 10000 && !_hasShownMilestone) {
          _hasShownMilestone = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showMilestoneDialog();
          });
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          color: const Color(0xFF00F0FF),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF00F0FF).withOpacity(0.1),
                                const Color(0xFF6B00FF).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF00F0FF).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF00F0FF), Color(0xFF6B00FF)],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.auto_awesome,
                                        size: 30,
                                        color: Colors.white,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'PLAYER ID',
                                      style: TextStyle(
                                        color: Color(0xFF00F0FF),
                                        fontSize: 10,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    Text(
                                      _playerId ?? 'LOADING...',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFFF00E5)),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.bolt,
                                      color: Color(0xFFFF00E5),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'LVL $level',
                                      style: const TextStyle(
                                        color: Color(0xFFFF00E5),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF12122A), Color(0xFF1A1A3A)],
                          ),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Color(0xFF00F0FF).withOpacity(
                                0.5 + _pulseController.value * 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00F0FF).withOpacity(
                                0.2 + _pulseController.value * 0.2,
                              ),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'BALANCE',
                              style: TextStyle(
                                color: Color(0xFF00F0FF),
                                letterSpacing: 4,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFF00F0FF), Color(0xFFFF00E5)],
                              ).createShader(bounds),
                              child: Text(
                                Helpers.formatPoints(points),
                                style: const TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.attach_money,
                                  color: Color(0xFF00F0FF),
                                  size: 18,
                                ),
                                Text(
                                  '\$$dollars USD',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFF00F0FF),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                widthFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF00F0FF),
                                        Color(0xFFFF00E5)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(progress * 100).toStringAsFixed(0)}% to Level ${level + 1}',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: _buildNeonButton(
                          onPressed: _watchRewardedAd,
                          icon: Icons.play_circle_filled,
                          label: 'WATCH ADS',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00F0FF), Color(0xFF6B00FF)],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildNeonButton(
                          onPressed: canWithdraw
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => WithdrawScreen(
                                        currentPoints: points,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          icon: Icons.account_balance_wallet,
                          label: 'WITHDRAW',
                          gradient: canWithdraw
                              ? const LinearGradient(
                                  colors: [Color(0xFFFF00E5), Color(0xFF6B00FF)],
                                )
                              : const LinearGradient(
                                  colors: [Colors.grey, Colors.grey],
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_isBannerLoaded && _bannerAd != null)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF00F0FF)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNeonButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required LinearGradient gradient,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _showMilestoneDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A3A), Color(0xFF0A0A1A)],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFFF00E5), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events,
                size: 80,
                color: Color(0xFFFF00E5),
              ),
              const SizedBox(height: 16),
              const Text(
                'ACHIEVEMENT UNLOCKED!',
                style: TextStyle(
                  color: Color(0xFFFF00E5),
                  fontSize: 18,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You reached \$10',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00F0FF),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Withdrawal is now available.\nProceed to cash out your earnings.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF00F0FF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('LATER'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WithdrawScreen(currentPoints: 0),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF00E5),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('WITHDRAW NOW'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bannerAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }
}