import 'package:flutter/material.dart';

class GuideTab extends StatelessWidget {
  const GuideTab({super.key});

  final List<Map<String, dynamic>> _guides = const [
    {
      'icon': Icons.play_circle,
      'title': 'How to Earn Points',
      'color': Color(0xFF00F0FF),
      'steps': [
        '📺 Watch rewarded video ads',
        '✨ Each ad gives you 1000 points',
        '💰 1000 points = 1 USD',
        '📈 Maximum 20 ads per day',
      ],
    },
    {
      'icon': Icons.account_balance_wallet,
      'title': 'Withdrawal Rules',
      'color': Color(0xFFFF00E5),
      'steps': [
        '🎯 Minimum: 10,000 points (10 USD)',
        '🔐 Account verification required',
        '💳 Multiple payment methods available',
        '⏱️ Processing time: 24h - 14 days',
      ],
    },
    {
      'icon': Icons.verified_user,
      'title': 'Account Verification',
      'color': Color(0xFF6B00FF),
      'steps': [
        '📝 Full name matching ID',
        '📞 Valid phone number',
        '🏠 Complete address',
        '💳 Payment method details',
      ],
    },
    {
      'icon': Icons.auto_awesome,
      'title': 'Pro Tips',
      'color': Color(0xFFFF6B00),
      'steps': [
        '🔥 Watch ads daily for bonuses',
        '🎁 Special events = 2x points',
        '👥 Referral program coming soon',
        '⭐ Reach higher levels for perks',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'GUIDE',
                style: TextStyle(
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF00F0FF).withOpacity(0.3),
                      const Color(0xFF6B00FF).withOpacity(0.3),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.auto_awesome,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final guide = _guides[index];
                  return _buildGuideCard(guide);
                },
                childCount: _guides.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideCard(Map<String, dynamic> guide) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF12122A),
            Color(0xFF1A1A3A),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (guide['color'] as Color).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (guide['color'] as Color).withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (guide['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: guide['color'], width: 1),
                  ),
                  child: Icon(guide['icon'], color: guide['color'], size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    guide['title'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (guide['steps'] as List<String>).map((step) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4, right: 12),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: guide['color'],
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          step,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}